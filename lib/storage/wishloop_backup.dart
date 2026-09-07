// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import '../common/consts.dart';
import '../models/hobby_wallet.dart';
import '../utils/reward_money.dart';

/// Portable full data backup. Restore is a single transaction: malformed data,
/// constraint failures and broken ledger links leave the live database intact.
class WishLoopBackup {
  final Database db;
  const WishLoopBackup(this.db);
  static const tables = [
    'mh_groups',
    'mh_habits',
    'mh_records',
    'mh_sync',
    'hw_wishlist',
    'hw_checkins',
    'hw_transactions',
    'hw_redemptions',
  ];

  Future<String> exportData() => db.transaction((txn) async {
    final data = <String, Object?>{};
    for (final table in tables) {
      data[table] = (await txn.query(table))
          .map(
            (row) => row.map(
              (key, value) => MapEntry(
                key,
                value is double && !value.isFinite ? 'Infinity' : value,
              ),
            ),
          )
          .toList();
    }
    final payload = jsonEncode(data);
    return jsonEncode({
      'format': 'WishLoop',
      'version': 1,
      'schema': appDBVersion,
      'sha256': sha256.convert(utf8.encode(payload)).toString(),
      'data': payload,
    });
  });

  Map<String, List<Map<String, Object?>>> inspect(String text) {
    if (utf8.encode(text).length > 50 * 1024 * 1024) {
      throw const FormatException('Backup too large');
    }
    final envelope = jsonDecode(text) as Map<String, dynamic>;
    if (envelope['format'] != 'WishLoop' ||
        envelope['version'] != 1 ||
        envelope['schema'] != appDBVersion ||
        envelope['data'] is! String) {
      throw const FormatException('Unsupported backup');
    }
    final payload = envelope['data'] as String;
    if (sha256.convert(utf8.encode(payload)).toString() != envelope['sha256']) {
      throw const FormatException('Backup checksum mismatch');
    }
    final raw = jsonDecode(payload) as Map<String, dynamic>;
    if (raw.length != tables.length) {
      throw const FormatException('Missing tables');
    }
    return {
      for (final table in tables)
        table: (raw[table] as List)
            .map(
              (row) => (row as Map<String, dynamic>).map(
                (key, value) => MapEntry(
                  key,
                  key == 'sort_position' && value == 'Infinity'
                      ? double.infinity
                      : value,
                ),
              ),
            )
            .toList(),
    };
  }

  Future<void> restore(String text) async {
    final data = inspect(text);
    await db.transaction((txn) async {
      // Reverse the FK insertion order; records' cleanup triggers see no checkins.
      for (final table in tables.reversed) {
        await txn.delete(table);
      }
      for (final table in tables) {
        final columns = (await txn.rawQuery(
          'PRAGMA table_info($table)',
        )).map((r) => r['name']).toSet();
        for (final row in data[table]!) {
          if (row.keys.any((k) => !columns.contains(k))) {
            throw const FormatException('Unknown column');
          }
          await txn.insert(table, row);
        }
      }
      for (final row in await txn.query('mh_habits')) {
        final hobby = Hobby.fromRow(row);
        // Decode all structured fields before commit, so corrupt backup data
        // cannot cause a crash on the next launch.
        hobby.frequency;
        hobby.reminder;
      }
      final broken = await txn.rawQuery('''
        SELECT c.id FROM hw_checkins c LEFT JOIN hw_transactions t
          ON t.source_type = 'CHECK_IN' AND t.source_id = c.id
          LEFT JOIN mh_records r ON r.uuid = c.record_uuid
        WHERE t.id IS NULL OR t.amount_minor != c.reward_minor OR t.type != 'EARN'
          OR r.parent_uuid != c.habit_uuid OR r.record_date != c.day
          OR r.record_type != 1 OR r.record_value != c.completion_value
        UNION ALL
        SELECT t.id FROM hw_transactions t LEFT JOIN hw_checkins c ON c.id = t.source_id
          WHERE t.source_type = 'CHECK_IN' AND c.id IS NULL
        UNION ALL
        SELECT w.id FROM hw_wishlist w LEFT JOIN hw_redemptions r ON r.wishlist_id = w.id
          LEFT JOIN hw_transactions t ON t.id = r.transaction_id
          WHERE (w.status = 'redeemed' AND (r.id IS NULL OR t.id IS NULL OR t.amount_minor != -r.amount_minor
            OR t.source_id != w.id OR t.type != 'SPEND' OR r.amount_minor != w.target_price_minor))
            OR (w.status = 'active' AND r.id IS NOT NULL)
        UNION ALL
        SELECT t.id FROM hw_transactions t LEFT JOIN hw_redemptions r ON r.transaction_id = t.id
          WHERE t.type = 'SPEND' AND r.id IS NULL
      ''');
      if (broken.isNotEmpty ||
          (await txn.rawQuery('PRAGMA foreign_key_check')).isNotEmpty) {
        throw const FormatException('Broken ledger relationships');
      }
      final total =
          (await txn.rawQuery(
                'SELECT COALESCE(SUM(amount_minor),0) AS total FROM hw_transactions',
              )).single['total']
              as int;
      if (total.abs() > RewardMoney.maxMinor) {
        throw const FormatException('Balance out of range');
      }
    });
  }
}
