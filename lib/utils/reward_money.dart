// Copyright 2026 Hobby Wallet contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:intl/intl.dart';

/// All arithmetic and decimal parsing use integers. Doubles are only used for
/// visual progress, never for a monetary amount or ledger total.
abstract final class RewardMoney {
  static const currency = 'CNY';
  static const maxMinor = 999999999999;

  static int? parse(String input, {bool signed = false}) {
    final value = input.trim();
    if (!RegExp(
      signed ? r'^[+-]?\d{1,10}(\.\d{1,2})?$' : r'^\d{1,10}(\.\d{1,2})?$',
    ).hasMatch(value)) {
      return null;
    }
    final negative = value.startsWith('-');
    final parts = value.replaceFirst(RegExp(r'^[+-]'), '').split('.');
    final minor =
        int.parse(parts.first) * 100 +
        (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0')));
    if (minor > maxMinor) return null;
    return negative ? -minor : minor;
  }

  static String decimal(int minor) =>
      '${minor < 0 ? '-' : ''}${minor.abs() ~/ 100}.${(minor.abs() % 100).toString().padLeft(2, '0')}';

  static String format(
    int minor, {
    String locale = 'en',
    bool showCode = false,
    bool signed = false,
  }) {
    final sign = minor < 0
        ? '−'
        : signed
        ? '+'
        : '';
    final whole = NumberFormat.decimalPattern(
      locale,
    ).format(minor.abs() ~/ 100);
    final fraction = (minor.abs() % 100).toString().padLeft(2, '0');
    return '$sign${showCode ? '$currency ' : '¥'}$whole.$fraction';
  }
}
