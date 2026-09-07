// Copyright 2026 Hobby Wallet contributors
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../common/utils.dart';
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

  Future<HobbyWalletSnapshot> load() => _db.transaction((db) async {
    final current = now();
    final day = HabitDate.dateTime(current);
    final monthStart = DateTime(
      current.year,
      current.month,
    ).millisecondsSinceEpoch;
    final nextMonth = DateTime(
      current.year,
      current.month + 1,
    ).millisecondsSinceEpoch;
    final hobbies = (await db.query(
      'mh_habits',
      where: 'status IN (1,3)',
      orderBy: 'status, sort_position, id_',
    )).map(Hobby.fromRow).toList();
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
      if (await _isDue(db, hobby, day)) dueIds.add(hobby.id);
    }
    final earned =
        (await db.rawQuery(
              "SELECT COALESCE(SUM(amount_minor),0) AS total FROM hw_transactions WHERE type = 'EARN' AND timestamp >= ? AND timestamp < ?",
              [monthStart, nextMonth],
            )).single['total']
            as int;
    return HobbyWalletSnapshot(
      hobbies: List.unmodifiable(hobbies),
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
      todayCompletions: Map.unmodifiable({
        for (final c in completions)
          c['habit_uuid'] as String: c['reward_minor'] as int,
      }),
      balanceMinor: await _balance(db),
      day: day,
      dueIds: Set.unmodifiable(dueIds),
      completedIds: Set.unmodifiable(
        legacyDone.map((r) => r['parent_uuid'] as String),
      ),
      todayEarnedMinor: completions.fold(
        0,
        (sum, c) => sum + (c['reward_minor'] as int),
      ),
      monthEarnedMinor: earned,
    );
  });

  /// Existing frequency quotas are preserved. Custom periods are anchored to
  /// the original start date; weekly periods start on Monday.
  Future<bool> _isDue(DatabaseExecutor db, Hobby hobby, HabitDate day) async {
    if (!hobby.isScheduled(day)) return false;
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

  Future<String> saveHobby({
    String? id,
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
        rewardMinor < 0 ||
        rewardMinor > RewardMoney.maxMinor ||
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
      final values = <String, Object?>{
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
  Future<int?> complete(String hobbyId) => _db.transaction((db) async {
    final day = today;
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
    if (!await _isDue(db, hobby, day)) {
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
      'timestamp': stamp,
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
