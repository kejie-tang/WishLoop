// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../l10n/localizations.dart';
import '../models/hobby_wallet.dart';
import '../storage/hobby_wallet_repository.dart';
import '../utils/reward_money.dart';

class WidgetLaunch {
  final String target;
  final String? hobbyId;
  const WidgetLaunch(this.target, [this.hobbyId]);
  static WidgetLaunch? parse(Object? raw) {
    if (raw is! Map || !{'today', 'wallet', 'wishes'}.contains(raw['target'])) {
      return null;
    }
    final id = raw['hobbyId'];
    return WidgetLaunch(
      raw['target'] as String,
      id is String && id.isNotEmpty ? id : null,
    );
  }
}

/// Android presentation bridge. Background actions use the same repository.
class WishLoopWidget {
  static const channel = MethodChannel(
    'io.github.friesi23.mhabit/wishloop_widget',
  );
  Future<Map<String, Object>> Function()? _pendingSnapshot;
  Future<void>? _sync;
  bool _disposed = false;

  Future<void> start(
    void Function(WidgetLaunch) onOpen, {
    void Function()? onChanged,
  }) async {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'changed' && !_disposed) onChanged?.call();
      if (call.method == 'open' && !_disposed) {
        final launch = WidgetLaunch.parse(call.arguments);
        if (launch != null) onOpen(launch);
      }
    });
    final launch = WidgetLaunch.parse(
      await channel.invokeMethod<Object?>('consumeLaunch'),
    );
    if (launch != null && !_disposed) onOpen(launch);
  }

  Future<void> refresh(
    HobbyWalletRepository repository,
    L10n l, {
    String theme = 'system',
  }) {
    _pendingSnapshot = () => createSnapshot(repository, l, theme: theme);
    return _sync ??= _drain().whenComplete(() => _sync = null);
  }

  Future<void> _drain() async {
    while (_pendingSnapshot != null && !_disposed) {
      final build = _pendingSnapshot!;
      _pendingSnapshot = null;
      final generation = await channel.invokeMethod<int>('beginSnapshot');
      final snapshot = await build();
      // Coalesce newer requests instead of publishing an already stale frame.
      if (_pendingSnapshot == null && !_disposed) {
        await channel.invokeMethod<void>('updateSnapshot', {
          'snapshot': jsonEncode(snapshot),
          'generation': generation,
        });
      }
    }
  }

  static Future<Map<String, Object>> createSnapshot(
    HobbyWalletRepository repo,
    L10n l, {
    String theme = 'system',
  }) async {
    final s = await repo
        .load(); // Always today, regardless of the in-app calendar.
    final today = s.day!;
    final wish = s.wishes
        .where((w) => w.isPrimary && w.status == WishlistStatus.active)
        .firstOrNull;
    final estimate = wish?.estimatedDays(s.balanceMinor, s.recent14NetMinor);
    String format(int amount, {bool signed = false}) => RewardMoney.format(
      amount,
      currency: s.currency,
      locale: l.localeName,
      signed: signed,
      showSymbol: !signed,
    );
    final days = <String, Object>{};
    // Cache a week of schedules so a closed app's widget can roll over locally.
    // Any check-in, edit or import rebuilds this cache through the controller.
    for (var offset = 0; offset < 7; offset++) {
      final day = today.addDays(offset);
      final hobbies = offset == 0
          ? s.dayHobbies
                .where(
                  (h) =>
                      s.dueIds.contains(h.id) && !s.completedIds.contains(h.id),
                )
                .toList()
          : await repo.widgetHobbiesOn(day);
      days[day.toIso8601String().substring(0, 10)] = {
        'net':
            '${l.wToday} ${format(offset == 0 ? s.dayNetMinor : 0, signed: true)}',
        'netMinor': offset == 0 ? s.dayNetMinor : 0,
        'empty': s.hobbies.isEmpty
            ? l.wWidgetEmpty
            : (offset == 0 && s.dayHobbies.isNotEmpty
                  ? l.wWidgetAllDone
                  : l.wEmptyToday),
        'hobbies': [
          for (final h in hobbies.take(4))
            {
              'id': h.id,
              'emoji': h.emoji,
              'amount': format(h.rewardMinor, signed: true),
              'amountMinor': h.rewardMinor,
              // Accessible names remain available to screen readers only.
              'label': '${h.name} ${format(h.rewardMinor, signed: true)}',
            },
        ],
      };
    }
    return {
      'version': 2,
      'theme': theme,
      'walletLabel': l.wWallet,
      'balance': format(s.balanceMinor),
      'wish': wish == null
          ? l.wWidgetNoWish
          : '${wish.emoji} ${wish.name}  ${wish.progressTenths(s.balanceMinor) ~/ 10}.${wish.progressTenths(s.balanceMinor) % 10}%',
      'progress': wish?.progressTenths(s.balanceMinor) ?? 0,
      'estimate': wish == null
          ? ''
          : estimate == 0
          ? l.wEstimateReached
          : estimate == null
          ? l.wWidgetEstimateUnavailable
          : l.wEstimateDays(estimate),
      'refresh': l.wWidgetRefresh,
      'retry': l.wWidgetRetry,
      'days': days,
    };
  }

  static Future<bool> pin() async =>
      await channel.invokeMethod<bool>('pinWidget') ?? false;
  void dispose() {
    _disposed = true;
    _pendingSnapshot = null;
    channel.setMethodCallHandler(null);
  }
}
