import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/platform/wishloop_widget.dart';
import 'package:mhabit/providers/wishloop/wallet_controller.dart';
import 'package:mhabit/storage/db/db_helper.dart';
import 'package:mhabit/storage/hobby_wallet_repository.dart';

void main() {
  late DBHelper helper;
  late HobbyWalletRepository repo;
  late L10n l;
  late String hobby;
  setUp(() async {
    helper = DBHelper();
    await helper.init();
    repo = HobbyWalletRepository(helper.db, clock: () => DateTime(2026, 9, 7));
    l = await L10n.delegate.load(const Locale('zh'));
    hobby = await repo.saveHobby(
      name: 'Vibe Coding',
      emoji: '💻',
      description: '',
      durationMinutes: 30,
      rewardMinor: 500,
      weekdayMask: 31,
      frequency: HabitFrequency.daily,
    );
    await repo.saveWish(
      name: '键盘',
      emoji: '⌨️',
      note: '',
      targetPriceMinor: 1000,
      isPrimary: true,
    );
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(WishLoopWidget.channel, null);
    await helper.db.close();
  });

  test(
    'widget always uses today, keeps signed rewards and includes upcoming schedules',
    () async {
      final vm = WalletController(repo);
      await repo.complete(hobby, onDay: repo.today.subtractDays(3));
      await vm.selectDay(repo.today.subtractDays(3));
      final s = await WishLoopWidget.createSnapshot(repo, l);
      final days = s['days'] as Map;
      expect(days, hasLength(7));
      expect((days['2026-09-07'] as Map)['netMinor'], 0);
      expect(
        ((days['2026-09-07'] as Map)['hobbies'] as List).single['text'],
        '💻 Vibe Coding  +5.00',
      );
      expect((days['2026-09-12'] as Map)['hobbies'], isEmpty);
      expect(s['progress'], 500);
      expect((await repo.load()).transactions, hasLength(1));
      await repo.complete(hobby);
      final updated = await WishLoopWidget.createSnapshot(
        repo,
        l,
        theme: 'dark',
      );
      expect(updated['theme'], 'dark');
      expect(updated['progress'], 1000);
      expect(
        (((updated['days'] as Map)['2026-09-07'] as Map)['hobbies'] as List)
            .single['text'],
        '✓ Vibe Coding  +5.00',
      );
      vm.dispose();
    },
  );

  test(
    'negative widget income and weekly quotas follow the repository rules',
    () async {
      await repo.saveHobby(
        id: hobby,
        name: '熬夜',
        emoji: '🌙',
        description: '',
        durationMinutes: 30,
        rewardMinor: -1000,
        weekdayMask: 127,
        frequency: const HabitFrequency(
          type: HabitFrequencyType.weekly,
          freq: 1,
        ),
      );
      await repo.complete(hobby);
      final s = await WishLoopWidget.createSnapshot(repo, l);
      expect(s['progress'], 0);
      final days = s['days'] as Map;
      expect((days['2026-09-07'] as Map)['netMinor'], -1000);
      expect(
        ((days['2026-09-07'] as Map)['hobbies'] as List).single['text'],
        contains('−10.00'),
      );
      expect((days['2026-09-08'] as Map)['hobbies'], isEmpty);
    },
  );

  test('native launch validation, cold start and pin response', () async {
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(WishLoopWidget.channel, (call) async {
          calls.add(call.method);
          if (call.method == 'consumeLaunch') {
            return {'target': 'today', 'hobbyId': hobby};
          }
          if (call.method == 'pinWidget') return true;
          return null;
        });
    final bridge = WishLoopWidget();
    WidgetLaunch? received;
    await bridge.start((v) => received = v);
    expect(received!.target, 'today');
    expect(received!.hobbyId, hobby);
    expect(await WishLoopWidget.pin(), isTrue);
    expect(calls, ['consumeLaunch', 'pinWidget']);
    expect(
      WidgetLaunch.parse({'target': 'complete', 'hobbyId': hobby}),
      isNull,
    );
    expect(WidgetLaunch.parse('invalid'), isNull);
    bridge.dispose();
  });

  test(
    'overlapping refreshes finish with the latest ledger snapshot',
    () async {
      final entered = Completer<void>(), release = Completer<void>();
      final snapshots = <Map<String, dynamic>>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(WishLoopWidget.channel, (call) async {
            if (call.method == 'updateSnapshot') {
              snapshots.add(
                jsonDecode(call.arguments as String) as Map<String, dynamic>,
              );
              if (snapshots.length == 1) {
                entered.complete();
                await release.future;
              }
            }
            return null;
          });
      final bridge = WishLoopWidget();
      final first = bridge.refresh(repo, l);
      await entered.future;
      await repo.complete(hobby);
      final last = bridge.refresh(repo, l);
      release.complete();
      await Future.wait([first, last]);
      expect(snapshots.last['progress'], 500);
      expect((await repo.load()).transactions, hasLength(1));
      bridge.dispose();
    },
  );
}
