import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/hobby_wallet.dart';
import 'package:mhabit/storage/db/db_helper.dart';
import 'package:mhabit/storage/hobby_wallet_repository.dart';
import 'package:mhabit/storage/wishloop_backup.dart';
import 'package:mhabit/storage/wishloop_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DBHelper helper;
  late HobbyWalletRepository repo;
  setUp(() async {
    helper = DBHelper();
    await helper.init();
    repo = HobbyWalletRepository(helper.db, clock: () => DateTime(2026, 9, 7));
  });
  tearDown(() async => helper.db.close());
  Future<String> hobby(String name, {String? group, String? id}) =>
      repo.saveHobby(
        id: id,
        name: name,
        emoji: '🌱',
        description: '',
        durationMinutes: 30,
        rewardMinor: 500,
        weekdayMask: 127,
        frequency: HabitFrequency.daily,
        groupId: group,
      );

  test('category CRUD preserves check-ins and ledger when removed', () async {
    final group = await repo.saveGroup(name: '  学习  ');
    final id = await hobby('Vibe Coding', group: group);
    await repo.complete(id);
    await repo.saveGroup(id: group, name: '创造');
    expect((await repo.load()).groups.single.name, '创造');
    expect((await repo.load()).hobbies.single.groupId, group);
    await repo.deleteGroup(group);
    await repo.deleteGroup(group);
    final s = await repo.load();
    expect(s.groups, isEmpty);
    expect(s.hobbies.single.groupId, isNull);
    expect(s.balanceMinor, 500);
    expect(s.completedIds, contains(id));
    expect(s.transactions, hasLength(1));
    await expectLater(
      hobby('stale', group: group),
      throwsA(isA<WalletException>()),
    );
    expect((await repo.load()).hobbies, hasLength(1));
    expect(await repo.undo(id, repo.today), isTrue);
    expect((await repo.load()).balanceMinor, 0);
  });

  test(
    'filtered reordering preserves hidden slots and archived order',
    () async {
      final g = await repo.saveGroup(name: '学习');
      final a = await hobby('A', group: g);
      final b = await hobby('B');
      final c = await hobby('C', group: g);
      final d = await hobby('D');
      await repo.setHobbyStatus(b, HabitStatus.archived);
      await repo.reorderHobbies([c, a]);
      expect((await repo.load()).hobbies.map((h) => h.id), [c, b, a, d]);
      expect((await repo.load()).dayHobbies.map((h) => h.id), [c, a, d]);
      for (final invalid in [
        [a, a],
        [a, 'missing'],
      ]) {
        await expectLater(
          repo.reorderHobbies(invalid),
          throwsA(isA<WalletException>()),
        );
        expect((await repo.load()).hobbies.map((h) => h.id), [c, b, a, d]);
      }
      expect((await repo.load()).transactions, isEmpty);
    },
  );

  test(
    'backup and repository reload preserve categories and both orders',
    () async {
      final g1 = await repo.saveGroup(name: '运动');
      final g2 = await repo.saveGroup(name: '学习');
      final a = await hobby('跑步', group: g1);
      final b = await hobby('Vibe Coding', group: g2);
      await repo.reorderGroups([g2, g1]);
      await repo.reorderHobbies([b, a]);
      final backup = WishLoopBackup(helper.db);
      final data = await backup.exportData();
      await repo.deleteGroup(g2);
      await repo.reorderHobbies([a, b]);
      await backup.restore(data);
      final s = await HobbyWalletRepository(helper.db).load();
      expect(s.groups.map((g) => g.uuid), [g2, g1]);
      expect(s.hobbies.map((h) => h.id), [b, a]);
      expect(s.hobbies.first.groupId, g2);
    },
  );

  test(
    'category validation rejects blank, long and nonexistent names/IDs',
    () async {
      for (final name in [' ', 'x' * 101]) {
        await expectLater(
          repo.saveGroup(name: name),
          throwsA(isA<WalletException>()),
        );
      }
      await expectLater(
        repo.saveGroup(id: 'missing', name: 'a'),
        throwsA(isA<WalletException>()),
      );
      expect((await repo.load()).groups, isEmpty);
    },
  );

  test('compact layout defaults and preferences survive reload', () async {
    SharedPreferences.setMockInitialValues({});
    expect((await WishLoopLayout.load()).compact, isTrue);
    await const WishLoopLayout(compact: false, hobbiesFirst: true).save();
    final restored = await WishLoopLayout.load();
    expect(restored.compact, isFalse);
    expect(restored.hobbiesFirst, isTrue);
  });
}
