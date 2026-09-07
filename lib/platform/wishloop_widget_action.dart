// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:uuid/validation.dart';

import '../models/habit_date.dart';
import '../models/hobby_wallet.dart';
import '../storage/hobby_wallet_repository.dart';

/// A stale widget must not charge an edited price or complete a different day.
/// Repository validation is repeated inside the SQLite transaction.
abstract final class WishLoopWidgetAction {
  static Future<bool> complete(
    HobbyWalletRepository repo,
    Object? arguments,
  ) async {
    if (arguments is! Map) return false;
    final id = arguments['hobbyId'];
    final date = arguments['day'];
    final amount = arguments['amountMinor'];
    if (id is! String || id.isEmpty || date is! String || amount is! int) {
      return false;
    }
    if (!UuidValidation.isValidUUID(fromString: id)) return false;
    final parsed = DateTime.tryParse(date);
    if (parsed == null || parsed.toIso8601String().substring(0, 10) != date) {
      return false;
    }
    try {
      return await repo.complete(
            id,
            onDay: HabitDate.dateTime(parsed),
            requireToday: true,
            expectedRewardMinor: amount,
          ) !=
          null;
    } on WalletException {
      // The widget may have outlived an edit/archive or crossed midnight.
      // Refresh the cache; do not retry a now-invalid monetary action.
      return false;
    }
  }
}
