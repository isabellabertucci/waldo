import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// Wraps [child] with the same provider/localization/theme stack the real
/// app uses, so golden tests exercise the actual `AppTheme.light`/`.dark`
/// rather than stock Material defaults - unlike [pumpWidgetWithProviders] in
/// `test_app.dart`, which pumps a bare, untheme'd `MaterialApp` because its
/// callers only assert on text/finder presence, not pixels.
///
/// [isBalanceHidden] starts the app with the eye toggle on (every amount
/// masked).
Widget wrapForGolden({
  required Widget child,
  required Database db,
  required Brightness brightness,
  bool isBalanceHidden = false,
}) {
  return ProviderScope(
    // Root scope of each golden; the lint can't tell, as it's built in a helper.
    overrides: [
      // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
      appDatabaseProvider.overrideWith((ref) async => db),
      // ignore: riverpod_lint/scoped_providers_should_specify_dependencies
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
