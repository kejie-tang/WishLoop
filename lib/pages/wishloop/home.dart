// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/localizations.dart';
import '../../models/habit_date.dart';
import '../../models/habit_form.dart';
import '../../models/hobby_wallet.dart';
import '../../providers/wishloop/wallet_controller.dart';
import '../../providers/workflow/app_reminder.dart';
import '../../reminders/notification_channel.dart';
import '../../reminders/wishloop_reminders.dart';
import 'common.dart';
import 'editors.dart';
import 'reward_calendar.dart';
import 'settings.dart';
import 'wallet.dart';
import 'wishes.dart';

class WishLoopHome extends StatefulWidget {
  final bool enableReminders;
  const WishLoopHome({super.key, this.enableReminders = true});
  @override
  State<WishLoopHome> createState() => _WishLoopHomeState();
}

class _WishLoopHomeState extends State<WishLoopHome>
    with WidgetsBindingObserver {
  int _index = 0;
  bool _archived = false, _syncing = false, _syncAgain = false;
  Timer? _dayTimer;
  late WalletController _vm;
  HobbyWalletSnapshot? _lastSnapshot;
  String? _locale;
  HabitDate? _day;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _vm = context.read<WalletController>();
    _day = _vm.repository.today;
    _vm.addListener(_onChange);
    _dayTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (_day != _vm.repository.today) {
        _day = _vm.repository.today;
        _vm.refresh();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l = L10n.of(context)!;
    if (_locale != l.localeName) {
      _locale = l.localeName;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncReminders();
      });
    }
  }

  void _onChange() {
    if (_vm.loading || identical(_lastSnapshot, _vm.snapshot)) return;
    _lastSnapshot = _vm.snapshot;
    if (widget.enableReminders) _syncReminders();
  }

  Future<void> _syncReminders() async {
    if (!widget.enableReminders || !mounted) return;
    if (_syncing) {
      _syncAgain = true;
      return;
    }
    _syncing = true;
    do {
      _syncAgain = false;
      if (!mounted) break;
      final l = L10n.of(context)!;
      try {
        await WishLoopReminders(
          _vm.repository,
          context.read<NotificationChannelData>(),
        ).refresh(l);
        if (mounted) {
          await context.read<AppReminderAccess>().processTrigger(
            const AppReminderTrigger.startup(),
            content: AppReminderContent.fromL10n(l),
          );
        }
      } catch (error, stack) {
        debugPrint('WishLoop reminder refresh failed: $error\n$stack');
        if (mounted) feedback(context, l.wReminderDenied);
      }
    } while (_syncAgain && mounted);
    _syncing = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _day = _vm.repository.today;
      _vm.refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dayTimer?.cancel();
    _vm.removeListener(_onChange);
    super.dispose();
  }

  Future<void> _edit([Hobby? hobby]) async {
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => HobbyEditor(hobby: hobby)));
  }

  Future<void> _complete(Hobby hobby) async {
    final l = L10n.of(context)!;
    final day = _vm.snapshot.day ?? _vm.selectedDay;
    await perform(context, () async {
      final reward = await _vm.complete(hobby.id, onDay: day);
      if (!mounted || reward == null) return;
      feedback(
        context,
        reward < 0
            ? l.wPenaltyFeedback(
                hobby.name,
                money(context, reward, signed: true),
              )
            : l.wCompleteFeedback(
                hobby.name,
                money(context, reward, signed: true),
              ),
        duration: const Duration(milliseconds: 1500),
        action: SnackBarAction(
          label: l.wUndo,
          onPressed: () => _undo(hobby, day),
        ),
      );
    });
  }

  Future<void> _undo(Hobby hobby, HabitDate day) => perform(context, () async {
    await _vm.undo(hobby.id, day);
  }, success: L10n.of(context)!.wUndoDone).then((_) {});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WalletController>();
    final s = vm.snapshot;
    final l = L10n.of(context)!;
    final titles = [l.appName, l.wHobbies, l.wWallet, l.wWishlist];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            key: const ValueKey('settings'),
            tooltip: l.wSettings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const WishLoopSettings()),
              );
              await vm.refresh();
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: vm.loading
            ? const Center(child: CircularProgressIndicator())
            : vm.error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l.wLoadError),
                    TextButton(onPressed: vm.refresh, child: Text(l.wRetry)),
                  ],
                ),
              )
            : IndexedStack(
                index: _index,
                children: [
                  _today(context, s),
                  _hobbies(context, s),
                  const WalletBody(),
                  const WishesBody(),
                ],
              ),
      ),
      floatingActionButton:
          !vm.loading && vm.error == null && (_index == 1 || _index == 3)
          ? FloatingActionButton.extended(
              onPressed: vm.busy
                  ? null
                  : () => _index == 1 ? _edit() : openWishEditor(context),
              icon: const Icon(Icons.add),
              label: Text(_index == 1 ? l.wAddHobby : l.wAddWish),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: l.wToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.spa_outlined),
            selectedIcon: const Icon(Icons.spa),
            label: l.wHobbies,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: l.wWalletTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: l.wWishlist,
          ),
        ],
      ),
    );
  }

  Widget _today(BuildContext context, HobbyWalletSnapshot s) {
    final l = L10n.of(context)!;
    final theme = Theme.of(context);
    final due = s.dayHobbies;
    final day = s.day ?? _vm.selectedDay;
    final primary = s.wishes
        .where((w) => w.isPrimary && w.status == WishlistStatus.active)
        .firstOrNull;
    return ListView(
      key: const PageStorageKey('today-scroll'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Text(
          DateFormat.MMMMEEEEd(
            l.localeName,
          ).format(s.day ?? _vm.repository.today),
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        Text(l.wSubtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 24),
        RewardCalendar(
          today: _vm.repository.today,
          selectedDay: day,
          dailyNetMinor: s.dailyNetMinor,
          enabled: !_vm.busy,
          onSelected: (selected) => _vm.selectDay(selected),
        ),
        WalletCard(
          color: theme.colorScheme.primaryContainer,
          child: Row(
            children: [
              Expanded(
                child: Text(l.wWallet, style: theme.textTheme.titleMedium),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    money(context, s.balanceMinor),
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (primary != null)
          WalletCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.wCurrentWish, style: theme.textTheme.labelLarge),
                const SizedBox(height: 16),
                WishProgress(
                  wish: primary,
                  balance: s.balanceMinor,
                  recent14NetMinor: s.recent14NetMinor,
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Text(
          l.wDateHobbies(DateFormat.yMMMd(l.localeName).format(day)),
          key: const ValueKey('selected-day-title'),
          style: theme.textTheme.titleLarge,
        ),
        Text(l.wSelectedNet(money(context, s.dayNetMinor, signed: true))),
        const SizedBox(height: 16),
        if (s.hobbies.isEmpty && due.isEmpty)
          EmptyWalletSection(
            icon: Icons.spa_outlined,
            title: l.wEmptyHobbies,
            body: l.wEmptyHobbiesBody,
            action: l.wAddHobby,
            onAction: _edit,
          )
        else if (due.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(l.wEmptyToday, textAlign: TextAlign.center),
          ),
        for (final h in due) _hobbyCard(context, h, today: true),
        if (day == _vm.repository.today &&
            due.any((h) => h.rewardMinor >= 0) &&
            due
                .where((h) => h.rewardMinor >= 0)
                .every((h) => s.completedIds.contains(h.id)))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              l.wAllDone,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
      ],
    );
  }

  Widget _hobbies(BuildContext context, HobbyWalletSnapshot s) {
    final l = L10n.of(context)!;
    return ListView(
      key: const PageStorageKey('hobbies-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        if (s.hobbies.any((h) => h.archived))
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.wShowArchived),
            value: _archived,
            onChanged: (v) => setState(() => _archived = v),
          ),
        if (s.hobbies.isEmpty)
          EmptyWalletSection(
            icon: Icons.spa_outlined,
            title: l.wEmptyHobbies,
            body: l.wEmptyHobbiesBody,
            action: l.wAddHobby,
            onAction: _edit,
          ),
        for (final h in s.hobbies.where((h) => !h.archived || _archived))
          _hobbyCard(context, h, today: false),
      ],
    );
  }

  Widget _hobbyCard(BuildContext context, Hobby h, {required bool today}) {
    final l = L10n.of(context)!;
    final s = _vm.snapshot;
    final done = s.completedIds.contains(h.id);
    final recordedReward = today && done
        ? (s.dayCompletions[h.id] ?? 0)
        : h.rewardMinor;
    final weekdays = h.weekdayMask == 127
        ? ''
        : [
            for (var i = 1; i <= 7; i++)
              if (h.weekdayMask & (1 << (i - 1)) != 0)
                l.getHabitEditReminderWeekDayText(i),
          ].join(' · ');
    return WalletCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(h.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(l.wMinutes(h.durationMinutes)),
                  ],
                ),
              ),
              if (!today)
                PopupMenuButton<String>(
                  onSelected: (action) async {
                    switch (action) {
                      case 'edit':
                        await _edit(h);
                      case 'archive':
                        await perform(context, () async {
                          await _vm.run(
                            () => _vm.repository.setHobbyStatus(
                              h.id,
                              h.archived
                                  ? HabitStatus.activated
                                  : HabitStatus.archived,
                            ),
                          );
                        });
                      case 'delete':
                        if (await confirm(
                              context,
                              l.wDelete,
                              l.wDeleteConfirm,
                              l.wDelete,
                            ) &&
                            context.mounted) {
                          await perform(context, () async {
                            await _vm.run(
                              () => _vm.repository.setHobbyStatus(
                                h.id,
                                HabitStatus.deleted,
                              ),
                            );
                          });
                        }
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(l.wEditHobby)),
                    PopupMenuItem(
                      value: 'archive',
                      child: Text(h.archived ? l.wRestoreHobby : l.wArchive),
                    ),
                    PopupMenuItem(value: 'delete', child: Text(l.wDelete)),
                  ],
                ),
            ],
          ),
          if (!today) ...[
            const SizedBox(height: 12),
            Text(
              [
                h.frequency.toLocalString(l),
                if (weekdays.isNotEmpty) weekdays,
                if (h.archived) l.wArchived,
              ].join(' · '),
            ),
            if (h.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(h.description),
              ),
            if (h.reminder != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('◷ ${h.reminder!.time.format(context)}'),
              ),
          ],
          const SizedBox(height: 16),
          Text(
            (recordedReward < 0 ? l.wPenaltyLabel : l.wRewardLabel)(
              money(context, recordedReward, signed: true),
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (today) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (done)
                  Expanded(
                    child: Text(
                      h.rewardMinor < 0 ? l.wPenaltyRecorded : l.wCompleted,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                if (done)
                  TextButton(
                    key: ValueKey('undo-${h.id}'),
                    onPressed: _vm.busy
                        ? null
                        : () => _undo(h, s.day ?? _vm.repository.today),
                    child: Text(l.wUndo),
                  )
                else
                  Expanded(
                    child: FilledButton(
                      key: ValueKey('complete-${h.id}'),
                      onPressed: _vm.busy ? null : () => _complete(h),
                      child: Text(
                        h.rewardMinor < 0 ? l.wRecordPenalty : l.wComplete,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
