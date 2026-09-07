// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../common/app_info.dart';
import '../../l10n/localizations.dart';
import '../../platform/wishloop_widget.dart';
import '../../providers/app_ui/app_language.dart';
import '../../providers/app_ui/app_theme.dart';
import '../../providers/wishloop/wallet_controller.dart';
import '../../providers/workflow/app_reminder.dart';
import '../../providers/workflow/habits_file_importer.dart';
import '../../reminders/notification_channel.dart';
import '../../reminders/notification_data.dart';
import '../../reminders/notification_service.dart';
import '../../storage/db_helper_provider.dart';
import '../../storage/wishloop_backup.dart';
import '../../utils/app_path_provider.dart';
import '../../utils/xshare.dart';
import '../app_settings/_widgets/app_language_changer.dart';
import '../app_settings/_widgets/app_setting_reminder_tile.dart';
import '../app_settings/_widgets/app_setting_theme_mode.dart';
import 'common.dart';
import 'currency_setting.dart';

class WishLoopSettings extends StatefulWidget {
  const WishLoopSettings({super.key});
  @override
  State<WishLoopSettings> createState() => _WishLoopSettingsState();
}

class _WishLoopSettingsState extends State<WishLoopSettings> with XShare {
  bool _working = false;
  Future<void> _work(Future<void> Function() action) async {
    if (_working) return;
    setState(() => _working = true);
    await perform(context, action);
    if (mounted) setState(() => _working = false);
  }

  WishLoopBackup get _backup =>
      WishLoopBackup(context.read<DBHelperViewModel>().local.db);
  Future<void> _export() => _work(() async {
    final data = await _backup.exportData();
    final dir = await AppPathProvider().getExportHabitsDirPath();
    final file = await File(
      '$dir/WishLoop-${DateTime.now().millisecondsSinceEpoch}.json',
    ).writeAsString(data, flush: true);
    if (!mounted) return;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final saved =
          await const MethodChannel(
            'io.github.friesi23.mhabit/wishloop_backup',
          ).invokeMethod<bool>('saveBackup', {
            'path': file.path,
            'name': file.uri.pathSegments.last,
          });
      if (mounted && saved == true) {
        feedback(context, L10n.of(context)!.wBackupDone);
      }
    } else {
      await trySaveFiles(
        [XFile(file.path)],
        defaultTargetPlatform,
        context: context,
      );
    }
  });
  Future<void> _import() => _work(() async {
    final file = await openFile();
    if (file == null) return;
    if (await file.length() > 50 * 1024 * 1024) {
      throw const FormatException('Backup too large');
    }
    final text = utf8.decode(await file.readAsBytes());
    final backup = _backup;
    backup.inspect(text);
    if (!mounted) return;
    final l = L10n.of(context)!;
    if (!await confirm(context, l.wImport, l.wImportConfirm, l.wImport) ||
        !mounted) {
      return;
    }
    final vm = context.read<WalletController>();
    await vm.run(() => backup.restore(text));
    if (mounted) feedback(context, l.wImportDone);
  });
  Future<void> _legacyImport() => _work(() async {
    final file = await openFile();
    if (file == null) return;
    if (await file.length() > 50 * 1024 * 1024) {
      throw const FormatException('Import too large');
    }
    final data =
        jsonDecode(utf8.decode(await file.readAsBytes()))
            as Map<String, dynamic>;
    final habits = data['habits'] as List;
    final groups = data['groups'] as List?;
    if (!mounted) return;
    final l = L10n.of(context)!;
    final runner = context.read<HabitFileImportRunner>();
    if (runner.importHabitsDataDryRun(habits) == 0) {
      throw const FormatException('No valid habits');
    }
    if (!await confirm(context, l.wLegacyImport, l.wLegacyConfirm, l.wImport) ||
        !mounted) {
      return;
    }
    final vm = context.read<WalletController>();
    // Keep a rollback image because the upstream importer commits per habit.
    final backup = _backup;
    final before = await backup.exportData();
    await vm.run(() async {
      try {
        final mapping = groups == null
            ? null
            : await runner.importGroupsData(groups);
        var failed = 0;
        await runner.importHabitsData(
          habits,
          groupUuidMapping: mapping,
          whenloadAllHabits: (_, failures, _) {
            failed = failures;
          },
        );
        if (failed > 0) {
          throw const FormatException('Some habits could not be imported');
        }
      } catch (_) {
        await backup.restore(before);
        rethrow;
      }
    });
    if (mounted) feedback(context, l.wLegacyDone);
  });
  @override
  Widget build(BuildContext buildContext) {
    final l = L10n.of(context)!;
    final reminder = context.watch<AppReminderViewModel>();
    final language = context.watch<AppLanguageViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text(l.wSettings)),
      body: AbsorbPointer(
        absorbing: _working,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
          children: [
            if (_working) const LinearProgressIndicator(),
            const AppSettingThemeModeTile(),
            if (defaultTargetPlatform == TargetPlatform.android)
              ListTile(
                key: const ValueKey('add-home-widget'),
                leading: const Icon(Icons.widgets_outlined),
                title: Text(l.wHomeWidget),
                subtitle: Text(l.wHomeWidgetHelp),
                trailing: IconButton(
                  tooltip: l.wWidgetAddHelp,
                  icon: const Icon(Icons.help_outline),
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l.wWidgetAddHelp),
                      scrollable: true,
                      content: Text(l.wWidgetAddInstructions),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l.wClose),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () => _work(() async {
                  final widget = WishLoopWidget();
                  await widget.refresh(
                    context.read<WalletController>().repository,
                    l,
                    theme: context.read<AppThemeViewModel>().themeType.name,
                  );
                  final requested = await WishLoopWidget.pin();
                  if (!requested && mounted) {
                    feedback(context, l.wHomeWidgetManual);
                  }
                }),
              ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l.appSetting_changeLanguageDialog_titleText),
              subtitle: Text(language.getAppLanguageText(l)),
              onTap: () async {
                final result = await showDialog<AppLanguageChangerDialogResult>(
                  context: context,
                  builder: (_) => AppLanguageChangerDialog(
                    selectedLocale: language.languange,
                  ),
                );
                if (result != null) {
                  await language.switchLanguage(result.choosenLanguage);
                }
              },
            ),
            const CurrencySettingTile(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l.wNotifications,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            AppSettingReminderTile(
              config: reminder.reminder,
              onSwitchButtonChanged: (enabled) => _work(() async {
                if (enabled) {
                  await reminder.switchOn(l10n: l);
                  if (!reminder.reminder.enabled && mounted) {
                    feedback(context, l.wReminderDenied);
                  }
                } else {
                  await reminder.switchOff(l10n: l);
                }
              }),
              onTimePicked: (time) =>
                  _work(() => reminder.switchToDaily(timeOfDay: time, l10n: l)),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(l.wTestNotification),
              subtitle: Text(l.wReminderHelp),
              onTap: () => _work(() async {
                final service = NotificationService();
                if (await service.requestPermissions() == false) {
                  if (mounted) feedback(context, l.wReminderDenied);
                  return;
                }
                if (!mounted) return;
                final success = await service.show(
                  id: 1900000001,
                  title: l.appName,
                  body: l.wNotificationBody,
                  type: NotificationDataType.appReminder,
                  channelId: NotificationChannelId.appReminder,
                  details: context.read<NotificationChannelData>().appReminder,
                );
                if (mounted) {
                  feedback(context, success ? l.wTestSent : l.wReminderDenied);
                }
              }),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: Text(l.wBackup),
              subtitle: Text(l.wBackupHelp),
              onTap: _export,
            ),
            ListTile(
              leading: const Icon(Icons.restore_page_outlined),
              title: Text(l.wImport),
              onTap: _import,
            ),
            ListTile(
              leading: const Icon(Icons.file_open_outlined),
              title: Text(l.wLegacyImport),
              subtitle: Text(l.wLegacyHelp),
              onTap: _legacyImport,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l.wAbout),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: l.appName,
                applicationVersion: AppInfo().appVersion,
                applicationLegalese: l.wAboutBody,
                children: [const SizedBox(height: 16), Text(l.wDisclaimer)],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l.wDisclaimer,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
