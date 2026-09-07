// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/localizations.dart';
import '../../models/hobby_wallet.dart';
import '../../providers/wishloop/wallet_controller.dart';
import 'common.dart';
import 'editors.dart';

Future<void> openWishEditor(BuildContext context, [WishlistItem? wish]) =>
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => WishEditor(wish: wish)));

class WishProgress extends StatelessWidget {
  final WishlistItem wish;
  final int balance;
  final int recent14NetMinor;
  const WishProgress({
    super.key,
    required this.wish,
    required this.balance,
    this.recent14NetMinor = 0,
  });
  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context)!;
    final tenths = wish.progressTenths(balance);
    final estimate = wish.estimatedDays(balance, recent14NetMinor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${wish.emoji}  ${wish.name}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Text(
          l.wWishAmounts(
            money(context, balance),
            money(context, wish.targetPriceMinor),
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: wish.progress(balance),
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Text('${tenths ~/ 10}.${tenths % 10}%'),
        ),
        const SizedBox(height: 8),
        Text(
          estimate == 0
              ? l.wEstimateReached
              : estimate == null
              ? l.wEstimateUnavailable
              : l.wEstimateDays(estimate),
          key: ValueKey('estimate-${wish.id}'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(l.wEstimateHelp, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class WishesBody extends StatelessWidget {
  const WishesBody({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WalletController>();
    final s = vm.snapshot;
    final l = L10n.of(context)!;
    return ListView(
      key: const PageStorageKey('wishes-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        if (s.wishes.isEmpty)
          EmptyWalletSection(
            icon: Icons.favorite_outline,
            title: l.wEmptyWishes,
            body: l.wEmptyWishesBody,
            action: l.wAddWish,
            onAction: () => openWishEditor(context),
          ),
        for (final w in s.wishes)
          WalletCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        w.status == WishlistStatus.redeemed
                            ? l.wRedeemed
                            : w.isPrimary
                            ? l.wCurrentWish
                            : l.wWishlist,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (w.status == WishlistStatus.active)
                      PopupMenuButton<String>(
                        onSelected: (action) async {
                          if (action == 'edit') {
                            await openWishEditor(context, w);
                          }
                          if (action == 'delete' &&
                              context.mounted &&
                              await confirm(
                                context,
                                l.wDelete,
                                w.name,
                                l.wDelete,
                              ) &&
                              context.mounted) {
                            await perform(context, () async {
                              await vm.run(
                                () => vm.repository.deleteWish(w.id),
                              );
                            });
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(l.wEditWish),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(l.wDelete),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (w.status == WishlistStatus.active)
                  WishProgress(
                    wish: w,
                    balance: s.balanceMinor,
                    recent14NetMinor: s.recent14NetMinor,
                  )
                else ...[
                  Text(
                    '${w.emoji}  ${w.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(money(context, w.targetPriceMinor)),
                  for (final r in s.redemptions.where(
                    (r) => r.wishlistId == w.id,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l.wRedeemedAt(
                          DateFormat.yMMMd(l.localeName).format(r.timestamp),
                        ),
                      ),
                    ),
                ],
                if (w.note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(w.note),
                  ),
                if (w.status == WishlistStatus.active) ...[
                  const SizedBox(height: 14),
                  Text(
                    w.canRedeem(s.balanceMinor)
                        ? l.wReady
                        : l.wShortfall(
                            money(context, w.targetPriceMinor - s.balanceMinor),
                          ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: ValueKey('redeem-${w.id}'),
                      onPressed: !w.canRedeem(s.balanceMinor) || vm.busy
                          ? null
                          : () async {
                              final yes = await confirm(
                                context,
                                l.wRedeemTitle(w.name),
                                l.wRedeemBody(
                                  money(context, w.targetPriceMinor),
                                  money(
                                    context,
                                    s.balanceMinor - w.targetPriceMinor,
                                  ),
                                ),
                                l.wConfirmRedeem,
                              );
                              if (yes && context.mounted) {
                                await perform(context, () async {
                                  await vm.run(
                                    () => vm.repository.redeem(w.id),
                                  );
                                }, success: l.wRedeemed);
                              }
                            },
                      icon: const Icon(Icons.card_giftcard),
                      label: Text(l.wRedeem),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
