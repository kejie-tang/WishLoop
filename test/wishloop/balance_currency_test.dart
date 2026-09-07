import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/hobby_wallet.dart';
import 'package:mhabit/platform/wishloop_widget.dart';
import 'package:mhabit/storage/db/db_helper.dart';
import 'package:mhabit/storage/db/sql.dart';
import 'package:mhabit/storage/hobby_wallet_repository.dart';
import 'package:mhabit/storage/wishloop_backup.dart';
import 'package:mhabit/utils/reward_money.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'fixtures/v10_schema.dart';

void main() {
  late DBHelper helper;
  late HobbyWalletRepository repo;
  late DateTime now;
  Future<String> hobby(int amount) => repo.saveHobby(
    name: 'Vibe Coding',
    emoji: '💻',
    description: '',
    durationMinutes: 30,
    rewardMinor: amount,
    weekdayMask: 127,
    frequency: HabitFrequency.daily,
  );
  Future<void> adjust(int amount, String id) =>
      repo.adjust(requestId: id, amountMinor: amount, title: id);
  String envelope(Map<String, Object?> data, int version) {
    final payload = jsonEncode(data);
    return jsonEncode({
      'format': 'WishLoop',
      'version': 1,
      'schema': version,
      'data': payload,
      'sha256': sha256.convert(utf8.encode(payload)).toString(),
    });
  }

  setUp(() async {
    helper = DBHelper();
    await helper.init();
    now = DateTime(2026, 9, 7, 10);
    repo = HobbyWalletRepository(helper.db, clock: () => now);
  });
  tearDown(() async => helper.db.close());

  test('empty ledger has 180 consecutive zero days including today', () async {
    final s = await repo.load();
    expect(s.currency, 'CNY');
    expect(s.balanceHistory.length, 180);
    expect(s.balanceHistory.first.day, HabitDate(2026, 3, 12));
    expect(s.balanceHistory.last.day, repo.today);
    expect(
      s.balanceHistory.every((p) => p.balanceMinor == 0 && p.changeMinor == 0),
      isTrue,
    );
  });

  test(
    'daily closing balance carries older money and includes every ledger type',
    () async {
      now = DateTime(2025, 12, 31, 23, 59);
      await adjust(10000, 'opening');
      now = DateTime(2026, 8, 25);
      await adjust(-500, 'first14');
      now = DateTime(2026, 9, 7, 10);
      final id = await hobby(-200);
      await repo.complete(id, onDay: HabitDate(2026, 9, 6));
      final wish = await repo.saveWish(
        name: 'book',
        targetPriceMinor: 3000,
        emoji: '📚',
        note: '',
      );
      await repo.redeem(wish);
      final s = await repo.load();
      final last14 = s.balanceHistory.skip(166).toList();
      expect(s.balanceHistory.first.balanceMinor, 10000);
      expect(last14.first.day, HabitDate(2026, 8, 25));
      expect(last14.first.balanceMinor, 9500);
      expect(last14[1].balanceMinor, 9500);
      expect(last14[1].changeMinor, 0);
      expect(last14[12].balanceMinor, 9300);
      expect(last14.last.changeMinor, -3000);
      expect(last14.last.balanceMinor, s.balanceMinor);
      expect(s.balanceMinor, 6300);
      expect(last14.fold(0, (sum, p) => sum + p.changeMinor), -3700);
    },
  );

  test(
    'chart includes all 230 entries despite ledger preview limit of 200',
    () async {
      for (var i = 0; i < 230; i++) {
        await adjust(1, 'entry-$i');
      }
      final s = await repo.load();
      expect(s.transactions, hasLength(200));
      expect(s.balanceHistory.last.balanceMinor, 230);
      expect(s.balanceHistory.last.changeMinor, 230);
    },
  );

  test(
    'midnight, month/year and leap-day boundaries use local calendar dates',
    () async {
      now = DateTime(2024, 2, 28, 23, 59, 59);
      await adjust(100, 'before');
      now = DateTime(2024, 2, 29);
      await adjust(-150, 'leap');
      now = DateTime(2024, 3, 1);
      final points = (await repo.load()).balanceHistory;
      expect(points[177].day, HabitDate(2024, 2, 28));
      expect(points[177].balanceMinor, 100);
      expect(points[178].day, HabitDate(2024, 2, 29));
      expect(points[178].balanceMinor, -50);
      expect(points.last.changeMinor, 0);
      expect(points.last.balanceMinor, -50);
    },
  );

  test(
    'backfill undo and recomplete revise historical balance exactly once',
    () async {
      final id = await hobby(500);
      final day = repo.today.subtractDays(20);
      await repo.complete(id, onDay: day);
      await repo.complete(id, onDay: day);
      expect((await repo.load()).balanceHistory[159].changeMinor, 500);
      await repo.undo(id, day);
      expect((await repo.load()).balanceHistory.last.balanceMinor, 0);
      await repo.complete(id, onDay: day);
      final s = await repo.load(onDay: day);
      expect(s.balanceHistory.last.day, repo.today);
      expect(s.balanceHistory.last.balanceMinor, 500);
      expect(s.balanceHistory.last.changeMinor, 0);
    },
  );

  test(
    'currency persists and all existing and new ledger rows use one unit',
    () async {
      final id = await hobby(500);
      await repo.complete(id);
      await repo.setCurrency('USD');
      await adjust(600, 'usd');
      final wish = await repo.saveWish(
        name: 'book',
        targetPriceMinor: 300,
        emoji: '📚',
        note: '',
      );
      await repo.redeem(wish);
      final reopened = HobbyWalletRepository(helper.db, clock: () => now);
      final s = await reopened.load();
      expect(s.currency, 'USD');
      expect(s.balanceMinor, 800);
      expect(s.hobbies.single.rewardMinor, 500);
      expect(s.wishes.single.targetPriceMinor, 300);
      expect(s.transactions.every((t) => t.currency == 'USD'), isTrue);
      await repo.undo(id, repo.today);
      await repo.complete(id);
      expect((await repo.load()).balanceMinor, 800);
      expect(
        (await repo.load()).transactions.every((t) => t.currency == 'USD'),
        isTrue,
      );
      await repo.setCurrency('CNY');
      expect(
        (await repo.load()).transactions.every((t) => t.currency == 'CNY'),
        isTrue,
      );
    },
  );

  test(
    'unsupported and mixed currencies are rejected without changing balance',
    () async {
      await adjust(100, 'fund');
      await expectLater(
        repo.setCurrency('EUR'),
        throwsA(isA<WalletException>()),
      );
      await repo.setCurrency('USD');
      await expectLater(
        helper.db.update('hw_transactions', {'currency': 'CNY'}),
        throwsA(isA<DatabaseException>()),
      );
      expect((await repo.load()).balanceMinor, 100);
      expect((await repo.load()).transactions.single.currency, 'USD');
    },
  );

  test(
    'switch and simultaneous completions remain atomic and idempotent',
    () async {
      final id = await hobby(-125);
      await Future.wait([
        repo.setCurrency('USD'),
        repo.complete(id),
        repo.complete(id),
      ]);
      final s = await repo.load();
      expect(s.balanceMinor, -125);
      expect(s.transactions.single.currency, 'USD');
    },
  );

  test(
    'CNY USD formatting keeps exact cents and signed labels without symbols',
    () {
      expect(RewardMoney.format(123456, currency: 'USD'), r'$1,234.56');
      expect(RewardMoney.format(-101, currency: 'USD'), '−\$1.01');
      expect(
        RewardMoney.format(
          2000,
          currency: 'USD',
          signed: true,
          showSymbol: false,
        ),
        '+20.00',
      );
      expect(
        RewardMoney.format(RewardMoney.maxMinor, currency: 'USD'),
        r'$9,999,999,999.99',
      );
      expect(
        RewardMoney.format(100, currency: 'USD', showCode: true),
        'USD 1.00',
      );
      expect(RewardMoney.format(100), '¥1.00');
    },
  );

  test(
    'widget snapshot refreshes balance symbol after switching currency',
    () async {
      await adjust(1234, 'fund');
      await repo.setCurrency('USD');
      final l = await L10n.delegate.load(const Locale('zh'));
      expect(
        (await WishLoopWidget.createSnapshot(repo, l))['balance'],
        r'$12.34',
      );
    },
  );

  test(
    'backup round trip restores currency, ledger and integer amounts',
    () async {
      await adjust(150, 'fund');
      await repo.setCurrency('USD');
      final backup = WishLoopBackup(helper.db);
      final text = await backup.exportData();
      await repo.setCurrency('CNY');
      await adjust(50, 'later');
      await backup.restore(text);
      final s = await repo.load();
      expect(s.currency, 'USD');
      expect(s.transactions.single.currency, 'USD');
      expect(s.balanceMinor, 150);
    },
  );

  test(
    'old v10 backups restore CNY and malformed currency backups roll back',
    () async {
      await adjust(100, 'fund');
      final backup = WishLoopBackup(helper.db);
      final data =
          jsonDecode(jsonDecode(await backup.exportData())['data'] as String)
              as Map<String, dynamic>;
      data.remove('hw_settings');
      await repo.setCurrency('USD');
      await backup.restore(envelope(data, 10));
      expect((await repo.load()).currency, 'CNY');
      data['hw_settings'] = [
        {'id': 1, 'currency': 'USD'},
      ];
      await expectLater(
        backup.restore(envelope(data, 11)),
        throwsA(isA<DatabaseException>()),
      );
      expect((await repo.load()).currency, 'CNY');
      data['hw_settings'] = [];
      await expectLater(
        backup.restore(envelope(data, 11)),
        throwsFormatException,
      );
      expect((await repo.load()).balanceMinor, 100);
    },
  );

  test(
    'real v10 migration keeps groups, negative check-ins, spends, links and triggers',
    () async {
      final originalPath = await databaseFactory.getDatabasesPath();
      final dir = await Directory.systemTemp.createTemp('wishloop_v10_v11_');
      addTearDown(() async {
        await databaseFactory.setDatabasesPath(originalPath);
        await dir.delete(recursive: true);
      });
      final old = await openDatabase(
        path.join(dir.path, appDBName),
        version: 10,
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
          await LegacyWalletV10Schema.migrate(db);
        },
      );
      // The current helper requires the unit only for seeding. The on-disk v10
      // input below has no settings table, exactly like released 1.2.0.
      await old.execute(
        'CREATE TABLE hw_settings(id INTEGER PRIMARY KEY, currency TEXT)',
      );
      await old.insert('hw_settings', {'id': 1, 'currency': 'CNY'});
      final legacy = HobbyWalletRepository(old, clock: () => now);
      final group = await legacy.saveGroup(name: '学习');
      final id = await legacy.saveHobby(
        name: 'old',
        groupId: group,
        emoji: '🌙',
        description: '',
        durationMinutes: 30,
        rewardMinor: -125,
        weekdayMask: 127,
        frequency: HabitFrequency.daily,
      );
      await legacy.adjust(requestId: 'fund', amountMinor: 1000, title: 'fund');
      await legacy.complete(id);
      final wish = await legacy.saveWish(
        name: 'book',
        targetPriceMinor: 300,
        emoji: '📚',
        note: '',
      );
      await legacy.redeem(wish);
      await old.execute('DROP TABLE hw_settings');
      final before = {
        for (final table in WishLoopBackup.tables.where(
          (t) => t != 'hw_settings',
        ))
          table: await old.query(table),
      };
      await old.close();
      await databaseFactory.setDatabasesPath(dir.path);
      final upgraded = DBHelper();
      await upgraded.init();
      try {
        expect(await upgraded.db.getVersion(), 11);
        for (final table in before.keys) {
          expect(await upgraded.db.query(table), before[table], reason: table);
        }
        expect(await upgraded.db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
        final current = HobbyWalletRepository(upgraded.db, clock: () => now);
        expect((await current.load()).balanceMinor, 575);
        expect((await current.load()).currency, 'CNY');
        await current.setCurrency('USD');
        await current.undo(id, current.today);
        expect((await current.load()).balanceMinor, 700);
        await current.complete(id);
        await upgraded.db.update(
          'mh_records',
          {'record_type': 0},
          where: 'parent_uuid = ?',
          whereArgs: [id],
        );
        expect((await current.load()).balanceMinor, 700);
        expect(
          (await current.load()).transactions.every((t) => t.currency == 'USD'),
          isTrue,
        );
      } finally {
        await upgraded.db.close();
      }
    },
  );
}
