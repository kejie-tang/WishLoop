// Copyright 2026 Hobby Wallet contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:intl/intl.dart';

/// All arithmetic and decimal parsing use integers. Doubles are only used for
/// visual progress, never for a monetary amount or ledger total.
abstract final class RewardMoney {
  static const currency = 'CNY';
  static const maxMinor = 999999999999;

  static int? parse(String input, {bool signed = false}) {
    final value = input.trim().replaceAll('−', '-').replaceAll('－', '-');
    if (!RegExp(
          signed
              ? r'^[+-]?(?:\d{1,10}(?:\.\d*)?|\.\d+)$'
              : r'^(?:\d{1,10}(?:\.\d*)?|\.\d+)$',
        ).hasMatch(value) ||
        value.length > 100) {
      return null;
    }
    final negative = value.startsWith('-');
    final parts = value.replaceFirst(RegExp(r'^[+-]'), '').split('.');
    final fraction = (parts.length == 1 ? '' : parts[1]).padRight(3, '0');
    // Decimal half-up rounding on the magnitude, including negative values.
    // Never parse money through a binary floating-point representation.
    final minor =
        (int.tryParse(parts.first) ?? 0) * 100 +
        int.parse(fraction.substring(0, 2)) +
        (int.parse(fraction[2]) >= 5 ? 1 : 0);
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
