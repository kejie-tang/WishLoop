// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/foundation.dart';

import '../../models/habit_date.dart';
import '../../models/hobby_wallet.dart';
import '../../storage/hobby_wallet_repository.dart';

class WalletController extends ChangeNotifier {
  final HobbyWalletRepository repository;
  HobbyWalletSnapshot snapshot = const HobbyWalletSnapshot();
  bool loading = true;
  bool busy = false;
  Object? error;
  bool _disposed = false;

  WalletController(this.repository);
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> refresh() async {
    try {
      snapshot = await repository.load();
      error = null;
    } catch (e, stack) {
      error = e;
      debugPrint('WishLoop load failed: $e\n$stack');
    } finally {
      loading = false;
      _notify();
    }
  }

  /// Serializes UI commands while database constraints protect other callers.
  /// Exceptions are surfaced by the caller as localized feedback.
  Future<T?> run<T>(Future<T> Function() command) async {
    if (busy) return null;
    busy = true;
    _notify();
    try {
      final result = await command();
      await refresh();
      return result;
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<int?> complete(String id) => run<int?>(() => repository.complete(id));
  Future<bool?> undo(String id, HabitDate day) =>
      run(() => repository.undo(id, day));

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
