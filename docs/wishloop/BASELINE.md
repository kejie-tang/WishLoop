# Baseline — 2026-09-07

Reference: Table Habit, Apache-2.0 (original copyright retained).

- Flutter 3.47.2 / Dart 3.13.2; Provider, sqflite, shared_preferences, Material 3, Flutter ARB localization.
- `flutter pub get`: passed.
- `flutter analyze`: 2 informational curly-braces findings in the pre-existing, uncommitted wallet repository.
- `flutter test`: 1328 passed.
- Android SDK installed; no Android emulator/device initially configured.
- Existing applicationId: `io.github.friesi23.mhabit`.
- Upstream database v8: mh_habits, mh_records, mh_groups, mh_sync. Completion is a mh_records row, keyed by habit UUID and local calendar date. HabitFrequency retains daily/weekly/monthly/custom quotas. Reminders use flutter_local_notifications.
- Existing worktree had uncommitted v9 wallet schema, model, repository, integer money helper and Dart 3.13 great_list_view vendor compatibility patch. These were preserved and extended.
- Existing routes: Habits, Today, habit create/edit/detail/status, settings/about/notifications, plus upstream auxiliary screens. WishLoop reuses bootstrapping, storage, theme, language and reminder services with a focused offline Android entry; upstream pages remain for compatibility and regression tests.
- WishLoop GitHub target already exists as an empty private repository. Preserve its visibility.
