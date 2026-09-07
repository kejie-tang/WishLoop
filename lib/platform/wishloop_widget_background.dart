// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/consts.dart';
import '../l10n/localizations.dart';
import '../reminders/notification_service.dart';
import '../storage/db/db_helper.dart';
import '../storage/hobby_wallet_repository.dart';
import '../storage/profile/handlers/app_language.dart';
import 'wishloop_widget.dart';
import 'wishloop_widget_action.dart';

/// Headless engine entry point: never builds an Activity or requests permission.
@pragma('vm:entry-point')
Future<void> wishLoopWidgetBackground() async {
  WidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(
    'io.github.friesi23.mhabit/wishloop_widget_background',
  );
  final helper = DBHelper();
  try {
    await helper.init();
    final repo = HobbyWalletRepository(helper.db);
    channel.setMethodCallHandler((call) async {
      if (call.method == 'close') {
        await helper.db.close();
        return null;
      }
      if (call.method != 'complete') throw MissingPluginException();
      final args = Map<Object?, Object?>.from(call.arguments as Map);
      final changed = await WishLoopWidgetAction.complete(repo, args);
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final raw = prefs.getString('appLocale');
      final locale = raw == null
          ? null
          : const AppLanguageProfileCodec().decode(
              Map<String, dynamic>.from(jsonDecode(raw) as Map),
            );
      final resolved = basicLocaleListResolution(
        locale == null ? PlatformDispatcher.instance.locales : [locale],
        appSupportedLocales,
      );
      final l = await L10n.delegate.load(resolved);
      final generation = await channel.invokeMethod<int>('beginSnapshot');
      final snapshot = await WishLoopWidget.createSnapshot(
        repo,
        l,
        theme: args['theme'] as String? ?? 'system',
      );
      await channel.invokeMethod<void>('updateSnapshot', {
        'snapshot': jsonEncode(snapshot),
        'generation': generation,
      });
      if (changed) {
        final state = await repo.load();
        final hobby = state.hobbies
            .where((h) => h.id == args['hobbyId'])
            .firstOrNull;
        if (hobby != null) {
          try {
            final service = NotificationService();
            await service.init();
            await service.cancelHabitReminder(
              id: hobby.habit.id!,
              timeout: null,
            );
          } catch (error, stack) {
            debugPrint(
              'WishLoop widget reminder cancellation failed: $error\n$stack',
            );
          }
        }
      }
      return changed;
    });
    await channel.invokeMethod<void>('ready');
  } catch (error, stack) {
    debugPrint('WishLoop widget initialization failed: $error\n$stack');
    await channel.invokeMethod<void>('failed');
  }
}
