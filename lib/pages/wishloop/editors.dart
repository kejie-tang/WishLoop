// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/localizations.dart';
import '../../models/habit_form.dart';
import '../../models/habit_freq.dart';
import '../../models/habit_reminder.dart';
import '../../models/hobby_wallet.dart';
import '../../providers/wishloop/wallet_controller.dart';
import '../../reminders/notification_service.dart';
import '../../utils/reward_money.dart';
import 'common.dart';

class HobbyEditor extends StatefulWidget {
  final Hobby? hobby;
  const HobbyEditor({super.key, this.hobby});
  @override
  State<HobbyEditor> createState() => _HobbyEditorState();
}

class _HobbyEditorState extends State<HobbyEditor> {
  final _form = GlobalKey<FormState>();
  final _scroll = ScrollController();
  late final TextEditingController _name,
      _emoji,
      _description,
      _duration,
      _reward,
      _times,
      _days;
  late int _weekdays;
  late HabitFrequencyType _frequency;
  late bool _daily, _remind;
  late TimeOfDay _time;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    final h = widget.hobby;
    _name = TextEditingController(text: h?.name);
    _emoji = TextEditingController(text: h?.emoji ?? '🌱');
    _description = TextEditingController(text: h?.description);
    _duration = TextEditingController(text: '${h?.durationMinutes ?? 30}');
    _reward = TextEditingController(
      text: RewardMoney.decimal(h?.rewardMinor ?? 500),
    );
    _times = TextEditingController(text: '${h?.frequency.freq ?? 3}');
    _days = TextEditingController(
      text: '${h?.frequency.days == 0 ? 7 : h?.frequency.days ?? 7}',
    );
    _weekdays = h?.weekdayMask ?? 127;
    _frequency = h?.frequency.type ?? HabitFrequencyType.custom;
    _daily = h?.frequency.isDaily ?? true;
    _remind = h?.reminder != null;
    _time = h?.reminder?.time ?? const TimeOfDay(hour: 20, minute: 0);
  }

  @override
  void dispose() {
    _scroll.dispose();
    for (final c in [
      _name,
      _emoji,
      _description,
      _duration,
      _reward,
      _times,
      _days,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    // The name field may be off-screen and unmounted by the lazy ListView.
    // Check its controller before validating the currently mounted fields.
    if (_name.text.trim().isEmpty) {
      await _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      if (mounted) _form.currentState!.validate();
      return;
    }
    final invalidFields = _form.currentState!.validateGranularly();
    if (invalidFields.isNotEmpty) {
      await Scrollable.ensureVisible(
        invalidFields.first.context,
        alignment: 0.2,
        duration: const Duration(milliseconds: 250),
      );
      return;
    }
    if (_weekdays == 0) {
      feedback(context, L10n.of(context)!.wInvalid);
      return;
    }
    setState(() => _saving = true);
    final l = L10n.of(context)!;
    final vm = context.read<WalletController>();
    final ok = await perform(context, () async {
      if (_remind &&
          await NotificationService().requestPermissions() == false) {
        if (mounted) feedback(context, l.wReminderDenied);
        return;
      }
      final freq = _daily
          ? HabitFrequency.daily
          : HabitFrequency(
              type: _frequency,
              freq: int.parse(_times.text),
              days: _frequency == HabitFrequencyType.custom
                  ? int.parse(_days.text)
                  : 0,
            );
      await vm.run(
        () => vm.repository.saveHobby(
          id: widget.hobby?.id,
          name: _name.text,
          emoji: _emoji.text.trim(),
          description: _description.text,
          durationMinutes: int.parse(_duration.text),
          rewardMinor: RewardMoney.parse(_reward.text, signed: true)!,
          weekdayMask: _weekdays,
          frequency: freq,
          reminder: !_remind
              ? null
              : widget.hobby?.reminder != null &&
                    widget.hobby!.reminder!.time == _time &&
                    widget.hobby!.weekdayMask == _weekdays
              ? widget.hobby!.reminder
              : (_weekdays == 127
                    ? HabitReminder.daily(time: _time)
                    : HabitReminder.weekly(
                        time: _time,
                        extra: [
                          for (var i = 1; i <= 7; i++)
                            if (_weekdays & (1 << (i - 1)) != 0) i,
                        ],
                      )),
        ),
      );
      if (mounted) Navigator.pop(context, true);
    });
    if (mounted) setState(() => _saving = false);
    if (!ok) return;
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hobby == null ? l.wAddHobby : l.wEditHobby),
      ),
      body: Form(
        key: _form,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              key: const ValueKey('hobby-name'),
              controller: _name,
              decoration: InputDecoration(labelText: l.wName),
              maxLength: 100,
              autovalidateMode: AutovalidateMode.onUserInteractionIfError,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l.wHobbyNameRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emoji,
              decoration: InputDecoration(labelText: l.wEmoji),
              maxLength: 16,
              validator: (v) => v == null || v.trim().isEmpty || v.length > 32
                  ? l.wInvalid
                  : null,
            ),
            Wrap(
              spacing: 10,
              children: [
                for (final emoji in [
                  '🏃',
                  '🇬🇧',
                  '🤖',
                  '📚',
                  '🎨',
                  '🎹',
                  '🌱',
                ])
                  ActionChip(
                    label: Text(emoji, style: const TextStyle(fontSize: 23)),
                    onPressed: () => _emoji.text = emoji,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _description,
              decoration: InputDecoration(labelText: l.wDescription),
              maxLength: 2000,
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _duration,
              decoration: InputDecoration(labelText: l.wDuration),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return n == null || n < 1 || n > 1440 ? l.wInvalid : null;
              },
            ),
            const SizedBox(height: 20),
            MoneyFormField(
              key: const ValueKey('hobby-reward'),
              controller: _reward,
              label: l.wReward,
              helper: l.wSignedRewardHelp,
              signed: true,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _daily ? 'daily' : _frequency.name,
              decoration: InputDecoration(labelText: l.wFrequency),
              items: [
                DropdownMenuItem(value: 'daily', child: Text(l.wDaily)),
                DropdownMenuItem(value: 'weekly', child: Text(l.wWeekly)),
                DropdownMenuItem(value: 'monthly', child: Text(l.wMonthly)),
                DropdownMenuItem(value: 'custom', child: Text(l.wCustom)),
              ],
              onChanged: (value) => setState(() {
                _daily = value == 'daily';
                if (!_daily) {
                  _frequency = HabitFrequencyType.values.byName(value!);
                }
              }),
            ),
            if (!_daily) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _times,
                decoration: InputDecoration(labelText: l.wTimes),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  final max = _frequency == HabitFrequencyType.weekly
                      ? 7
                      : _frequency == HabitFrequencyType.monthly
                      ? 31
                      : int.tryParse(_days.text) ?? 0;
                  return n == null || n < 1 || n > max ? l.wInvalid : null;
                },
              ),
              if (_frequency == HabitFrequencyType.custom)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextFormField(
                    controller: _days,
                    decoration: InputDecoration(labelText: l.wDays),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return n == null || n < 1 || n > 365 ? l.wInvalid : null;
                    },
                  ),
                ),
            ],
            const SizedBox(height: 22),
            Text(l.wWeekdays, style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: [
                for (var i = 1; i <= 7; i++)
                  FilterChip(
                    label: Text(l.getHabitEditReminderWeekDayText(i)),
                    selected: _weekdays & (1 << (i - 1)) != 0,
                    onSelected: (_) =>
                        setState(() => _weekdays ^= 1 << (i - 1)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l.wFrequencyHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.wReminder),
              subtitle: Text(_time.format(context)),
              value: _remind,
              onChanged: (v) => setState(() => _remind = v),
            ),
            if (_remind)
              TextButton.icon(
                icon: const Icon(Icons.schedule),
                label: Text(_time.format(context)),
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (mounted && time != null) setState(() => _time = time);
                },
              ),
            Text(l.wReminderHelp, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 28),
            FilledButton(
              key: const ValueKey('save-hobby'),
              onPressed: _saving ? null : _save,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(l.wSave),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class WishEditor extends StatefulWidget {
  final WishlistItem? wish;
  const WishEditor({super.key, this.wish});
  @override
  State<WishEditor> createState() => _WishEditorState();
}

class _WishEditorState extends State<WishEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _price, _emoji, _note;
  late bool _primary;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    final w = widget.wish;
    _name = TextEditingController(text: w?.name);
    _price = TextEditingController(
      text: w == null ? '' : RewardMoney.decimal(w.targetPriceMinor),
    );
    _emoji = TextEditingController(text: w?.emoji ?? '🎁');
    _note = TextEditingController(text: w?.note);
    _primary = w?.isPrimary ?? true;
  }

  @override
  void dispose() {
    for (final c in [_name, _price, _emoji, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wish == null ? l.wAddWish : l.wEditWish),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              key: const ValueKey('wish-name'),
              controller: _name,
              decoration: InputDecoration(labelText: l.wName),
              maxLength: 100,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l.wInvalid : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emoji,
              decoration: InputDecoration(labelText: l.wEmoji),
              maxLength: 16,
              validator: (v) => v == null || v.trim().isEmpty || v.length > 32
                  ? l.wInvalid
                  : null,
            ),
            const SizedBox(height: 16),
            MoneyFormField(
              key: const ValueKey('wish-price'),
              controller: _price,
              label: l.wTargetPrice,
              allowZero: false,
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _note,
              decoration: InputDecoration(labelText: l.wNote),
              minLines: 2,
              maxLines: 4,
              maxLength: 2000,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.wPrimary),
              value: _primary,
              onChanged: (v) => setState(() => _primary = v),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const ValueKey('save-wish'),
              onPressed: _saving
                  ? null
                  : () async {
                      if (!_form.currentState!.validate()) return;
                      setState(() => _saving = true);
                      final vm = context.read<WalletController>();
                      final ok = await perform(context, () async {
                        await vm.run(
                          () => vm.repository.saveWish(
                            id: widget.wish?.id,
                            name: _name.text,
                            targetPriceMinor: RewardMoney.parse(_price.text)!,
                            emoji: _emoji.text.trim(),
                            note: _note.text,
                            isPrimary: _primary,
                          ),
                        );
                      });
                      if (!context.mounted) return;
                      if (ok) {
                        Navigator.pop(context, true);
                      } else {
                        setState(() => _saving = false);
                      }
                    },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(l.wSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
