import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/models/habit_freq.dart';
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
    await tester.tap(finder);
    await tester.pumpAndSettle();
    expect(vm.busy, isFalse);
  }

  for (final theme in ThemeMode.values.where((t) => t != ThemeMode.system)) {
    testWidgets('four pages render in Chinese ${theme.name}', (tester) async {
      await pump(tester, themeMode: theme);
      expect(find.text('今日奖励'), findsOneWidget);
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
    for (var i = 0; i < 4; i++) {
      await tab(tester, i);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
  });
}
