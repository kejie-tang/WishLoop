// Copyright 2026 Hobby Wallet contributors
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../common/utils.dart';
import '../models/group.dart';
import '../models/habit_date.dart';
import '../models/habit_form.dart';
import '../models/habit_freq.dart';
import '../models/habit_reminder.dart';
import '../models/hobby_wallet.dart';
import '../utils/app_clock.dart';
import '../utils/reward_money.dart';

/// Owns atomic reward workflows on the existing SQLite connection.
/// There is deliberately no cached or independently persisted balance.
class HobbyWalletRepository {
  final Database Function() _database;
  final DateTime Function() now;

  HobbyWalletRepository(Database database, {DateTime Function()? clock})
    : this.withDatabase(() => database, clock: clock);

  HobbyWalletRepository.withDatabase(
    this._database, {
    DateTime Function()? clock,
  }) : now = clock ?? AppClock().now;

  Database get _db => _database();
  HabitDate get today => HabitDate.dateTime(now());

  Future<int> _balance(DatabaseExecutor db) async =>
      (await db.rawQuery(
            'SELECT COALESCE(SUM(amount_minor), 0) AS total FROM hw_transactions',
          )).single['total']
          as int;

  Future<void> _checkBalanceRange(DatabaseExecutor db, int delta) async {
    if (((await _balance(db)) + delta).abs() > RewardMoney.maxMinor) {
      throw const WalletException(WalletFailure.invalidInput);
    }
  }

  Future<HobbyWalletSnapshot> load({HabitDate? onDay}) => _db.transaction((
    db,
  ) async {
    final current = now();
    final currentDay = HabitDate.dateTime(current);
    final day = onDay ?? currentDay;
    final monthStart = HabitDate(current.year, current.month);
    final nextMonth = HabitDate(current.year, current.month + 1);
    final allHobbies = (await db.rawQuery(
      '''SELECT h.* FROM mh_habits h WHERE h.status IN (1,3) OR EXISTS
        (SELECT 1 FROM mh_records r WHERE r.parent_uuid = h.uuid AND r.record_date = ?)
        ORDER BY h.sort_position, h.id_''',
      [day.epochDay],
    )).map(Hobby.fromRow).toList();
    final hobbies = allHobbies.where((h) => h.habit.status != 2).toList();
    final completions = await db.query(
      'hw_checkins',
      where: 'day = ?',
      whereArgs: [day.epochDay],
    );
    final legacyDone = await db.rawQuery(
      '''SELECT r.parent_uuid FROM mh_records r JOIN mh_habits h ON h.uuid = r.parent_uuid WHERE r.record_date = ? AND r.record_type = 1 AND ((h.type_ = 2 AND r.record_value <= h.daily_goal) OR (h.type_ != 2 AND r.record_value >= h.daily_goal))''',
      [day.epochDay],
    );
    final dueIds = <String>{};
    for (final hobby in hobbies) {
      if (day.epochDay <= currentDay.epochDay &&
          await _isDue(
            db,
            hobby,
            day,
            backfill: day.epochDay < currentDay.epochDay,
          )) {
        dueIds.add(hobby.id);
      }
    }
    final dailyNet = <int, int>{
      for (final r in await db.rawQuery(
        """SELECT c.day, SUM(t.amount_minor) AS total FROM hw_checkins c
        JOIN hw_transactions t ON t.source_type = 'CHECK_IN' AND t.source_id = c.id
        GROUP BY c.day""",
      ))
        r['day'] as int: r['total'] as int,
    };
    int sumBetween(int start, int end) => dailyNet.entries
        .where((e) => e.key >= start && e.key < end)
        .fold(0, (sum, e) => sum + e.value);
    final completedIds = legacyDone
        .map((r) => r['parent_uuid'] as String)
        .toSet();
    return HobbyWalletSnapshot(
      groups: List.unmodifiable(
        (await db.query(
          'mh_groups',
          where: 'status = 1',
          orderBy: 'sort_position, id_',
        )).map(GroupDBCell.fromJson),
      ),
      hobbies: List.unmodifiable(hobbies),
      dayHobbies: List.unmodifiable(
        allHobbies.where(
          (h) => dueIds.contains(h.id) || completedIds.contains(h.id),
        ),
      ),
      dailyNetMinor: Map.unmodifiable(dailyNet),
      recent14NetMinor: sumBetween(
        currentDay.epochDay - 13,
        currentDay.epochDay + 1,
      ),
      transactions: List.unmodifiable(
        (await db.query(
          'hw_transactions',
          orderBy: 'timestamp DESC, id DESC',
          limit: 200,
        )).map(WalletTransaction.fromRow),
      ),
      wishes: List.unmodifiable(
        (await db.query(
          'hw_wishlist',
          orderBy: 'is_primary DESC, created_at DESC',
        )).map(WishlistItem.fromRow),
      ),
      redemptions: List.unmodifiable(
        (await db.query(
          'hw_redemptions',
          orderBy: 'timestamp DESC',
        )).map(WishlistRedemption.fromRow),
      ),
      dayCompletions: Map.unmodifiable({
        for (final c in completions)
          c['habit_uuid'] as String: c['reward_minor'] as int,
      }),
      balanceMinor: await _balance(db),
      day: day,
      dueIds: Set.unmodifiable(dueIds),
      completedIds: Set.unmodifiable(
        legacyDone.map((r) => r['parent_uuid'] as String),
      ),
      dayNetMinor: completions.fold(
        0,
        (sum, c) => sum + (c['reward_minor'] as int),
      ),
      monthEarnedMinor: sumBetween(monthStart.epochDay, nextMonth.epochDay),
    );
  });

  /// Existing frequency quotas are preserved. Custom periods are anchored to
  /// the original start date; weekly periods start on Monday.
  Future<bool> _isDue(
    DatabaseExecutor db,
    Hobby hobby,
    HabitDate day, {
    bool backfill = false,
  }) async {
    if (hobby.habit.status != HabitStatus.activated.dbCode ||
        hobby.weekdayMask & (1 << (day.weekday - 1)) == 0 ||
        (!backfill && day.epochDay < hobby.habit.startDate!)) {
      return false;
    }
    final frequency = hobby.frequency;
    if (frequency.isDaily) return true;
    final HabitDate start;
    final HabitDate end;
    switch (frequency.type) {
      case HabitFrequencyType.weekly:
        start = day.subtractDays(day.weekday - 1);
        end = start.addDays(7);
      case HabitFrequencyType.monthly:
        start = HabitDate(day.year, day.month);
        end = HabitDate(day.year, day.month + 1);
      case HabitFrequencyType.custom:
        final days = frequency.days;
        start = day.subtractDays(
          (day.epochDay - hobby.habit.startDate!) % days,
        );
        end = start.addDays(days);
      case HabitFrequencyType.unknown:
        return false;
    }
    final rows = await db.rawQuery(
      """SELECT COUNT(DISTINCT record_date) AS n FROM mh_records
      WHERE parent_uuid = ? AND record_date >= ? AND record_date < ?
      AND record_type = 1 AND record_value ${hobby.habit.type == 2 ? '<=' : '>='} ?""",
      [hobby.id, start.epochDay, end.epochDay, hobby.habit.dailyGoal],
    );
    return (rows.single['n'] as int) < frequency.freq;
  }

  Future<bool> isDueOn(Hobby hobby, HabitDate day) =>
      _db.transaction((db) => _isDue(db, hobby, day));

  /// Read-only upcoming widget rows reuse the same schedule/quota rules.
  Future<List<Hobby>> widgetHobbiesOn(HabitDate day) =>
      _db.transaction((db) async {
        final result = <Hobby>[];
        for (final row in await db.query(
          'mh_habits',
          where: 'status = 1',
          orderBy: 'sort_position, id_',
        )) {
          final hobby = Hobby.fromRow(row);
          if (await _isDue(db, hobby, day)) result.add(hobby);
          if (result.length == 3) break;
        }
        return result;
      });

  Future<String> saveHobby({
    String? id,
    String? groupId,
    required String name,
    required String emoji,
    required String description,
    required int durationMinutes,
    required int rewardMinor,
    required int weekdayMask,
    required HabitFrequency frequency,
    HabitReminder? reminder,
  }) async {
    if (name.trim().isEmpty ||
        name.trim().length > 100 ||
        emoji.isEmpty ||
        emoji.length > 32 ||
        description.length > 2000 ||
        durationMinutes < 1 ||
        durationMinutes > 1440 ||
        rewardMinor.abs() > RewardMoney.maxMinor ||
        weekdayMask < 1 ||
        weekdayMask > 127 ||
        frequency.freq < 1 ||
        (frequency.type == HabitFrequencyType.weekly && frequency.freq > 7) ||
        (frequency.type == HabitFrequencyType.monthly && frequency.freq > 31) ||
        (frequency.type == HabitFrequencyType.custom &&
            (frequency.days < frequency.freq || frequency.days > 365))) {
      throw const WalletException(WalletFailure.invalidInput);
    }
    final uuid = id ?? const Uuid().v4();
    await _db.transaction((db) async {
      if (groupId != null &&
          (await db.query(
            'mh_groups',
            columns: ['uuid'],
            where: 'uuid = ? AND status = 1',
            whereArgs: [groupId],
          )).isEmpty) {
        throw const WalletException(WalletFailure.invalidInput);
      }
      final values = <String, Object?>{
        'group_id': groupId,
        'name': name.trim(),
        'desc': description.trim(),
        'hobby_emoji': emoji,
        'duration_minutes': durationMinutes,
        'reward_minor': rewardMinor,
        'weekday_mask': weekdayMask,
        'freq_type': frequency.type.dbCode,
        'remind_cutsom': reminder == null
            ? null
            : jsonEncode(reminder.toJson()),
        'freq_custom': jsonEncode(frequency.toJson()['args']),
      };
      if (id == null) {
        await db.insert('mh_habits', {
          ...values,
          'uuid': uuid,
          'type_': 1,
          'status': 1,
          'daily_goal': 1,
          'daily_goal_unit': '',
          'color': 1,
          'start_date': today.epochDay,
          'target_days': 66,
          'create_t': now().millisecondsSinceEpoch ~/ 1000,
        });
        await db.insert('mh_sync', {
          'habit_uuid': uuid,
          'dirty': 1,
          'dirty_total': 1,
        });
      } else {
        if (await db.update(
              'mh_habits',
              values,
              where: 'uuid = ? AND status != 2',
              whereArgs: [uuid],
            ) !=
            1) {
          throw const WalletException(WalletFailure.missingHobby);
        }
      }
    });
    return uuid;
  }

  Future<String> saveGroup({String? id, required String name}) async {
    if (name.trim().isEmpty || name.trim().length > 100) {
      throw const WalletException(WalletFailure.invalidInput);
    }
    final uuid = id ?? const Uuid().v4();
    await _db.transaction((db) async {
      if (id == null) {
        await db.insert('mh_groups', {
          'uuid': uuid,
          'name': name.trim(),
          'status': 1,
        });
        await db.insert('mh_sync', {
          'group_uuid': uuid,
          'dirty': 1,
          'dirty_total': 1,
        });
      } else {
        if (await db.update(
              'mh_groups',
              {'name': name.trim()},
              where: 'uuid = ? AND status = 1',
              whereArgs: [id],
            ) !=
            1) {
          throw const WalletException(WalletFailure.invalidInput);
        }
        await _markGroupDirty(db, uuid);
      }
    });
    return uuid;
  }

  Future<void> deleteGroup(String id) => _db.transaction((db) async {
    if (await db.update(
          'mh_groups',
          {'status': 2},
          where: 'uuid = ? AND status = 1',
          whereArgs: [id],
        ) !=
        1) {
      return;
    }
    await _markGroupDirty(db, id);
    await db.rawUpdate(
      'UPDATE mh_sync SET dirty = dirty + 1, dirty_total = dirty_total + 1 WHERE habit_uuid IN (SELECT uuid FROM mh_habits WHERE group_id = ?)',
      [id],
    );
    await db.update(
      'mh_habits',
      {'group_id': null},
      where: 'group_id = ?',
      whereArgs: [id],
    );
  });

  Future<void> _markGroupDirty(DatabaseExecutor db, String id) => db.rawUpdate(
    'UPDATE mh_sync SET dirty = dirty + 1, dirty_total = dirty_total + 1 WHERE group_uuid = ?',
    [id],
  );

  /// Replaces only the slots occupied by the visible subset. Hidden/archived
  /// hobbies keep their relative positions when a category is reordered.
  Future<void> reorderHobbies(List<String> orderedIds) =>
      _reorder('mh_habits', orderedIds);
  Future<void> reorderGroups(List<String> orderedIds) =>
      _reorder('mh_groups', orderedIds);

  Future<void> _reorder(
    String table,
    List<String> orderedIds,
  ) => _db.transaction((db) async {
    final selected = orderedIds.toSet();
    final rows = await db.query(
      table,
      columns: ['uuid'],
      where: table == 'mh_habits' ? 'status IN (1,3)' : 'status = 1',
      orderBy: 'sort_position, id_',
    );
    final all = rows.map((r) => r['uuid'] as String).toList();
    if (selected.length != orderedIds.length ||
        !all.toSet().containsAll(selected)) {
      throw const WalletException(WalletFailure.invalidInput);
    }
    var next = 0;
    final reordered = [
      for (final id in all) selected.contains(id) ? orderedIds[next++] : id,
    ];
    for (var i = 0; i < reordered.length; i++) {
      await db.update(
        table,
        {'sort_position': i.toDouble()},
        where: 'uuid = ?',
        whereArgs: [reordered[i]],
      );
      final key = table == 'mh_habits' ? 'habit_uuid' : 'group_uuid';
      await db.rawUpdate(
        'UPDATE mh_sync SET dirty = dirty + 1, dirty_total = dirty_total + 1 WHERE $key = ?',
        [reordered[i]],
      );
    }
  });

  Future<void> setHobbyStatus(String id, HabitStatus status) async {
    if (!{
      HabitStatus.activated,
      HabitStatus.archived,
      HabitStatus.deleted,
    }.contains(status)) {
      throw const WalletException(WalletFailure.invalidInput);
    }
    if (await _db.update(
          'mh_habits',
          {'status': status.dbCode},
          where: 'uuid = ?',
          whereArgs: [id],
        ) !=
        1) {
      throw const WalletException(WalletFailure.missingHobby);
    }
  }

  /// Returns the reward only for a new completion. Duplicate taps return null.
  Future<int?> complete(String hobbyId, {HabitDate? onDay}) => _db.transaction((
    db,
  ) async {
    final day = onDay ?? today;
    if (day.epochDay > today.epochDay || day.year < 1900) {
      throw const WalletException(WalletFailure.invalidInput);
    }
    final id = genRecordUUID(hobbyId, day.epochDay);
    if ((await db.query(
      'hw_checkins',
      where: 'id = ?',
      whereArgs: [id],
    )).isNotEmpty) {
      return null;
    }
    final rows = await db.query(
      'mh_habits',
      where: 'uuid = ? AND status = 1',
      whereArgs: [hobbyId],
    );
    if (rows.isEmpty) {
      throw const WalletException(WalletFailure.missingHobby);
    }
    final hobby = Hobby.fromRow(rows.single);
    if (!await _isDue(
      db,
      hobby,
      day,
      backfill: day.epochDay < today.epochDay,
    )) {
      throw const WalletException(WalletFailure.invalidInput);
    }
    await _checkBalanceRange(db, hobby.rewardMinor);
    final previous = await db.query(
      'mh_records',
      where: 'parent_uuid = ? AND record_date = ?',
      whereArgs: [hobbyId, day.epochDay],
    );
    // A historical/legacy completion is not a second opportunity to earn.
    if (previous.any(
      (r) =>
          r['record_type'] == 1 &&
          (hobby.habit.type == 2
              ? (r['record_value'] as num) <= hobby.habit.dailyGoal!
              : (r['record_value'] as num) >= hobby.habit.dailyGoal!),
    )) {
      return null;
    }
    // Backfill may predate creation. Extend the habit start without changing
    // the phase of an existing custom schedule, then keep original record APIs.
    if (day.epochDay < hobby.habit.startDate!) {
      final f = hobby.frequency;
      final start = f.type == HabitFrequencyType.custom && !f.isDaily
          ? day.subtractDays((day.epochDay - hobby.habit.startDate!) % f.days)
          : day;
      await db.update(
        'mh_habits',
        {'start_date': start.epochDay},
        where: 'uuid = ?',
        whereArgs: [hobbyId],
      );
    }
    final recordId = previous.isEmpty ? id : previous.single['uuid'] as String;
    final completionValue = hobby.habit.type == 2 ? 0 : hobby.habit.dailyGoal!;
    final stamp = now().millisecondsSinceEpoch;
    if (previous.isEmpty) {
      await db.insert('mh_records', {
        'uuid': recordId,
        'parent_uuid': hobbyId,
        'parent_id': hobby.habit.id,
        'record_date': day.epochDay,
        'record_type': 1,
        'record_value': completionValue,
        'create_t': stamp ~/ 1000,
      });
      await db.insert('mh_sync', {'record_uuid': recordId, 'dirty': 1});
    } else {
      await db.update(
        'mh_records',
        {'record_type': 1, 'record_value': completionValue},
        where: 'uuid = ?',
        whereArgs: [recordId],
      );
    }
    await db.insert('hw_checkins', {
      'id': id,
      'habit_uuid': hobbyId,
      'day': day.epochDay,
      'record_uuid': recordId,
      'reward_minor': hobby.rewardMinor,
      'completed_at': stamp,
      'completion_value': completionValue,
      'previous_record': previous.isEmpty ? null : jsonEncode(previous.single),
    });
    await db.insert('hw_transactions', {
      'id': 'earn:$id',
      'amount_minor': hobby.rewardMinor,
      'type': 'EARN',
      'source_type': 'CHECK_IN',
      'source_id': id,
      'title': hobby.name,
      // Ledger date follows the selected day; completed_at retains entry time.
      'timestamp': day == today
          ? stamp
          : DateTime(day.year, day.month, day.day, 12).millisecondsSinceEpoch,
    });
    return hobby.rewardMinor;
  });

  /// Undo is keyed to the original local day, including a snackbar tapped after
  /// midnight. It restores a partial legacy record, if one existed.
  Future<bool> undo(String hobbyId, HabitDate day) => _db.transaction((
    db,
  ) async {
    final id = genRecordUUID(hobbyId, day.epochDay);
    final rows = await db.query(
      'hw_checkins',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) {
      final records = await db.query(
        'mh_records',
        where: 'parent_uuid = ? AND record_date = ?',
        whereArgs: [hobbyId, day.epochDay],
      );
      if (records.isEmpty) return false;
      final uuid = records.single['uuid'];
      await db.delete('mh_sync', where: 'record_uuid = ?', whereArgs: [uuid]);
      await db.delete('mh_records', where: 'uuid = ?', whereArgs: [uuid]);
      return true;
    }
    final row = rows.single;
    final recordId = row['record_uuid'];
    await _checkBalanceRange(db, -(row['reward_minor'] as int));
    await db.delete(
      'hw_transactions',
      where: "source_type = 'CHECK_IN' AND source_id = ?",
      whereArgs: [id],
    );
    await db.delete('hw_checkins', where: 'id = ?', whereArgs: [id]);
    if (row['previous_record'] == null) {
      await db.delete(
        'mh_sync',
        where: 'record_uuid = ?',
        whereArgs: [recordId],
      );
      await db.delete('mh_records', where: 'uuid = ?', whereArgs: [recordId]);
    } else {
      final previous = Map<String, Object?>.from(
        jsonDecode(row['previous_record'] as String) as Map,
      );
      await db.update(
        'mh_records',
        previous,
        where: 'uuid = ?',
        whereArgs: [recordId],
      );
    }
    return true;
  });

  /// Request ID makes retries idempotent; every genuine adjustment uses a new ID.
  Future<bool> adjust({
    required String requestId,
    required int amountMinor,
    required String title,
  }) => _db.transaction((db) async {
    if (requestId.isEmpty ||
        amountMinor == 0 ||
        amountMinor.abs() > RewardMoney.maxMinor ||
        title.trim().isEmpty ||
        title.length > 100) {
      throw const WalletException(WalletFailure.invalidInput);
    }
    if ((await db.query(
      'hw_transactions',
      where: "source_type = 'MANUAL' AND source_id = ?",
      whereArgs: [requestId],
    )).isNotEmpty) {
      return false;
    }
    await _checkBalanceRange(db, amountMinor);
    await db.insert('hw_transactions', {
      'id': 'adjust:$requestId',
      'amount_minor': amountMinor,
      'type': 'ADJUSTMENT',
      'source_type': 'MANUAL',
      'source_id': requestId,
      'title': title.trim(),
      'timestamp': now().millisecondsSinceEpoch,
    });
    return true;
  });

  Future<String> saveWish({
    String? id,
    required String name,
    required int targetPriceMinor,
    required String emoji,
    required String note,
    bool isPrimary = false,
  }) async {
    if (name.trim().isEmpty ||
        name.length > 100 ||
        targetPriceMinor < 1 ||
        targetPriceMinor > RewardMoney.maxMinor ||
        emoji.isEmpty ||
        emoji.length > 32 ||
        note.length > 2000) {
      throw const WalletException(WalletFailure.invalidInput);
    }
    final uuid = id ?? const Uuid().v4();
    await _db.transaction((db) async {
      if (id != null) {
        final rows = await db.query(
          'hw_wishlist',
          where: 'id = ?',
          whereArgs: [id],
        );
        if (rows.isEmpty) {
          throw const WalletException(WalletFailure.missingWish);
        }
        if (rows.single['status'] != 'active') {
          throw const WalletException(WalletFailure.alreadyRedeemed);
        }
      }
      if (isPrimary) await db.update('hw_wishlist', {'is_primary': 0});
      final values = {
        'name': name.trim(),
        'target_price_minor': targetPriceMinor,
        'emoji': emoji,
        'note': note.trim(),
        'is_primary': isPrimary ? 1 : 0,
      };
      if (id == null) {
        await db.insert('hw_wishlist', {
          ...values,
          'id': uuid,
          'created_at': now().millisecondsSinceEpoch,
        });
      } else {
        await db.update(
          'hw_wishlist',
          values,
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
    return uuid;
  }

  Future<void> deleteWish(String id) async {
    if (await _db.delete(
          'hw_wishlist',
          where: "id = ? AND status = 'active'",
          whereArgs: [id],
        ) !=
        1) {
      throw const WalletException(WalletFailure.missingWish);
    }
  }

  Future<void> redeem(String id) => _db.transaction((db) async {
    final rows = await db.query(
      'hw_wishlist',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) throw const WalletException(WalletFailure.missingWish);
    final wish = WishlistItem.fromRow(rows.single);
    if (wish.status == WishlistStatus.redeemed) {
      throw const WalletException(WalletFailure.alreadyRedeemed);
    }
    if (await _balance(db) < wish.targetPriceMinor) {
      throw const WalletException(WalletFailure.insufficientBalance);
    }
    final stamp = now().millisecondsSinceEpoch;
    await db.insert('hw_transactions', {
      'id': 'spend:$id',
      'amount_minor': -wish.targetPriceMinor,
      'type': 'SPEND',
      'source_type': 'WISHLIST',
      'source_id': id,
      'title': wish.name,
      'timestamp': stamp,
    });
    await db.insert('hw_redemptions', {
      'id': id,
      'wishlist_id': id,
      'transaction_id': 'spend:$id',
      'amount_minor': wish.targetPriceMinor,
      'title': wish.name,
      'timestamp': stamp,
    });
    await db.update(
      'hw_wishlist',
      {'status': 'redeemed', 'is_primary': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  });
}
