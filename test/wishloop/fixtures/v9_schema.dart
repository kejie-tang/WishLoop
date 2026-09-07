// Frozen v1.0.0 / database v9 schema, for real upgrade regression tests.
// Copyright 2026 Hobby Wallet contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:sqflite/sqflite.dart';

/// Called inside sqflite's onCreate/onUpgrade transaction. Never removes
/// existing habits, records, groups, settings, or sync metadata.
abstract final class LegacyWalletV9Schema {
  static Future<void> migrate(DatabaseExecutor db) async {
    final columns = (await db.rawQuery(
      'PRAGMA table_info(mh_habits)',
    )).map((row) => row['name']).toSet();
    const additions = {
      'hobby_emoji': "TEXT NOT NULL DEFAULT '🌱'",
      'reward_minor':
          'INTEGER NOT NULL DEFAULT 0 CHECK(reward_minor BETWEEN 0 AND 999999999999)',
      'duration_minutes':
          'INTEGER NOT NULL DEFAULT 30 CHECK(duration_minutes BETWEEN 1 AND 1440)',
      'weekday_mask':
          'INTEGER NOT NULL DEFAULT 127 CHECK(weekday_mask BETWEEN 1 AND 127)',
    };
    for (final entry in additions.entries) {
      if (!columns.contains(entry.key)) {
        await db.execute(
          'ALTER TABLE mh_habits ADD COLUMN ${entry.key} ${entry.value}',
        );
      }
    }
    for (final sql in _statements) {
      await db.execute(sql);
    }
  }

  static const _statements = [
    '''CREATE TABLE IF NOT EXISTS hw_checkins (
      id TEXT PRIMARY KEY NOT NULL,
      habit_uuid TEXT NOT NULL REFERENCES mh_habits(uuid),
      day INTEGER NOT NULL,
      record_uuid TEXT NOT NULL UNIQUE REFERENCES mh_records(uuid),
      reward_minor INTEGER NOT NULL CHECK(reward_minor BETWEEN 0 AND 999999999999),
      completion_value REAL NOT NULL,
      completed_at INTEGER NOT NULL,
      previous_record TEXT,
      UNIQUE(habit_uuid, day)
    )''',
    '''CREATE TABLE IF NOT EXISTS hw_transactions (
      id TEXT PRIMARY KEY NOT NULL,
      amount_minor INTEGER NOT NULL CHECK(typeof(amount_minor) = 'integer' AND abs(amount_minor) <= 999999999999),
      type TEXT NOT NULL CHECK(type IN ('EARN','SPEND','ADJUSTMENT')),
      source_type TEXT NOT NULL CHECK(source_type IN ('CHECK_IN','WISHLIST','MANUAL')),
      source_id TEXT NOT NULL,
      title TEXT NOT NULL,
      timestamp INTEGER NOT NULL,
      currency TEXT NOT NULL DEFAULT 'CNY' CHECK(currency = 'CNY'),
      UNIQUE(source_type, source_id),
      CHECK((type = 'EARN' AND source_type = 'CHECK_IN' AND amount_minor >= 0)
        OR (type = 'SPEND' AND source_type = 'WISHLIST' AND amount_minor < 0)
        OR (type = 'ADJUSTMENT' AND source_type = 'MANUAL' AND amount_minor != 0))
    )''',
    'CREATE INDEX IF NOT EXISTS hw_transactions_time ON hw_transactions(timestamp DESC)',
    '''CREATE TABLE IF NOT EXISTS hw_wishlist (
      id TEXT PRIMARY KEY NOT NULL,
      name TEXT NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 100),
      target_price_minor INTEGER NOT NULL CHECK(typeof(target_price_minor) = 'integer' AND target_price_minor BETWEEN 1 AND 999999999999),
      emoji TEXT NOT NULL DEFAULT '🎁',
      note TEXT NOT NULL DEFAULT '',
      created_at INTEGER NOT NULL,
      status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active','redeemed')),
      is_primary INTEGER NOT NULL DEFAULT 0 CHECK(is_primary IN (0,1))
    )''',
    "CREATE UNIQUE INDEX IF NOT EXISTS hw_one_primary ON hw_wishlist(is_primary) WHERE is_primary = 1 AND status = 'active'",
    '''CREATE TABLE IF NOT EXISTS hw_redemptions (
      id TEXT PRIMARY KEY NOT NULL,
      wishlist_id TEXT NOT NULL UNIQUE REFERENCES hw_wishlist(id),
      transaction_id TEXT NOT NULL UNIQUE REFERENCES hw_transactions(id),
      title TEXT NOT NULL,
      amount_minor INTEGER NOT NULL CHECK(amount_minor BETWEEN 1 AND 999999999999),
      timestamp INTEGER NOT NULL
    )''',
    // Legacy record editors/importers cannot leave rewards for an undone record.
    '''CREATE TRIGGER IF NOT EXISTS hw_record_changed AFTER UPDATE ON mh_records
    WHEN EXISTS(SELECT 1 FROM hw_checkins WHERE record_uuid = NEW.uuid
      AND (NEW.record_type != 1 OR NEW.record_value != completion_value))
    BEGIN
      DELETE FROM hw_transactions WHERE source_type = 'CHECK_IN' AND source_id IN
        (SELECT id FROM hw_checkins WHERE record_uuid = NEW.uuid);
      DELETE FROM hw_checkins WHERE record_uuid = NEW.uuid;
    END''',
    '''CREATE TRIGGER IF NOT EXISTS hw_record_deleted BEFORE DELETE ON mh_records
    BEGIN
      DELETE FROM hw_transactions WHERE source_type = 'CHECK_IN' AND source_id IN
        (SELECT id FROM hw_checkins WHERE record_uuid = OLD.uuid);
      DELETE FROM hw_checkins WHERE record_uuid = OLD.uuid;
    END''',
  ];
}
