// Copyright 2026 Hobby Wallet contributors
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import '../storage/db/handlers/habit.dart';
import 'habit_date.dart';
import 'habit_form.dart';
import 'habit_freq.dart';
import 'habit_reminder.dart';

enum WalletTransactionType { earn, spend, adjustment }

enum WishlistStatus { active, redeemed }

enum WalletFailure {
  invalidInput,
  missingHobby,
  insufficientBalance,
  alreadyRedeemed,
  missingWish,
}

class WalletException implements Exception {
  final WalletFailure reason;
  const WalletException(this.reason);
  @override
  String toString() => 'WalletException($reason)';
}

/// Wraps the existing habit rather than creating a second habit database.
class Hobby {
  final HabitDBCell habit;
  final String emoji;
  final int rewardMinor;
  final int durationMinutes;
  final int weekdayMask;

  const Hobby({
    required this.habit,
    required this.emoji,
    required this.rewardMinor,
    required this.durationMinutes,
    required this.weekdayMask,
  });

  factory Hobby.fromRow(Map<String, Object?> row) => Hobby(
    habit: HabitDBCell.fromJson(row),
    emoji: row['hobby_emoji'] as String,
    rewardMinor: row['reward_minor'] as int,
    durationMinutes: row['duration_minutes'] as int,
    weekdayMask: row['weekday_mask'] as int,
  );

  String get id => habit.uuid!;
  String get name => habit.name ?? '';
  String get description => habit.desc ?? '';
  HabitReminder? get reminder => habit.remindCustom == null
      ? null
      : HabitReminder.fromJson(
          jsonDecode(habit.remindCustom!) as Map<String, dynamic>,
        );
  bool get archived => habit.status == HabitStatus.archived.dbCode;
  HabitFrequency get frequency =>
      habit.freqType == null || habit.freqCustom == null
      ? HabitFrequency.daily
      : HabitFrequency.fromJson({
          'type': habit.freqType,
          'args': jsonDecode(habit.freqCustom!),
        });

  bool isScheduled(HabitDate day) =>
      !archived &&
      habit.status == HabitStatus.activated.dbCode &&
      day.epochDay >= habit.startDate! &&
      weekdayMask & (1 << (day.weekday - 1)) != 0;
}

class WalletTransaction {
  final String id;
  final int amountMinor;
  final WalletTransactionType type;
  final String sourceType;
  final String sourceId;
  final String title;
  final DateTime timestamp;
  final String currency;

  const WalletTransaction({
    required this.id,
    required this.amountMinor,
    required this.type,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    required this.timestamp,
    required this.currency,
  });

  factory WalletTransaction.fromRow(Map<String, Object?> row) =>
      WalletTransaction(
        id: row['id'] as String,
        amountMinor: row['amount_minor'] as int,
        type: WalletTransactionType.values.byName(
          (row['type'] as String).toLowerCase(),
        ),
        sourceType: row['source_type'] as String,
        sourceId: row['source_id'] as String,
        title: row['title'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
        currency: row['currency'] as String,
      );
}

class WishlistItem {
  final String id;
  final String name;
  final int targetPriceMinor;
  final String emoji;
  final String note;
  final DateTime createdAt;
  final WishlistStatus status;
  final bool isPrimary;

  const WishlistItem({
    required this.id,
    required this.name,
    required this.targetPriceMinor,
    required this.emoji,
    required this.note,
    required this.createdAt,
    this.status = WishlistStatus.active,
    this.isPrimary = false,
  });

  factory WishlistItem.fromRow(Map<String, Object?> row) => WishlistItem(
    id: row['id'] as String,
    name: row['name'] as String,
    targetPriceMinor: row['target_price_minor'] as int,
    emoji: row['emoji'] as String,
    note: row['note'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
    status: WishlistStatus.values.byName(row['status'] as String),
    isPrimary: row['is_primary'] == 1,
  );

  double progress(int balanceMinor) =>
      balanceMinor.clamp(0, targetPriceMinor) / targetPriceMinor;

  /// The fixed trailing window includes today and 13 previous calendar days.
  /// Missing days count as zero. No division or rounding of money into doubles.
  int? estimatedDays(int balanceMinor, int recent14NetMinor) {
    final remaining = targetPriceMinor - balanceMinor;
    if (remaining <= 0) return 0;
    if (recent14NetMinor <= 0) return null;
    return (remaining * 14 + recent14NetMinor - 1) ~/ recent14NetMinor;
  }

  int progressTenths(int balanceMinor) =>
      balanceMinor.clamp(0, targetPriceMinor) * 1000 ~/ targetPriceMinor;
  bool canRedeem(int balanceMinor) =>
      status == WishlistStatus.active && balanceMinor >= targetPriceMinor;
}

class WishlistRedemption {
  final String id;
  final String wishlistId;
  final String transactionId;
  final String title;
  final int amountMinor;
  final DateTime timestamp;

  const WishlistRedemption({
    required this.id,
    required this.wishlistId,
    required this.transactionId,
    required this.title,
    required this.amountMinor,
    required this.timestamp,
  });

  factory WishlistRedemption.fromRow(Map<String, Object?> row) =>
      WishlistRedemption(
        id: row['id'] as String,
        wishlistId: row['wishlist_id'] as String,
        transactionId: row['transaction_id'] as String,
        title: row['title'] as String,
        amountMinor: row['amount_minor'] as int,
        timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
      );
}

class HobbyWalletSnapshot {
  final List<Hobby> hobbies;
  final List<Hobby> dayHobbies;
  final Map<int, int> dailyNetMinor;
  final int recent14NetMinor;
  final List<WalletTransaction> transactions;
  final List<WishlistItem> wishes;
  final List<WishlistRedemption> redemptions;
  final Map<String, int> dayCompletions;
  final HabitDate? day;
  final Set<String> dueIds;
  final Set<String> completedIds;
  final int balanceMinor;
  final int dayNetMinor;
  final int monthEarnedMinor;

  const HobbyWalletSnapshot({
    this.hobbies = const [],
    this.dayHobbies = const [],
    this.dailyNetMinor = const {},
    this.recent14NetMinor = 0,
    this.transactions = const [],
    this.wishes = const [],
    this.redemptions = const [],
    this.dayCompletions = const {},
    this.day,
    this.dueIds = const {},
    this.completedIds = const {},
    this.balanceMinor = 0,
    this.dayNetMinor = 0,
    this.monthEarnedMinor = 0,
  });
}
