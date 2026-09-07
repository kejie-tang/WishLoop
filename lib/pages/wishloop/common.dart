// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/localizations.dart';
import '../../models/hobby_wallet.dart';
import '../../providers/wishloop/wallet_controller.dart';
import '../../utils/reward_money.dart';

String money(BuildContext context, int amount, {bool signed = false}) =>
    RewardMoney.format(
      amount,
      currency: context.read<WalletController>().snapshot.currency,
      locale: L10n.of(context)!.localeName,
      signed: signed,
      showSymbol: !signed,
    );

void feedback(
  BuildContext context,
  String text, {
  SnackBarAction? action,
  Duration duration = const Duration(seconds: 4),
}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        action: action,
        duration: duration,
        // Material 3 otherwise keeps action snackbars visible indefinitely.
        persist: false,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

String errorText(BuildContext context, Object error) {
  final l = L10n.of(context)!;
  if (error is WalletException) {
    return switch (error.reason) {
      WalletFailure.insufficientBalance => l.wInsufficient,
      WalletFailure.alreadyRedeemed => l.wAlreadyRedeemed,
      WalletFailure.invalidInput => l.wInvalid,
      _ => l.wError,
    };
  }
  return l.wError;
}

Future<bool> perform(
  BuildContext context,
  Future<void> Function() action, {
  String? success,
}) async {
  try {
    await action();
    if (context.mounted && success != null) feedback(context, success);
    return true;
  } catch (error, stack) {
    debugPrint('WishLoop action failed: $error\n$stack');
    if (context.mounted) feedback(context, errorText(context, error));
    return false;
  }
}

Future<bool> confirm(
  BuildContext context,
  String title,
  String body,
  String action,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        scrollable: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(L10n.of(context)!.wCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;

class WalletCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  const WalletCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(20),
  });
  @override
  Widget build(BuildContext context) => Card(
    color: color,
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Padding(padding: padding, child: child),
  );
}

class EmptyWalletSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;
  const EmptyWalletSection({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 12),
    child: Column(
      children: [
        Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Text(
          body,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (action != null)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(action!),
            ),
          ),
      ],
    ),
  );
}

/// Normalizes decimal input on blur while preserving integer-only parsing.
class MoneyFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helper;
  final bool signed, allowZero;
  const MoneyFormField({
    super.key,
    required this.controller,
    required this.label,
    this.helper,
    this.signed = false,
    this.allowZero = true,
  });
  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context)!;
    return Focus(
      onFocusChange: (focused) {
        if (!focused) {
          final minor = RewardMoney.parse(controller.text, signed: signed);
          if (minor != null) controller.text = RewardMoney.decimal(minor);
        }
      },
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 3,
        ),
        keyboardType: TextInputType.numberWithOptions(
          decimal: true,
          signed: signed,
        ),
        validator: (value) {
          final minor = RewardMoney.parse(value ?? '', signed: signed);
          return minor == null || (!allowZero && minor == 0)
              ? l.wInvalid
              : null;
        },
      ),
    );
  }
}
