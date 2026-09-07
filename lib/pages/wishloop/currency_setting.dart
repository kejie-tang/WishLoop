// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/localizations.dart';
import '../../providers/wishloop/wallet_controller.dart';
import '../../utils/reward_money.dart';
import 'common.dart';

class CurrencySettingTile extends StatelessWidget {
  const CurrencySettingTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context)!;
    final vm = context.watch<WalletController>();
    final currency = vm.snapshot.currency;
    String label(String code) =>
        code == 'USD' ? l.wCurrencyUsd : l.wCurrencyCny;
    return ListTile(
      key: const ValueKey('currency-setting'),
      leading: const Icon(Icons.currency_exchange),
      title: Text(l.wCurrency),
      subtitle: Text(label(currency)),
      trailing: const Icon(Icons.chevron_right),
      enabled: !vm.busy,
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(l.wCurrency),
            children: [
              for (final code in RewardMoney.currencies)
                SimpleDialogOption(
                  key: ValueKey('currency-$code'),
                  onPressed: () => Navigator.pop(context, code),
                  child: Row(
                    children: [
                      Expanded(child: Text(label(code))),
                      if (code == currency) const Icon(Icons.check),
                    ],
                  ),
                ),
            ],
          ),
        );
        if (selected == null || selected == currency || !context.mounted) {
          return;
        }
        if (!await confirm(
              context,
              l.wCurrencyChangeTitle(label(selected)),
              l.wCurrencyChangeBody,
              l.wConfirmCurrency,
            ) ||
            !context.mounted) {
          return;
        }
        await perform(
          context,
          () => vm.run(() => vm.repository.setCurrency(selected)),
        );
      },
    );
  }
}
