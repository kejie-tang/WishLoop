import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/hobby_wallet.dart';
import 'package:mhabit/models/reward_calendar.dart';
import 'package:mhabit/storage/db/db_helper.dart';
import 'package:mhabit/storage/db/sql.dart';
import 'package:mhabit/storage/hobby_wallet_repository.dart';
import 'package:mhabit/storage/wishloop_backup.dart';
import 'package:mhabit/utils/reward_money.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'fixtures/v9_schema.dart';

void main() {
  late DBHelper helper;
  late HobbyWalletRepository repo;
  late DateTime now;
  Future<String> hobby(
    int amount, {
    HabitFrequency frequency = HabitFrequency.daily,
  }) => repo.saveHobby(
    name: amount < 0 ? '熬夜' : '跑步',
    emoji: '🌱',
    description: '',
    durationMinutes: 30,
    rewardMinor: amount,
    weekdayMask: 127,
    frequency: frequency,
  );
  setUp(() async {
    helper = DBHelper();
    await helper.init();
    now = DateTime(2026, 9, 7, 21, 30);
    repo = HobbyWalletRepository(helper.db, clock: () => now);
  });
  tearDown(() async {
    if (helper.db.isOpen) await helper.db.close();
  });

  test(
    'decimal input rounds half-up symmetrically, pads and never uses doubles',
    () {
      for (final e in {
        '5': 500,
        '5.': 500,
        '.5': 50,
        '1.234': 123,
        '1.235': 124,
        '9.999': 1000,
        '-0.005': -1,
        '-3.456': -346,
        '+3.456': 346,
        '0.0049': 0,
        '−3.5': -350,
        '9999999999.99': 999999999999,
      }.entries) {
        expect(RewardMoney.parse(e.key, signed: true), e.value, reason: e.key);
      }
      expect(RewardMoney.decimal(RewardMoney.parse('3.5')!), '3.50');
      for (final invalid in [
        'NaN',
        'Infinity',
        '1e4',
        '--1',
        '1.2.3',
        '9999999999.995',
      ]) {
        expect(RewardMoney.parse(invalid, signed: true), isNull);
      }
      expect(RewardMoney.parse('-1'), isNull);
    },
  );

  test(
    'negative occurrence deducts once; undo and repeat preserve original signed amount',
    () async {
      final bad = await hobby(-346);
      final results = await Future.wait(
        List.generate(10, (_) => repo.complete(bad)),
      );
      expect(results.whereType<int>().toList(), [-346]);
      var s = await repo.load();
      expect(s.balanceMinor, -346);
      expect(s.dayNetMinor, -346);
      expect(s.dailyNetMinor[repo.today.epochDay], -346);
      expect(s.transactions.single.amountMinor, -346);
      await repo.saveHobby(
        id: bad,
        name: '熬夜',
        emoji: '🌙',
        description: '',
        durationMinutes: 30,
        rewardMinor: -1000,
        weekdayMask: 127,
        frequency: HabitFrequency.daily,
      );
      await repo.undo(bad, repo.today);
      expect((await repo.load()).balanceMinor, 0);
      expect(await helper.db.query('hw_transactions'), isEmpty);
      await repo.complete(bad);
      s = await repo.load();
      expect(s.balanceMinor, -1000);
      expect(s.transactions.length, 1);
    },
  );

  test(
    'backfill belongs to selected day/month; later undo never touches today',
    () async {
      final good = await hobby(500);
      final bad = await hobby(-125);
      final day = HabitDate(2026, 8, 31);
      await repo.complete(good, onDay: day);
      await repo.complete(bad, onDay: day);
      await repo.complete(good);
      final selected = await repo.load(onDay: day);
      expect(selected.day, day);
      expect(selected.dayNetMinor, 375);
      expect(selected.completedIds, {good, bad});
      expect(selected.dailyNetMinor[day.epochDay], 375);
      expect(selected.monthEarnedMinor, 500);
      expect(selected.recent14NetMinor, 875);
      expect(selected.balanceMinor, 875);
      await repo.undo(good, day);
      final today = await repo.load();
      expect(today.balanceMinor, 375);
      expect(today.dayNetMinor, 500);
      expect(today.dailyNetMinor[day.epochDay], -125);
      expect(today.completedIds, {good});
      expect(await repo.complete(good, onDay: day), 500);
      expect(await repo.complete(good, onDay: day), isNull);
      expect((await repo.load()).balanceMinor, 875);
      final recorded = await helper.db.query(
        'hw_checkins',
        where: 'day = ?',
        whereArgs: [day.epochDay],
      );
      expect(
        recorded.every((c) => c['completed_at'] == now.millisecondsSinceEpoch),
        isTrue,
      );
    },
  );

  test(
    'calendar history can undo archived and deleted habits without reviving them',
    () async {
      final good = await hobby(500);
      final day = repo.today.subtractDays(2);
      await repo.complete(good, onDay: day);
      await repo.setHobbyStatus(good, HabitStatus.deleted);
      var s = await repo.load(onDay: day);
      expect(s.hobbies, isEmpty);
      expect(s.dayHobbies.single.id, good);
      await repo.undo(good, day);
      s = await repo.load(onDay: day);
      expect(s.dayHobbies, isEmpty);
      expect(s.balanceMinor, 0);
    },
  );

  test(
    'future recording blocked and custom backfill retains original cycle phase',
    () async {
      final custom = await hobby(
        500,
        frequency: HabitFrequency.custom(days: 3),
      );
      await expectLater(
        repo.complete(custom, onDay: repo.today.addDays(1)),
        throwsA(isA<WalletException>()),
      );
      expect((await repo.load(onDay: repo.today.addDays(1))).dueIds, isEmpty);
      await repo.complete(custom, onDay: HabitDate(2026, 9, 5));
      expect(
        (await repo.load()).hobbies.single.habit.startDate,
        HabitDate(2026, 9, 4).epochDay,
      );
      await expectLater(
        repo.complete(custom, onDay: HabitDate(2026, 9, 6)),
        throwsA(isA<WalletException>()),
      );
      expect(await repo.complete(custom), 500);
      now = DateTime(2026, 9, 10);
      expect(await repo.complete(custom), 500);
    },
  );

  test(
    '14-day estimate counts net hobby rewards only, includes zeros, excludes outside dates',
    () async {
      final good = await hobby(140);
      final bad = await hobby(-70);
      await repo.complete(good, onDay: repo.today.subtractDays(13));
      await repo.complete(good, onDay: repo.today.subtractDays(14)); // excluded
      await repo.complete(bad);
      await repo.adjust(requestId: 'fund', amountMinor: 9000, title: '人工调整');
      final wishId = await repo.saveWish(
        name: '书',
        targetPriceMinor: 1000,
        emoji: '📚',
        note: '',
      );
      await repo.redeem(wishId); // not an earnings loss
      var s = await repo.load();
      expect(s.recent14NetMinor, 70);
      final target = WishlistItem(
        id: 'target',
        name: '目标',
        targetPriceMinor: 1000,
        emoji: '🎁',
        note: '',
        createdAt: DateTime(2026),
      );
      expect(target.estimatedDays(500, 70), 100);
      expect(target.estimatedDays(501, 70), 100); // ceil 99.8
      expect(target.estimatedDays(-100, 70), 220);
      expect(target.estimatedDays(1000, -70), 0);
      expect(target.estimatedDays(0, 0), isNull);
      expect(target.estimatedDays(0, -1), isNull);
      await repo.undo(bad, repo.today);
      s = await repo.load();
      expect(s.recent14NetMinor, 140);
    },
  );

  test(
    'week/month normalization, zero range, leap month and year boundaries',
    () {
      final day = HabitDate(2026, 9, 7);
      final week = RewardCalendarRange.containing(day, RewardCalendarMode.week);
      final month = RewardCalendarRange.containing(
        day,
        RewardCalendarMode.month,
      );
      final values = {
        day.epochDay: 100,
        day.addDays(1).epochDay: -200,
        day.addDays(14).epochDay: 1000,
        HabitDate(2026, 8, 31).epochDay: 999999,
      };
      expect(week.intensity(day, values), .5);
      expect(week.intensity(day.addDays(1), values), 1);
      expect(month.intensity(day, values), .1);
      expect(month.intensity(day.addDays(1), values), .2);
      expect(week.net(values), -100);
      expect(month.net(values), 900);
      expect(week.intensity(day, {}), 0);
      expect(week.intensity(day, {day.epochDay: 0}), 0);
      expect(week.intensity(day.addDays(14), values), 0);
      final leap = RewardCalendarRange.containing(
        HabitDate(2024, 2, 29),
        RewardCalendarMode.month,
      );
      expect(leap.length, 29);
      expect(leap.shift(1).start, HabitDate(2024, 3));
      expect(
        RewardCalendarRange.containing(
          HabitDate(2026, 12, 31),
          RewardCalendarMode.week,
        ).end,
        HabitDate(2027, 1, 4),
      );
    },
  );

  test(
    'v9 upgrade preserves all rows, redemptions, sequences, triggers and old backups',
    () async {
      final originalPath = await databaseFactory.getDatabasesPath();
      final dir = await Directory.systemTemp.createTemp('wishloop_v9_v10_');
      addTearDown(() async {
        await databaseFactory.setDatabasesPath(originalPath);
        await dir.delete(recursive: true);
      });
      final old = await openDatabase(
        path.join(dir.path, appDBName),
        version: 9,
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
          await db.execute(CustomSql.autoAddSortPostionWhenAddNewHabit);
          await db.execute(CustomSql.autoUpdateHabitsModifyTimeTrigger);
          await LegacyWalletV9Schema.migrate(db);
        },
      );
      // Only the current seeding helper needs settings; remove it before opening
      // the legacy file, so migration/backup are exercised against real v9 tables.
      await old.execute(
        "CREATE TABLE hw_settings(id INTEGER PRIMARY KEY, currency TEXT)",
      );
      await old.insert('hw_settings', {'id': 1, 'currency': 'CNY'});
      final legacy = HobbyWalletRepository(old, clock: () => now);
      final id = await legacy.saveHobby(
        name: 'old',
        emoji: '🌱',
        description: '',
        durationMinutes: 30,
        rewardMinor: 500,
        weekdayMask: 127,
        frequency: HabitFrequency.daily,
      );
      await legacy.complete(id);
      final wish = await legacy.saveWish(
        name: 'book',
        targetPriceMinor: 100,
        emoji: '📚',
        note: '',
      );
      await legacy.redeem(wish);
      await old.update(
        'sqlite_sequence',
        {'seq': 1000},
        where: 'name = ?',
        whereArgs: ['mh_habits'],
      );
      await old.execute('DROP TABLE hw_settings');
      final legacyTables = WishLoopBackup.tables.where(
        (t) => t != 'hw_settings',
      );
      final before = {
        for (final table in legacyTables) table: await old.query(table),
      };
      final payload = jsonEncode(
        before.map(
          (table, rows) => MapEntry(
            table,
            rows
                .map(
                  (row) => row.map(
                    (key, value) => MapEntry(
                      key,
                      value is double && !value.isFinite ? 'Infinity' : value,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
      final oldBackup = jsonEncode({
        'format': 'WishLoop',
        'version': 1,
        'schema': 9,
        'data': payload,
        'sha256': sha256.convert(utf8.encode(payload)).toString(),
      });
      await old.close();
      await databaseFactory.setDatabasesPath(dir.path);
      final upgraded = DBHelper();
      await upgraded.init();
      try {
        expect(await upgraded.db.getVersion(), appDBVersion);
        expect(
          (await upgraded.db.rawQuery(
            'PRAGMA foreign_keys',
          )).single.values.single,
          1,
        );
        expect(await upgraded.db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
        for (final table in legacyTables) {
          expect(await upgraded.db.query(table), before[table], reason: table);
        }
        final newRepo = HobbyWalletRepository(upgraded.db, clock: () => now);
        final bad = await newRepo.saveHobby(
          name: 'bad',
          emoji: '🌙',
          description: '',
          durationMinutes: 30,
          rewardMinor: -125,
          weekdayMask: 127,
          frequency: HabitFrequency.daily,
        );
        expect((await newRepo.load()).hobbies.last.habit.id, 1001);
        await newRepo.complete(bad);
        expect((await newRepo.load()).balanceMinor, 275);
        await upgraded.db.update(
          'mh_records',
          {'record_type': 0},
          where: 'parent_uuid = ?',
          whereArgs: [bad],
        );
        expect(
          (await newRepo.load()).balanceMinor,
          400,
        ); // cleanup trigger retained
        await WishLoopBackup(upgraded.db).restore(oldBackup);
        expect((await newRepo.load()).balanceMinor, 400);
        expect((await newRepo.load()).redemptions.length, 1);
        expect((await newRepo.load()).hobbies.length, 1);
        final corrupt = jsonDecode(oldBackup) as Map<String, dynamic>;
        final data =
            jsonDecode(corrupt['data'] as String) as Map<String, dynamic>;
        (data['hw_transactions'] as List).removeLast();
        corrupt['data'] = jsonEncode(data);
        corrupt['sha256'] = sha256
            .convert(utf8.encode(corrupt['data'] as String))
            .toString();
        await expectLater(
          WishLoopBackup(upgraded.db).restore(jsonEncode(corrupt)),
          throwsA(isA<DatabaseException>()),
        );
        expect((await newRepo.load()).balanceMinor, 400);
      } finally {
        await upgraded.db.close();
      }
    },
  );
}
