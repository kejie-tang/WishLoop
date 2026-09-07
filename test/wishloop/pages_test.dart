import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/reward_calendar.dart';
import 'package:mhabit/pages/wishloop/editors.dart';
import 'package:mhabit/pages/wishloop/home.dart';
import 'package:mhabit/providers/wishloop/wallet_controller.dart';
import 'package:mhabit/storage/db/db_helper.dart';
import 'package:mhabit/storage/hobby_wallet_repository.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DBHelper helper;
  late WalletController vm;
  late String hobby, wish;
  setUp(() async {
    final dbPath = await databaseFactory.getDatabasesPath();
    databaseFactory = databaseFactoryFfiNoIsolate;
    await databaseFactory.setDatabasesPath(dbPath);
    helper = DBHelper();
    await helper.init();
    final repo = HobbyWalletRepository(
      helper.db,
      clock: () => DateTime(2026, 9, 7),
    );
    hobby = await repo.saveHobby(
      name: '跑步',
      emoji: '🏃',
      description: '公园',
      durationMinutes: 30,
      rewardMinor: 500,
      weekdayMask: 127,
      frequency: HabitFrequency.daily,
    );
    wish = await repo.saveWish(
      name: '一本书',
      targetPriceMinor: 500,
      emoji: '📚',
      note: '',
      isPrimary: true,
    );
    vm = WalletController(repo);
    await vm.refresh();
  });
  tearDown(() async {
    vm.dispose();
    await helper.db.close();
  });
  Future<void> pump(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
    Locale locale = const Locale('zh'),
    double scale = 1,
  }) async {
    tester.view.physicalSize = const Size(400, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: MaterialApp(
          locale: locale,
          supportedLocales: appSupportedLocales,
          localizationsDelegates: appLocalizationsDelegates,
          theme: ThemeData(colorSchemeSeed: const Color(0xFF8A5944)),
          darkTheme: ThemeData(brightness: Brightness.dark),
          themeMode: themeMode,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const WishLoopHome(enableReminders: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tab(WidgetTester tester, int index) async {
    await tester.tap(find.byType(NavigationDestination).at(index));
    await tester.pumpAndSettle();
  }

  Future<void> commandTap(WidgetTester tester, Finder finder) async {
    await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
    expect(vm.busy, isFalse);
  }

  for (final theme in ThemeMode.values.where((t) => t != ThemeMode.system)) {
    testWidgets('four pages render in Chinese ${theme.name}', (tester) async {
      await pump(tester, themeMode: theme);
      expect(find.text('奖励日历'), findsOneWidget);
      await tester.drag(
        find.byKey(const ValueKey('reward-calendar-gesture')),
        const Offset(0, 90),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tab(tester, 1);
      expect(find.text('添加兴趣'), findsOneWidget);
      await tab(tester, 2);
      expect(find.text('调整余额'), findsOneWidget);
      await tab(tester, 3);
      expect(find.text('添加愿望'), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.byKey(ValueKey('redeem-$wish')),
      );
      expect(button.onPressed, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('complete, undo, complete and redeem refresh visible balance', (
    tester,
  ) async {
    await pump(tester);
    await tester.scrollUntilVisible(
      find.byKey(ValueKey('complete-$hobby')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await commandTap(tester, find.byKey(ValueKey('complete-$hobby')));
    expect(vm.snapshot.balanceMinor, 500);
    await commandTap(
      tester,
      find.descendant(of: find.byType(SnackBar), matching: find.text('撤销')),
    );
    expect(vm.snapshot.balanceMinor, 0);
    await commandTap(tester, find.byKey(ValueKey('complete-$hobby')));
    expect(vm.snapshot.balanceMinor, 500);
    // Exercise actual timer behavior: an action SnackBar otherwise persists
    // indefinitely in Material 3 even when its duration has elapsed.
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    await commandTap(tester, find.byKey(ValueKey('undo-$hobby')));
    expect(vm.snapshot.balanceMinor, 0);
    await commandTap(tester, find.byKey(ValueKey('complete-$hobby')));
    await tab(tester, 3);
    await tester.tap(find.byKey(ValueKey('redeem-$wish')));
    await tester.pumpAndSettle();
    expect(find.text('确认兑换'), findsOneWidget);
    await commandTap(tester, find.text('确认兑换'));
    expect(vm.snapshot.balanceMinor, 0);
    expect(vm.snapshot.redemptions.length, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('English localization and large text have no layout exceptions', (
    tester,
  ) async {
    await pump(tester, locale: const Locale('en'), scale: 1.6);
    await tester.drag(
      find.byKey(const ValueKey('reward-calendar-gesture')),
      const Offset(0, 90),
    );
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tab(tester, i);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'calendar swipes week/month, navigates dates, backfills and undoes',
    (tester) async {
      await pump(tester);
      final today = vm.repository.today;
      final gesture = find.byKey(const ValueKey('reward-calendar-gesture'));
      await tester.drag(gesture, const Offset(0, 90));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SegmentedButton<RewardCalendarMode>>(
              find.byKey(const ValueKey('calendar-mode')),
            )
            .selected,
        {RewardCalendarMode.month},
      );
      final previous = today.subtractDays(1);
      await tester.tap(
        find.byKey(ValueKey('calendar-day-${previous.epochDay}')),
      );
      await tester.pumpAndSettle();
      expect(vm.snapshot.day, previous);
      await tester.scrollUntilVisible(
        find.byKey(ValueKey('complete-$hobby')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await commandTap(tester, find.byKey(ValueKey('complete-$hobby')));
      expect(vm.snapshot.balanceMinor, 500);
      expect(vm.snapshot.dailyNetMinor[previous.epochDay], 500);
      await commandTap(tester, find.byKey(ValueKey('undo-$hobby')));
      expect(vm.snapshot.balanceMinor, 0);
      await Scrollable.ensureVisible(
        tester.element(find.byKey(const ValueKey('calendar-mode'))),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const ValueKey('calendar-period')),
        const Offset(150, 0),
      );
      await tester.pumpAndSettle();
      expect(vm.snapshot.day!.month, 8);
      // A six-row month must remain scrollable on a phone. Dragging the date
      // grid scrolls the page; only the header's upward drag collapses it.
      final augustFirst = vm.snapshot.day!.copyWith(day: 1);
      await tester.drag(
        find.byKey(ValueKey('calendar-day-${augustFirst.epochDay}')),
        const Offset(0, -250),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SegmentedButton<RewardCalendarMode>>(
              find.byKey(const ValueKey('calendar-mode')),
            )
            .selected,
        {RewardCalendarMode.month},
      );
      final augustLast = augustFirst.addDays(30);
      await commandTap(
        tester,
        find.byKey(ValueKey('calendar-day-${augustLast.epochDay}')),
      );
      expect(vm.snapshot.day, augustLast);
      await Scrollable.ensureVisible(
        tester.element(find.byKey(const ValueKey('calendar-mode'))),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const ValueKey('calendar-period')),
        const Offset(-150, 0),
      );
      await tester.pumpAndSettle();
      expect(vm.snapshot.day!.month, 9);
      await tester.drag(
        find.byKey(const ValueKey('calendar-period')),
        const Offset(0, -90),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SegmentedButton<RewardCalendarMode>>(
              find.byKey(const ValueKey('calendar-mode')),
            )
            .selected,
        {RewardCalendarMode.week},
      );
      await commandTap(tester, find.byKey(const ValueKey('calendar-today')));
      expect(vm.snapshot.day, today);
      final future = tester.widget<InkWell>(
        find.byKey(ValueKey('calendar-day-${today.addDays(1).epochDay}')),
      );
      expect(future.onTap, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'latest-period forward swipe and button switch modes; history still pages normally',
    (tester) async {
      await pump(tester);
      final today = vm.repository.today;
      RewardCalendarMode mode() => tester
          .widget<SegmentedButton<RewardCalendarMode>>(
            find.byKey(const ValueKey('calendar-mode')),
          )
          .selected
          .single;
      Future<void> swipe(double dx) async {
        await tester.drag(
          find.byKey(const ValueKey('calendar-period')),
          Offset(dx, 0),
        );
        await tester.pumpAndSettle();
      }

      await swipe(-150);
      expect(mode(), RewardCalendarMode.month);
      expect(vm.snapshot.day, today);
      await swipe(-150);
      expect(mode(), RewardCalendarMode.week);
      expect(vm.snapshot.day, today);
      await swipe(-15);
      expect(mode(), RewardCalendarMode.week);

      // Moving through history and merely arriving at the newest period must
      // not also change mode in the same gesture.
      await swipe(150);
      expect(vm.snapshot.day, today.subtractDays(7));
      expect(mode(), RewardCalendarMode.week);
      await swipe(-150);
      expect(vm.snapshot.day, today);
      expect(mode(), RewardCalendarMode.week);
      await commandTap(tester, find.byKey(const ValueKey('calendar-next')));
      expect(mode(), RewardCalendarMode.month);
      await commandTap(tester, find.byKey(const ValueKey('calendar-next')));
      expect(mode(), RewardCalendarMode.week);

      await swipe(-150);
      final earlierInMonth = today.copyWith(day: 1);
      await commandTap(
        tester,
        find.byKey(ValueKey('calendar-day-${earlierInMonth.epochDay}')),
      );
      await swipe(-150);
      expect(mode(), RewardCalendarMode.week);
      expect(vm.snapshot.day, earlierInMonth);
      expect(vm.snapshot.balanceMinor, 0);
      expect(vm.snapshot.completedIds, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'negative editor rounds input on blur; records a deduction and updates forecast',
    (tester) async {
      await pump(tester);
      await tab(tester, 1);
      await tester.tap(find.text('添加兴趣'));
      await tester.pumpAndSettle();
      expect(find.byType(HobbyEditor), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('hobby-name')), '熬夜');
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('hobby-reward')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
        find.byKey(const ValueKey('hobby-reward')),
        '-3.456',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      final editable = find.descendant(
        of: find.byKey(const ValueKey('hobby-reward')),
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(editable).controller.text, '-3.46');
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('save-hobby')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await commandTap(tester, find.byKey(const ValueKey('save-hobby')));
      final bad = vm.snapshot.hobbies.firstWhere((h) => h.rewardMinor < 0);
      await tab(tester, 0);
      await tester.scrollUntilVisible(
        find.byKey(ValueKey('complete-${bad.id}')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('记录发生'), findsOneWidget);
      await commandTap(tester, find.byKey(ValueKey('complete-${bad.id}')));
      expect(vm.snapshot.balanceMinor, -346);
      await tab(tester, 3);
      expect(find.text('暂无法预计：近14天净奖励未增长'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
