// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'habit_date.dart';

enum RewardCalendarMode { week, month }

/// Calendar periods use local civil dates, never elapsed 24-hour durations.
class RewardCalendarRange {
  final HabitDate start;
  final HabitDate end; // exclusive
  final RewardCalendarMode mode;
  const RewardCalendarRange._(this.start, this.end, this.mode);

  factory RewardCalendarRange.containing(
    HabitDate day,
    RewardCalendarMode mode,
  ) {
    final start = mode == RewardCalendarMode.week
        ? day.subtractDays(day.weekday - 1)
        : HabitDate(day.year, day.month);
    return RewardCalendarRange._(
      start,
      mode == RewardCalendarMode.week
          ? start.addDays(7)
          : HabitDate(day.year, day.month + 1),
      mode,
    );
  }

  int get length => end.epochDay - start.epochDay;
  Iterable<HabitDate> get days sync* {
    for (var i = 0; i < length; i++) {
      yield start.addDays(i);
    }
  }

  bool contains(HabitDate day) =>
      day.epochDay >= start.epochDay && day.epochDay < end.epochDay;
  RewardCalendarRange shift(int offset) => RewardCalendarRange.containing(
    mode == RewardCalendarMode.week
        ? start.addDays(offset * 7)
        : HabitDate(start.year, start.month + offset),
    mode,
  );
  int net(Map<int, int> values) =>
      days.fold(0, (sum, day) => sum + (values[day.epochDay] ?? 0));
  int maxMagnitude(Map<int, int> values) => days.fold(0, (maximum, day) {
    final magnitude = (values[day.epochDay] ?? 0).abs();
    return magnitude > maximum ? magnitude : maximum;
  });

  /// A shared absolute scale makes positive and negative magnitudes comparable.
  /// Only the currently visible week/month participates in normalization.
  double intensity(HabitDate day, Map<int, int> values) {
    if (!contains(day)) return 0;
    final max = maxMagnitude(values);
    return max == 0 ? 0 : (values[day.epochDay] ?? 0).abs() / max;
  }
}
