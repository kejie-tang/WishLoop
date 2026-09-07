import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/hobby_wallet.dart';
import 'package:mhabit/storage/db/db_helper.dart';
import 'package:mhabit/storage/hobby_wallet_repository.dart';
import 'package:mhabit/utils/reward_money.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DBHelper helper;
  late HobbyWalletRepository repo;
  late DateTime now;
  late String hobby;
  Future<String> addHobby({
    int reward = 500,
    HabitFrequency frequency = HabitFrequency.daily,
    int weekdays = 127,
  }) => repo.saveHobby(
    name: '跑步',
    emoji: '🏃',
    description: '',
    durationMinutes: 30,
    rewardMinor: reward,
    weekdayMask: weekdays,
    frequency: frequency,
  );
  Future<String> addWish({int price = 299900}) => repo.saveWish(
    name: '耳机',
    targetPriceMinor: price,
    emoji: '🎧',
    note: '',
    isPrimary: true,
  );
  Future<void> fund(int amount) async =>
      repo.adjust(requestId: 'fund', amountMinor: amount, title: '之前的积累');

  setUp(() async {
    helper = DBHelper();
    await helper.init();
    now = DateTime(2026, 9, 7, 10);
    repo = HobbyWalletRepository(helper.db, clock: () => now);
    hobby = await addHobby();
  });
  tearDown(() async => helper.db.close());

  test(
    'complete creates one native record and exactly one linked EARN',
    () async {
      expect(await repo.complete(hobby), 500);
      final state = await repo.load();
      expect(state.balanceMinor, 500);
      expect(state.dayNetMinor, 500);
      expect(state.monthEarnedMinor, 500);
      expect(state.transactions.single.type, WalletTransactionType.earn);
      final checkin = (await helper.db.query('hw_checkins')).single;
      expect(state.transactions.single.sourceId, checkin['id']);
      expect(
        (await helper.db.query('mh_records')).single['uuid'],
        checkin['record_uuid'],
      );
    },
  );
  test('concurrent repeated completions cannot duplicate rewards', () async {
    final results = await Future.wait(
      List.generate(10, (_) => repo.complete(hobby)),
    );
    expect(results.whereType<int>().length, 1);
    expect((await repo.load()).balanceMinor, 500);
    expect((await helper.db.query('hw_transactions')).length, 1);
  });
  test('undo removes corresponding completion, record and income', () async {
    await repo.complete(hobby);
    expect(await repo.undo(hobby, repo.today), isTrue);
    expect(await repo.undo(hobby, repo.today), isFalse);
    expect((await repo.load()).balanceMinor, 0);
    expect(await helper.db.query('hw_transactions'), isEmpty);
    expect(await helper.db.query('hw_checkins'), isEmpty);
    expect(await helper.db.query('mh_records'), isEmpty);
  });
  test('complete undo complete ends with exactly 500', () async {
    await repo.complete(hobby);
    await repo.undo(hobby, repo.today);
    await repo.complete(hobby);
    expect((await repo.load()).balanceMinor, 500);
    expect((await helper.db.query('hw_transactions')).length, 1);
  });
  test('undo uses original reward even after reward is edited', () async {
    await repo.complete(hobby);
    await repo.saveHobby(
      id: hobby,
      name: 'Run',
      emoji: '🏃',
      description: '',
      durationMinutes: 30,
      rewardMinor: 1000,
      weekdayMask: 127,
      frequency: HabitFrequency.daily,
    );
    await repo.undo(hobby, repo.today);
    expect((await repo.load()).balanceMinor, 0);
    await repo.complete(hobby);
    expect((await repo.load()).balanceMinor, 1000);
  });
  test(
    'manual positive and negative adjustments are idempotent ledger entries',
    () async {
      await fund(30000);
      expect(
        await repo.adjust(requestId: 'fund', amountMinor: 30000, title: 'same'),
        isFalse,
      );
      await repo.adjust(
        requestId: 'negative',
        amountMinor: -10000,
        title: '校正',
      );
      final state = await repo.load();
      expect(state.balanceMinor, 20000);
      expect(
        state.transactions.every(
          (t) => t.type == WalletTransactionType.adjustment,
        ),
        isTrue,
      );
    },
  );
  test('balance equals ALL ledger transactions, not just recent 200', () async {
    for (var i = 0; i < 205; i++) {
      await repo.adjust(requestId: '$i', amountMinor: 101, title: 'adjust');
    }
    await repo.complete(hobby);
    final state = await repo.load();
    expect(state.transactions.length, 200);
    expect(state.balanceMinor, 205 * 101 + 500);
    expect(
      (await helper.db.rawQuery(
        'SELECT SUM(amount_minor) AS s FROM hw_transactions',
      )).single['s'],
      state.balanceMinor,
    );
  });
  test(
    'insufficient balance cannot redeem and leaves no partial writes',
    () async {
      final wish = await addWish();
      await fund(50000);
      await expectLater(
        repo.redeem(wish),
        throwsA(
          isA<WalletException>().having(
            (e) => e.reason,
            'reason',
            WalletFailure.insufficientBalance,
          ),
        ),
      );
      final state = await repo.load();
      expect(state.balanceMinor, 50000);
      expect(state.redemptions, isEmpty);
      expect(state.wishes.single.status, WishlistStatus.active);
    },
  );
  test(
    'sufficient funds create one SPEND and redemption; retry is safe',
    () async {
      final wish = await addWish();
      await fund(310000);
      final results = await Future.wait(
        List.generate(8, (_) async {
          try {
            await repo.redeem(wish);
            return true;
          } on WalletException catch (e) {
            expect(e.reason, WalletFailure.alreadyRedeemed);
            return false;
          }
        }),
      );
      expect(results.where((v) => v).length, 1);
      final state = await repo.load();
      expect(state.balanceMinor, 10100);
      expect(
        state.transactions
            .where((t) => t.type == WalletTransactionType.spend)
            .single
            .amountMinor,
        -299900,
      );
      expect(state.wishes.single.status, WishlistStatus.redeemed);
      expect(state.redemptions.single.amountMinor, 299900);
    },
  );
  test('competing wishes cannot overspend the same balance', () async {
    final a = await addWish(price: 500);
    final b = await addWish(price: 500);
    await fund(500);
    final results = await Future.wait(
      [a, b].map((id) async {
        try {
          await repo.redeem(id);
          return true;
        } on WalletException {
          return false;
        }
      }),
    );
    expect(results.where((v) => v).length, 1);
    expect((await repo.load()).balanceMinor, 0);
  });
  test(
    'undo after redemption preserves actual ledger (negative balance allowed)',
    () async {
      final wish = await addWish(price: 500);
      await repo.complete(hobby);
      await repo.redeem(wish);
      await repo.undo(hobby, repo.today);
      expect((await repo.load()).balanceMinor, -500);
    },
  );
  test('progress clamps negative and excess balances correctly', () async {
    await addWish();
    final wish = (await repo.load()).wishes.single;
    expect(wish.progressTenths(48300), 161);
    expect(wish.progress(48300), closeTo(0.16105, 0.00001));
    expect(wish.progress(-1), 0);
    expect(wish.progress(400000), 1);
    expect(wish.canRedeem(299899), isFalse);
    expect(wish.canRedeem(299900), isTrue);
  });
  test('midnight and month rollover; old-day undo is precise', () async {
    now = DateTime(2026, 9, 30, 23, 59);
    final day = repo.today;
    await repo.complete(hobby);
    now = DateTime(2026, 10, 1);
    expect((await repo.load()).dayNetMinor, 0);
    expect((await repo.load()).monthEarnedMinor, 0);
    await repo.complete(hobby);
    await repo.undo(hobby, day);
    expect((await repo.load()).balanceMinor, 500);
  });
  test('weekdays, archive and weekly quotas respected', () async {
    final weekday = await addHobby(weekdays: 31);
    final weekly = await addHobby(frequency: const HabitFrequency.weekly());
    await repo.complete(weekly);
    now = DateTime(2026, 9, 8);
    expect((await repo.load()).dueIds.contains(weekly), isFalse);
    await expectLater(repo.complete(weekly), throwsA(isA<WalletException>()));
    now = DateTime(2026, 9, 12);
    await expectLater(repo.complete(weekday), throwsA(isA<WalletException>()));
    await repo.setHobbyStatus(hobby, HabitStatus.archived);
    await expectLater(repo.complete(hobby), throwsA(isA<WalletException>()));
    now = DateTime(2026, 9, 14);
    expect(await repo.complete(weekly), 500);
  });
  test(
    'legacy record edit removes matching reward through DB trigger',
    () async {
      await repo.complete(hobby);
      await helper.db.update('mh_records', {'record_type': 0});
      expect((await repo.load()).balanceMinor, 0);
      expect(await helper.db.query('hw_checkins'), isEmpty);
    },
  );
  test('transaction failure rolls back native completion too', () async {
    await helper.db.execute(
      "CREATE TRIGGER fail_earn BEFORE INSERT ON hw_transactions BEGIN SELECT RAISE(ABORT, 'test disk failure'); END",
    );
    await expectLater(repo.complete(hobby), throwsA(isA<DatabaseException>()));
    expect(await helper.db.query('mh_records'), isEmpty);
    expect(await helper.db.query('hw_checkins'), isEmpty);
  });
  test('database survives close and reopen', () async {
    await repo.complete(hobby);
    final dbPath = helper.db.path;
    await helper.db.close();
    helper = DBHelper();
    await helper.init();
    expect(helper.db.path, dbPath);
    repo = HobbyWalletRepository(helper.db, clock: () => now);
    expect((await repo.load()).balanceMinor, 500);
  });
  test(
    'monthly and anchored custom quotas reset at the correct boundary',
    () async {
      final monthly = await addHobby(frequency: const HabitFrequency.monthly());
      final custom = await addHobby(frequency: HabitFrequency.custom(days: 3));
      await repo.complete(monthly);
      await repo.complete(custom);
      now = DateTime(2026, 9, 8);
      expect((await repo.load()).dueIds.contains(monthly), isFalse);
      expect((await repo.load()).dueIds.contains(custom), isFalse);
      now = DateTime(2026, 9, 10);
      expect(await repo.complete(custom), 500);
      now = DateTime(2026, 10, 1);
      expect(await repo.complete(monthly), 500);
    },
  );
  test(
    'archive and soft delete retain already earned ledger history',
    () async {
      await repo.complete(hobby);
      await repo.setHobbyStatus(hobby, HabitStatus.archived);
      expect((await repo.load()).balanceMinor, 500);
      await repo.setHobbyStatus(hobby, HabitStatus.activated);
      expect(await repo.complete(hobby), isNull);
      await repo.setHobbyStatus(hobby, HabitStatus.deleted);
      expect((await repo.load()).hobbies, isEmpty);
      expect((await repo.load()).balanceMinor, 500);
    },
  );
  test(
    'partial native record is restored exactly when reward is undone',
    () async {
      final h = (await repo.load()).hobbies.single;
      await helper.db.insert('mh_records', {
        'parent_id': h.habit.id,
        'parent_uuid': hobby,
        'uuid': 'partial',
        'record_type': 1,
        'record_value': 0.5,
        'record_date': repo.today.epochDay,
        'reason': 'halfway',
      });
      expect(await repo.complete(hobby), 500);
      await repo.undo(hobby, repo.today);
      final record = (await helper.db.query('mh_records')).single;
      expect(record['record_value'], 0.5);
      expect(record['reason'], 'halfway');
      expect((await repo.load()).balanceMinor, 0);
    },
  );
  test(
    'legacy completed record cannot earn retroactively and can be undone',
    () async {
      final h = (await repo.load()).hobbies.single;
      await helper.db.insert('mh_records', {
        'parent_id': h.habit.id,
        'parent_uuid': hobby,
        'uuid': 'legacy-done',
        'record_type': 1,
        'record_value': 1,
        'record_date': repo.today.epochDay,
      });
      expect(await repo.complete(hobby), isNull);
      expect((await repo.load()).completedIds, contains(hobby));
      expect((await repo.load()).balanceMinor, 0);
      expect(await repo.undo(hobby, repo.today), isTrue);
      expect(await repo.complete(hobby), 500);
    },
  );

  test('integer decimal parsing is exact and rejects invalid money', () {
    expect(RewardMoney.parse('3.50'), 350);
    expect(RewardMoney.parse('+300', signed: true), 30000);
    expect(RewardMoney.parse('0.29'), 29);
    expect(RewardMoney.parse('-3.50', signed: true), -350);
    for (final value in ['NaN', 'Infinity', '1e5', '-1', '10000000000']) {
      expect(RewardMoney.parse(value), isNull);
    }
    expect(RewardMoney.format(350), '¥3.50');
  });
  test(
    'v8 migration through production opener preserves habits AND records',
    () async {
      final dir = await Directory.systemTemp.createTemp('wishloop_migration_');
      addTearDown(() => dir.delete(recursive: true));
      final dbPath = path.join(dir.path, appDBName);
      final old = await openDatabase(
        dbPath,
        version: 8,
        onCreate: (db, _) async {
          for (final table in [
            'mh_habits',
            'mh_records',
            'mh_groups',
            'mh_sync',
          ]) {
            await db.execute(
              await File('assets/sql/$table.sql').readAsString(),
            );
          }
        },
      );
      await old.insert('mh_habits', {
        'id_': 1,
        'uuid': 'old-habit',
        'type_': 1,
        'status': 1,
        'name': 'Existing',
        'daily_goal': 1,
        'daily_goal_unit': '',
        'start_date': HabitDate(2020).epochDay,
      });
      await old.insert('mh_records', {
        'parent_id': 1,
        'parent_uuid': 'old-habit',
        'uuid': 'old-record',
        'record_type': 1,
        'record_value': 1,
        'record_date': HabitDate(2020).epochDay,
      });
      await old.close();
      await databaseFactory.setDatabasesPath(dir.path);
      final upgraded = DBHelper();
      await upgraded.init();
      expect(await upgraded.db.getVersion(), appDBVersion);
      expect((await upgraded.db.query('mh_habits')).single['name'], 'Existing');
      expect((await upgraded.db.query('mh_habits')).single['reward_minor'], 0);
      expect(
        (await upgraded.db.query('mh_records')).single['uuid'],
        'old-record',
      );
      expect(await upgraded.db.query('hw_transactions'), isEmpty);
      await upgraded.db.close();
    },
  );
}
