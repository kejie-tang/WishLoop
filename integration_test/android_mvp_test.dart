import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mhabit/main.dart' as app;
import 'package:mhabit/models/reward_calendar.dart';
import 'package:mhabit/pages/wishloop/home.dart';
import 'package:mhabit/providers/app_ui/app_theme.dart';
import 'package:mhabit/providers/wishloop/wallet_controller.dart';
import 'package:mhabit/reminders/notification_channel.dart';
import 'package:mhabit/reminders/notification_data.dart';
import 'package:mhabit/reminders/notification_service.dart';
import 'package:mhabit/storage/db_helper_provider.dart';
import 'package:mhabit/storage/wishloop_backup.dart';
import 'package:mhabit/theme/color.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android: edit, earn, undo, redeem, persist, backup, theme, notify',
    (tester) async {
      final errorHandler = FlutterError.onError;
      final dispatcher = WidgetsBinding.instance.platformDispatcher;
      final platformErrorHandler = dispatcher.onError;
      try {
        await app.main();
      } finally {
        FlutterError.onError = errorHandler;
        dispatcher.onError = platformErrorHandler;
      }
      Future<void> waitFor(bool Function() ready) async {
        for (var i = 0; i < 200 && !ready(); i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(ready(), isTrue);
        await tester.pump(const Duration(milliseconds: 500));
      }

      Future<void> tapInView(Finder finder) async {
        // Wait for the Android keyboard to finish resizing the viewport before
        // positioning a lazily built ListView child.
        await tester.pump(const Duration(milliseconds: 500));
        if (finder.evaluate().isEmpty) {
          await tester.scrollUntilVisible(
            finder,
            250,
            scrollable: find.byType(Scrollable).first,
          );
        }
        // The live test clock can leave a previous screen's floating feedback
        // over a bottom form button. Dismiss it before the next UI action.
        ScaffoldMessenger.maybeOf(tester.element(finder))?.clearSnackBars();
        await tester.pump(const Duration(milliseconds: 500));
        await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
        await tester.pump(const Duration(milliseconds: 500));
        await tester.tap(finder);
        await tester.pump(const Duration(milliseconds: 500));
      }

      await waitFor(() => find.byType(WishLoopHome).evaluate().isNotEmpty);
      final context = tester.element(find.byType(WishLoopHome));
      final vm = context.read<WalletController>();
      await waitFor(() => !vm.loading);
      // Run this test only on the dedicated clean WishLoop emulator.
      expect(vm.snapshot.hobbies, isEmpty);
      expect(find.text('奖励日历'), findsOneWidget);
      debugPrint('MVP: launch ready');
      await tapInView(find.text('添加兴趣').first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.enterText(find.byKey(const ValueKey('hobby-name')), '跑步');
      await tester.enterText(
        find.byKey(const ValueKey('hobby-reward')),
        '5.00',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('save-hobby')),
        450,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('save-hobby')));
      await tester.pump(const Duration(milliseconds: 500));
      await waitFor(() => vm.snapshot.hobbies.isNotEmpty && !vm.busy);
      debugPrint('MVP: hobby saved');
      expect(vm.snapshot.hobbies.single.name, '跑步');
      final hobby = vm.snapshot.hobbies.single.id;
      await tester.tap(find.byType(NavigationDestination).at(3));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('添加愿望').first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.enterText(find.byKey(const ValueKey('wish-name')), '一本喜欢的书');
      await tester.enterText(find.byKey(const ValueKey('wish-price')), '5.00');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.ensureVisible(find.byKey(const ValueKey('save-wish')));
      await tester.tap(find.byKey(const ValueKey('save-wish')));
      await tester.pump(const Duration(milliseconds: 500));
      await waitFor(() => vm.snapshot.wishes.isNotEmpty && !vm.busy);
      debugPrint('MVP: wish saved');
      final wish = vm.snapshot.wishes.single.id;
      expect(
        tester
            .widget<FilledButton>(find.byKey(ValueKey('redeem-$wish')))
            .onPressed,
        isNull,
      );
      await tester.tap(find.byType(NavigationDestination).at(0));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.scrollUntilVisible(
        find.byKey(ValueKey('complete-$hobby')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tapInView(find.byKey(ValueKey('complete-$hobby')));
      await tester.pump(const Duration(milliseconds: 500));
      await waitFor(() => !vm.busy && vm.snapshot.balanceMinor == 500);
      expect(vm.snapshot.balanceMinor, 500);
      await tapInView(find.byKey(ValueKey('undo-$hobby')));
      await tester.pump(const Duration(milliseconds: 500));
      await waitFor(() => !vm.busy && vm.snapshot.balanceMinor == 0);
      expect(vm.snapshot.balanceMinor, 0);
      await tapInView(find.byKey(ValueKey('complete-$hobby')));
      await tester.pump(const Duration(milliseconds: 500));
      await waitFor(() => !vm.busy && vm.snapshot.balanceMinor == 500);
      expect(vm.snapshot.balanceMinor, 500);
      await tester.tap(find.byType(NavigationDestination).at(3));
      await tester.pump(const Duration(milliseconds: 500));
      await tapInView(find.byKey(ValueKey('redeem-$wish')));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('确认兑换'));
      await tester.pump(const Duration(milliseconds: 500));
      await waitFor(() => !vm.busy && vm.snapshot.balanceMinor == 0);
      expect(vm.snapshot.balanceMinor, 0);
      debugPrint('MVP: earn / undo / redeem passed');
      expect(vm.snapshot.redemptions.length, 1);
      final db = context.read<DBHelperViewModel>().local.db;
      final backup = WishLoopBackup(db);
      final saved = await backup.exportData();
      await vm.repository.adjust(
        requestId: 'integration-adjust',
        amountMinor: 12345,
        title: '之前的积累',
      );
      await backup.restore(saved);
      await vm.refresh();
      await tester.pump(const Duration(milliseconds: 500));
      await waitFor(() => !vm.busy && vm.snapshot.balanceMinor == 0);
      expect(vm.snapshot.balanceMinor, 0);
      expect((await db.query('hw_transactions')).length, 2);
      await tester.tap(find.byType(NavigationDestination).at(1));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('添加兴趣'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.enterText(find.byKey(const ValueKey('hobby-name')), '熬夜');
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('hobby-reward')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
        find.byKey(const ValueKey('hobby-reward')),
        '-3.456',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: find.byKey(const ValueKey('hobby-reward')),
                matching: find.byType(EditableText),
              ),
            )
            .controller
            .text,
        '-3.46',
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('save-hobby')),
        350,
        scrollable: find.byType(Scrollable).first,
      );
      await tapInView(find.byKey(const ValueKey('save-hobby')));
      await waitFor(() => !vm.busy && vm.snapshot.hobbies.length == 2);
      final bad = vm.snapshot.hobbies.firstWhere((h) => h.rewardMinor < 0).id;
      await tester.tap(find.byType(NavigationDestination).at(0));
      await tester.pump(const Duration(milliseconds: 500));
      await Scrollable.ensureVisible(
        tester.element(find.byKey(const ValueKey('calendar-mode'))),
        alignment: 0.5,
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.drag(
        find.byKey(const ValueKey('calendar-period')),
        const Offset(0, 90),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        tester
            .widget<SegmentedButton<RewardCalendarMode>>(
              find.byKey(const ValueKey('calendar-mode')),
            )
            .selected,
        {RewardCalendarMode.month},
      );
      final previousDay = vm.repository.today.subtractDays(1);
      if (previousDay.month != vm.repository.today.month) {
        await tapInView(find.byKey(const ValueKey('calendar-previous')));
        await waitFor(
          () => !vm.busy && vm.snapshot.day!.month == previousDay.month,
        );
      }
      await tapInView(
        find.byKey(ValueKey('calendar-day-${previousDay.epochDay}')),
      );
      await waitFor(() => !vm.busy && vm.snapshot.day == previousDay);
      await tester.scrollUntilVisible(
        find.byKey(ValueKey('complete-$bad')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tapInView(find.byKey(ValueKey('complete-$bad')));
      await waitFor(() => !vm.busy && vm.snapshot.balanceMinor == -346);
      expect(vm.snapshot.dailyNetMinor[previousDay.epochDay], -346);
      await tapInView(find.byKey(ValueKey('undo-$bad')));
      await waitFor(() => !vm.busy && vm.snapshot.balanceMinor == 0);
      await Scrollable.ensureVisible(
        tester.element(find.byKey(const ValueKey('calendar-mode'))),
        alignment: 0.5,
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.drag(
        find.byKey(const ValueKey('calendar-period')),
        const Offset(150, 0),
      );
      await waitFor(
        () => !vm.busy && vm.snapshot.day!.month != previousDay.month,
      );
      await tapInView(find.byKey(const ValueKey('calendar-today')));
      await waitFor(() => !vm.busy && vm.snapshot.day == vm.repository.today);
      debugPrint('MVP: negative rounding / calendar / backfill / undo passed');
      // Mixed gains/losses exercise the real 14-day forecast and heatmap data.
      for (var offset = 1; offset <= 6; offset++) {
        final day = vm.repository.today.subtractDays(offset);
        if ({2, 3, 5, 6}.contains(offset)) {
          await vm.repository.complete(hobby, onDay: day);
        }
        if ({1, 2, 4, 6}.contains(offset)) {
          await vm.repository.complete(bad, onDay: day);
        }
      }
      await vm.repository.saveWish(
        name: '新书奖励',
        targetPriceMinor: 5000,
        emoji: '📚',
        note: '',
        isPrimary: true,
      );
      await vm.refresh();
      await tester.pump(const Duration(milliseconds: 500));
      expect(vm.snapshot.balanceMinor, 616);
      expect(vm.snapshot.recent14NetMinor, 1116);
      await tester.tap(find.byType(NavigationDestination).at(3));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('预计还要 55 天'), findsOneWidget);
      debugPrint('MVP: mixed-sign 14-day forecast = 55 days');

      await context.read<AppThemeViewModel>().setNewthemeType(
        AppThemeType.dark,
      );
      await tester.pump(const Duration(milliseconds: 500));
      await waitFor(
        () =>
            Theme.of(tester.element(find.byType(WishLoopHome))).brightness ==
            Brightness.dark,
      );
      expect(
        Theme.of(tester.element(find.byType(WishLoopHome))).brightness,
        Brightness.dark,
      );
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.byType(NavigationDestination).at(i));
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      }
      await context.read<AppThemeViewModel>().setNewthemeType(
        AppThemeType.light,
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byKey(const ValueKey('settings')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('CNY ¥ · 虚拟记账单位'), findsOneWidget);
      // Permission is granted with adb before the test; inspect the real service.
      final service = NotificationService();
      expect(
        await service.show(
          id: 1900000001,
          title: 'WishLoop',
          body: 'Android notification verification',
          type: NotificationDataType.appReminder,
          channelId: NotificationChannelId.appReminder,
          details: context.read<NotificationChannelData>().appReminder,
        ),
        isTrue,
      );
      expect(
        (await service.getActiveNotifications()).any((n) => n.id == 1900000001),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
