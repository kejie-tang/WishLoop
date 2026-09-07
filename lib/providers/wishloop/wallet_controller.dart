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
  HabitDate? _selectedDay;
  int _refreshGeneration = 0;
  HabitDate get selectedDay => _selectedDay ?? repository.today;

  Future<void> selectDay(HabitDate day) async {
    if (day.epochDay > repository.today.epochDay || day.year < 1900) return;
    await run(() async => _selectedDay = day == repository.today ? null : day);
  }

  WalletController(this.repository);
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> refresh() async {
    final generation = ++_refreshGeneration;
    try {
      final value = await repository.load(onDay: selectedDay);
      if (generation != _refreshGeneration) return;
      snapshot = value;
      error = null;
    } catch (e, stack) {
      error = e;
      debugPrint('WishLoop load failed: $e\n$stack');
    } finally {
      if (generation == _refreshGeneration) {
        loading = false;
        _notify();
      }
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

  Future<int?> complete(String id, {HabitDate? onDay}) =>
      run<int?>(() => repository.complete(id, onDay: onDay ?? selectedDay));
  Future<bool?> undo(String id, HabitDate day) =>
      run(() => repository.undo(id, day));

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
