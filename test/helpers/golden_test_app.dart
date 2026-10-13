import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// Wraps [child] in the real app's providers, theme and localizations.
/// [isBalanceHidden] starts with the eye toggle on; [locale] is the app language.
Widget wrapForGolden({
  required Widget child,
  required Database db,
  required Brightness brightness,
  bool isBalanceHidden = false,
  Locale locale = const Locale('en'),
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
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

/// Makes the tests in this scope run on a Portuguese phone, so money formats
/// as pt_PT (`1 234,50 €`); pair it with `locale: Locale('pt')`.
void usePortuguesePhone() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .localeTestValue = const Locale(
      'pt',
      'PT',
    );
  });
  tearDown(
    () => TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearLocaleTestValue(),
  );
}

class _HiddenBalance extends BalanceHidden {
  @override
  bool build() => true;
}
