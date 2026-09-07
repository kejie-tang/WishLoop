// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/utils.dart';
import '../../models/app_theme_color.dart';
import '../../pages/wishloop/home.dart';
import '../../providers/app_ui/app_language.dart';
import '../../providers/app_ui/app_theme.dart';
import '../../providers/wishloop/wallet_controller.dart';
import '../../storage/db_helper_provider.dart';
import '../../storage/hobby_wallet_repository.dart';
import '../../theme/app_theme_builder.dart';
import '../../theme/color.dart';
import '../common/app_root_view.dart';

/// The focused Android entry reuses the reference app's initialized database,
/// profile, Provider objects, localization delegates and Material 3 themes.
class WishLoopApp extends StatelessWidget {
  const WishLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageViewModel>().languange;
    final (mode, color, seed) = context
        .select<AppThemeViewModel, (AppThemeType, AppThemeColor, Color)>(
          (vm) => (vm.themeType, vm.themeColor, vm.mainColor),
        );
    return ChangeNotifierProvider(
      create: (context) => WalletController(
        HobbyWalletRepository.withDatabase(
          () => context.read<DBHelperViewModel>().local.db,
        ),
      )..refresh(),
      child: AppRootView(
        themeMode: transToMaterialThemeType(mode),
        language: language,
        lightThemeBuilder: (_) => const AppThemeBuilder().buildLight(
          themeColor: color,
          themeMainColor: seed,
        ),
        darkThemeBuilder: (_) => const AppThemeBuilder().buildDark(
          themeColor: color,
          themeMainColor: seed,
        ),
        child: const WishLoopHome(),
      ),
    );
  }
}
