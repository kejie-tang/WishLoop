// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/localizations.dart';
import '../../models/hobby_wallet.dart';
import '../../providers/wishloop/wallet_controller.dart';
import '../../utils/reward_money.dart';
import 'common.dart';

class WalletBody extends StatelessWidget {
  const WalletBody({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WalletController>();
    final s = vm.snapshot;
    final l = L10n.of(context)!;
    final theme = Theme.of(context);
    return ListView(
      key: const PageStorageKey('wallet-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        WalletCard(
          color: theme.colorScheme.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.wWallet, style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  money(context, s.balanceMinor),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${l.wMonthReward}  ${money(context, s.monthEarnedMinor, signed: true)}',
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: vm.busy
                    ? null
                    : () => showDialog<void>(
                        context: context,
                        builder: (_) => const _AdjustmentDialog(),
                      ),
                icon: const Icon(Icons.tune),
                label: Text(l.wAdjust),
              ),
            ],
          ),
        ),
        if (s.balanceMinor < 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(l.wNegativeBalance),
          ),
        Text(l.wRecent, style: theme.textTheme.titleLarge),
        const SizedBox(height: 14),
        if (s.transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text(l.wEmptyLedger, textAlign: TextAlign.center),
          ),
        for (var i = 0; i < s.transactions.length; i++) ...[
          if (i == 0 ||
              DateUtils.dateOnly(s.transactions[i].timestamp) !=
                  DateUtils.dateOnly(s.transactions[i - 1].timestamp))
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                DateFormat.yMMMd(
                  l.localeName,
                ).format(s.transactions[i].timestamp),
                style: theme.textTheme.labelLarge,
              ),
            ),
          _TransactionTile(transaction: s.transactions[i]),
        ],
        if (s.transactions.length >= 200)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(l.wLedgerLimit, style: theme.textTheme.bodySmall),
          ),
        const SizedBox(height: 28),
        Text(l.wDisclaimer, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final WalletTransaction transaction;
  const _TransactionTile({required this.transaction});
  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final l = L10n.of(context)!;
    final (icon, label) = switch (t.type) {
      WalletTransactionType.earn => (Icons.add, l.wEarn),
      WalletTransactionType.spend => (Icons.card_giftcard, l.wSpend),
      WalletTransactionType.adjustment => (Icons.tune, l.wAdjustment),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '$label · ${DateFormat.Hm(l.localeName).format(t.timestamp)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              money(context, t.amountMinor, signed: true),
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: t.amountMinor >= 0
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdjustmentDialog extends StatefulWidget {
  const _AdjustmentDialog();
  @override
  State<_AdjustmentDialog> createState() => _AdjustmentDialogState();
}

class _AdjustmentDialogState extends State<_AdjustmentDialog> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  final _id = const Uuid().v4();
  bool _saving = false;
  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context)!;
    return AlertDialog(
      title: Text(l.wAdjust),
      scrollable: true,
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.wAdjustHelp),
            const SizedBox(height: 20),
            TextFormField(
              key: const ValueKey('adjust-amount'),
              controller: _amount,
              decoration: InputDecoration(labelText: l.wAmount),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              validator: (v) =>
                  (RewardMoney.parse(v ?? '', signed: true) ?? 0) == 0
                  ? l.wInvalid
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('adjust-reason'),
              controller: _reason,
              decoration: InputDecoration(labelText: l.wReason),
              maxLength: 100,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l.wInvalid : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(l.wCancel),
        ),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
                  if (!_form.currentState!.validate()) return;
                  setState(() => _saving = true);
                  final vm = context.read<WalletController>();
                  final ok = await perform(context, () async {
                    await vm.run(
                      () => vm.repository.adjust(
                        requestId: _id,
                        amountMinor: RewardMoney.parse(
                          _amount.text,
                          signed: true,
                        )!,
                        title: _reason.text,
                      ),
                    );
                  });
                  if (!context.mounted) return;
                  if (ok) {
                    Navigator.pop(context);
                  } else {
                    setState(() => _saving = false);
                  }
                },
          child: Text(l.wSave),
        ),
      ],
    );
  }
}
