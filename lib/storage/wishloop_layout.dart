// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:shared_preferences/shared_preferences.dart';

/// Local display preferences; account data stays in SQLite.
class WishLoopLayout {
  final bool compact;
  final bool hobbiesFirst;
  const WishLoopLayout({this.compact = true, this.hobbiesFirst = false});
  static Future<WishLoopLayout> load() async {
    final prefs = await SharedPreferences.getInstance();
    return WishLoopLayout(
      compact: prefs.getBool('wishloop.compact') ?? true,
      hobbiesFirst: prefs.getBool('wishloop.hobbiesFirst') ?? false,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setBool('wishloop.compact', compact) ||
        !await prefs.setBool('wishloop.hobbiesFirst', hobbiesFirst)) {
      throw StateError('Could not save home layout');
    }
  }
}
