# sqflite_android 2.4.3: transaction-aware single-worker dispatch

Source: `sqflite_android` 2.4.3, `android/src/main/java/com/tekartik/sqflite/DatabaseWorkerPool.java`.
Upstream SHA-256: `468dc8a589901fe419d4bd489bd7aea3482033ecd5cee7f95464825cbb0ae109`.
License: [BSD-2-Clause](LICENSE), copyright Alexandre Roux Tekartik.

WishLoop has a UI engine and a short-lived headless widget engine. With independent
connections to the same SQLite file, upstream's one-worker queue can dispatch the
second connection's BEGIN before the first connection has sent COMMIT. The worker
then waits on a lock whose release is queued behind it. Adding workers alone does
not guarantee safety because a worker reserved by a transaction can still receive
another database's task.

This local source overlay preserves the default single worker and SQLite plugin:

- Queue tasks in arrival order when no transaction owns the worker.
- While a transaction is active, execute that connection's tasks until commit,
  rollback or close; then resume the other connections.
- Treat a closed database as outside a transaction so cleanup cannot retain the
  worker's ownership.

No database/schema/ledger changes and no global pub-cache mutation. `android/build.gradle`
excludes only the original source file and compiles this copy in its place. The hash
guard deliberately fails if the upstream implementation changes. Re-evaluate/remove
the overlay when upgrading the plugin.

Regression: `flutter test integration_test/widget_concurrency_test.dart --flavor f_dev -d emulator-5554`.
This intentionally holds one transaction open while two other connections attempt
transactions, then performs twelve rounds of competing reads, currency updates and
idempotent completions. Closing one connection must leave the others usable.
