import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/storage/db/db_helper.dart';
import 'package:mhabit/storage/hobby_wallet_repository.dart';
import 'package:mhabit/storage/wishloop_backup.dart';

void main() {
  late DBHelper helper;
  late HobbyWalletRepository repo;
  late WishLoopBackup backup;
  setUp(() async {
    helper = DBHelper();
    await helper.init();
    repo = HobbyWalletRepository(helper.db, clock: () => DateTime(2026, 9, 7));
    backup = WishLoopBackup(helper.db);
    final h = await repo.saveHobby(
      name: '读书',
      emoji: '📚',
      description: '每天',
      durationMinutes: 20,
      rewardMinor: 500,
      weekdayMask: 127,
      frequency: HabitFrequency.daily,
    );
    await repo.complete(h);
    final w = await repo.saveWish(
      name: '新书',
      targetPriceMinor: 300,
      emoji: '📖',
      note: '',
      isPrimary: true,
    );
    await repo.redeem(w);
  });
  tearDown(() async => helper.db.close());

  test(
    'full backup round trip preserves records, ledger, redemption and primary wish',
    () async {
      await repo.saveWish(
        name: 'Next',
        targetPriceMinor: 2000,
        emoji: '🎁',
        note: 'note',
        isPrimary: true,
      );
      final original = await backup.exportData();
      await repo.adjust(requestId: 'later', amountMinor: 1000, title: 'later');
      await backup.restore(original);
      expect((await repo.load()).balanceMinor, 200);
      expect(
        (await repo.load()).wishes.where((w) => w.isPrimary).single.name,
        'Next',
      );
      expect((await repo.load()).redemptions.length, 1);
      expect((await helper.db.query('mh_records')).length, 1);
      // Restoring twice is idempotent; no duplicate earnings or spends.
      await backup.restore(original);
      expect((await repo.load()).balanceMinor, 200);
    },
  );
  test('checksum and unsupported schema rejected before mutation', () async {
    final original =
        jsonDecode(await backup.exportData()) as Map<String, dynamic>;
    for (final altered in [
      {...original, 'sha256': 'bad'},
      {...original, 'schema': 999},
      {...original, 'data': '{}'},
    ]) {
      await expectLater(
        backup.restore(jsonEncode(altered)),
        throwsFormatException,
      );
      expect((await repo.load()).balanceMinor, 200);
    }
  });
  test('broken linked ledger rolls back ALL table replacements', () async {
    final envelope =
        jsonDecode(await backup.exportData()) as Map<String, dynamic>;
    final data = jsonDecode(envelope['data'] as String) as Map<String, dynamic>;
    (data['hw_transactions'] as List).removeWhere((r) => r['type'] == 'EARN');
    envelope['data'] = jsonEncode(data);
    envelope['sha256'] = sha256
        .convert(utf8.encode(envelope['data'] as String))
        .toString();
    await expectLater(
      backup.restore(jsonEncode(envelope)),
      throwsFormatException,
    );
    expect((await repo.load()).balanceMinor, 200);
    expect((await helper.db.query('hw_checkins')).length, 1);
    expect((await helper.db.query('hw_redemptions')).length, 1);
  });
}
