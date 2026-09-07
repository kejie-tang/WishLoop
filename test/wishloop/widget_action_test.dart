import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/hobby_wallet.dart';
import 'package:mhabit/platform/wishloop_widget.dart';
import 'package:mhabit/platform/wishloop_widget_action.dart';
import 'package:mhabit/storage/db/db_helper.dart';
import 'package:mhabit/storage/hobby_wallet_repository.dart';

void main() {
  late DBHelper helper;
  late HobbyWalletRepository repo;
  late DateTime clock;
  late L10n l;
  Future<String> add(String name, String emoji, {int reward = 500}) =>
      repo.saveHobby(
        name: name,
        emoji: emoji,
        description: '',
        durationMinutes: 20,
        rewardMinor: reward,
        weekdayMask: 127,
        frequency: HabitFrequency.daily,
      );
  Map<String, Object> args(
    String id, {
    int amount = 500,
    String day = '2026-09-07',
  }) => {'hobbyId': id, 'day': day, 'amountMinor': amount};
  Future<List> rows() async =>
      (((await WishLoopWidget.createSnapshot(repo, l))['days']
                  as Map)['2026-09-07']
              as Map)['hobbies']
          as List;
  setUp(() async {
    helper = DBHelper();
    await helper.init();
    clock = DateTime(2026, 9, 7, 10);
    repo = HobbyWalletRepository(helper.db, clock: () => clock);
    l = await L10n.delegate.load(const Locale('zh'));
  });
  tearDown(() async => helper.db.close());

  test(
    'four unfinished hobbies keep sort order and completing one fills from fifth',
    () async {
      final ids = <String>[];
      for (var i = 0; i < 6; i++) {
        ids.add(await add('Hobby $i', '📚'));
      }
      await repo.reorderHobbies(ids.reversed.toList());
      expect(
        (await rows()).map((r) => r['id']).toList(),
        ids.reversed.take(4).toList(),
      );
      expect(await WishLoopWidgetAction.complete(repo, args(ids.last)), isTrue);
      expect((await rows()).map((r) => r['id']).toList(), [
        ids[4],
        ids[3],
        ids[2],
        ids[1],
      ]);
      final row = (await rows()).first as Map;
      expect(row['emoji'], '📚');
      expect(row['amount'], '+5.00');
      expect(row['text'], isNull);
      expect(row['label'], contains('Hobby 4'));
      expect((await repo.load()).balanceMinor, 500);
    },
  );

  test(
    'concurrent widget taps earn once; explicit app undo and a later tap remain correct',
    () async {
      final id = await add('Run', '🏃');
      final results = await Future.wait(
        List.generate(8, (_) => WishLoopWidgetAction.complete(repo, args(id))),
      );
      expect(results.where((r) => r), hasLength(1));
      expect((await rows()), isEmpty);
      expect((await repo.load()).transactions, hasLength(1));
      await repo.undo(id, repo.today);
      expect(await rows(), hasLength(1));
      expect(await WishLoopWidgetAction.complete(repo, args(id)), isTrue);
      expect((await repo.load()).balanceMinor, 500);
      expect((await repo.load()).transactions, hasLength(1));
    },
  );

  test(
    'widget deductions and zero rewards use the same ledger and USD currency',
    () async {
      final bad = await add('Late', '🌙', reward: -346);
      final zero = await add('Stretch', '🧘', reward: 0);
      await repo.setCurrency('USD');
      await WishLoopWidgetAction.complete(repo, args(bad, amount: -346));
      await WishLoopWidgetAction.complete(repo, args(zero, amount: 0));
      final s = await repo.load();
      expect(s.balanceMinor, -346);
      expect(s.transactions, hasLength(2));
      expect(s.transactions.every((t) => t.currency == 'USD'), isTrue);
      final snapshot = await WishLoopWidget.createSnapshot(repo, l);
      expect(snapshot['balance'], '−\$3.46');
      expect(await rows(), isEmpty);
    },
  );

  test(
    'an edited widget price is rejected atomically instead of charging the new amount',
    () async {
      final id = await add('Run', '🏃');
      await repo.saveHobby(
        id: id,
        name: 'Run',
        emoji: '🏃',
        description: '',
        durationMinutes: 20,
        rewardMinor: -1000,
        weekdayMask: 127,
        frequency: HabitFrequency.daily,
      );
      expect(await WishLoopWidgetAction.complete(repo, args(id)), isFalse);
      expect((await repo.load()).transactions, isEmpty);
      expect((await rows()).single['amount'], '−10.00');
      expect(
        await WishLoopWidgetAction.complete(repo, args(id, amount: -1000)),
        isTrue,
      );
    },
  );

  test(
    'midnight cannot turn a stale widget tap into a backfill or tomorrow check-in',
    () async {
      final id = await add('Run', '🏃');
      clock = DateTime(2026, 9, 8);
      expect(await WishLoopWidgetAction.complete(repo, args(id)), isFalse);
      await expectLater(
        repo.complete(id, onDay: HabitDate(2026, 9, 7), requireToday: true),
        throwsA(isA<WalletException>()),
      );
      expect((await repo.load()).transactions, isEmpty);
      expect(
        await repo.complete(id, onDay: HabitDate(2026, 9, 7)),
        500,
      ); // App backfill unchanged.
    },
  );

  test(
    'malformed, missing and archived widget targets never create rewards',
    () async {
      final id = await add('Run', '🏃');
      for (final invalid in [
        null,
        '',
        {},
        args('missing'),
        args('00000000-0000-4000-8000-000000000000'),
        args(id, day: '2026-02-31'),
        {'hobbyId': id, 'day': '2026-09-07', 'amountMinor': '500'},
      ]) {
        expect(await WishLoopWidgetAction.complete(repo, invalid), isFalse);
      }
      await repo.setHobbyStatus(id, HabitStatus.archived);
      expect(await WishLoopWidgetAction.complete(repo, args(id)), isFalse);
      expect((await repo.load()).transactions, isEmpty);
      expect(await rows(), isEmpty);
    },
  );

  test(
    'native background changes refresh the existing Flutter controller',
    () async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        WishLoopWidget.channel,
        (_) async => null,
      );
      addTearDown(
        () => messenger.setMockMethodCallHandler(WishLoopWidget.channel, null),
      );
      final bridge = WishLoopWidget();
      var changes = 0;
      await bridge.start((_) {}, onChanged: () => changes++);
      await messenger.handlePlatformMessage(
        WishLoopWidget.channel.name,
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('changed'),
        ),
        (_) {},
      );
      expect(changes, 1);
      bridge.dispose();
    },
  );
}
