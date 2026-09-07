// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import '../l10n/localizations.dart';
import '../models/habit_date.dart';
import '../models/habit_reminder.dart';
import '../storage/hobby_wallet_repository.dart';
import '../utils/local_timezone.dart';
import '../utils/reward_money.dart';
import 'notification_channel.dart';
import 'notification_service.dart';

/// Adapts the existing notification scheduler to the wallet's schedule and copy.
/// No background worker, server or new notification stack is introduced.
class WishLoopReminders {
  final HobbyWalletRepository repository;
  final NotificationChannelData channels;
  const WishLoopReminders(this.repository, this.channels);

  Future<void> refresh(L10n l10n) async {
    await LocalTimeZoneManager().updateTimeZone();
    channels.onL10nUpdate(l10n);
    final state = await repository.load();
    final service = NotificationService();
    // Includes reminders left behind by deleted/archived hobbies or an import.
    await service.cancelAllHabitReminders();
    for (final hobby in state.hobbies) {
      final reminder = hobby.reminder;
      if (hobby.archived || reminder == null) continue;
      var cursor = repository.now();
      for (var attempt = 0; attempt < 370; attempt++) {
        final next = reminder.getNextRemindDate(
          crtDate: cursor,
          lastUntrackDate: HabitDate.dateTime(cursor),
        );
        if (next == null) break;
        final day = HabitDate.dateTime(next);
        if (await repository.isDueOn(hobby, day) &&
            !(day == state.day && state.completedIds.contains(hobby.id))) {
          final ok = await service.regrHabitReminder(
            id: hobby.habit.id!,
            uuid: hobby.id,
            name: hobby.name,
            quest: hobby.rewardMinor < 0
                ? l10n.wPenaltyReminder(
                    hobby.name,
                    RewardMoney.format(
                      hobby.rewardMinor.abs(),
                      locale: l10n.localeName,
                    ),
                  )
                : l10n.wReminderBody(
                    hobby.name,
                    RewardMoney.format(
                      hobby.rewardMinor,
                      locale: l10n.localeName,
                    ),
                  ),
            reminder: HabitReminder.daily(time: reminder.time),
            lastUntrackDate: day,
            crtDate: next.subtract(const Duration(seconds: 1)),
            details: channels.habitReminder,
          );
          if (!ok) throw StateError('Unable to schedule hobby reminder');
          break;
        }
        cursor = DateTime(next.year, next.month, next.day + 1);
      }
    }
  }
}
