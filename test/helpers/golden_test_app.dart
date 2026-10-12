import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// Wraps [child] in the real app's providers, theme and localizations.
/// [isBalanceHidden] starts with the eye toggle on.
Widget wrapForGolden({
  required Widget child,
  required Database db,
  required Brightness brightness,
  bool isBalanceHidden = false,
}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWith((ref) async => db),
      clockProvider.overrideWithValue(() => DateTime(2026, 10, 8, 12)),
      if (isBalanceHidden)
        balanceHiddenProvider.overrideWith(_HiddenBalance.new),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

class _HiddenBalance extends BalanceHidden {
  @override
  bool build() => true;
}
