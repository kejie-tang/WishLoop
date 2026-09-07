import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/storage/db/db_helper.dart';
import 'package:mhabit/storage/hobby_wallet_repository.dart';

// Run with --flavor f_dev on the dedicated emulator. The release app is untouched.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android SQLite connections cannot block each other’s commit', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final ui = DBHelper();
    final worker = DBHelper();
    final closingWorker = DBHelper();
    await ui.init();
    await worker.init();
    await closingWorker.init();
    final app = HobbyWalletRepository(ui.db);
    final background = HobbyWalletRepository(worker.db);
    final third = HobbyWalletRepository(closingWorker.db);
    final before = await app.load();
    try {
      final id = await app.saveHobby(
        name: 'Concurrency test',
        emoji: '📚',
        description: '',
        durationMinutes: 20,
        rewardMinor: -346,
        weekdayMask: 127,
        frequency: HabitFrequency.daily,
      );
      final began = Completer<void>();
      final holding = ui.db.transaction((txn) async {
        began.complete();
        // The other connection attempts BEGIN while this transaction is open.
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await txn.rawQuery('SELECT COUNT(*) FROM hw_transactions');
      });
      await began.future;
      final completed = background.complete(id);
      final currency = third.setCurrency('USD');
      await Future.wait([
        holding,
        completed,
        currency,
      ]).timeout(const Duration(seconds: 8));
      for (var i = 0; i < 12; i++) {
        await Future.wait([
          app.load(),
          background.load(),
          third.load(),
          background.complete(id),
          app.setCurrency(i.isEven ? 'CNY' : 'USD'),
        ]).timeout(const Duration(seconds: 8));
      }
      final snapshot = await app.load();
      expect(snapshot.balanceMinor, before.balanceMinor - 346);
      expect(snapshot.transactions, hasLength(before.transactions.length + 1));
      expect(snapshot.currency, 'USD');
      expect(
        snapshot.transactions.every((entry) => entry.currency == 'USD'),
        isTrue,
      );
      await worker.db.close();
      expect((await app.load()).balanceMinor, before.balanceMinor - 346);
      await app.undo(id, app.today);
      expect((await third.load()).balanceMinor, before.balanceMinor);
      debugPrint(
        'WIDGET CONCURRENCY: three connections, 12 competing rounds, '
        'single ledger entry, close and undo passed',
      );
    } finally {
      if (worker.db.isOpen) await worker.db.close();
      await closingWorker.db.close();
      await ui.db.close();
    }
  });
}
