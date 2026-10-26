import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/core/utils/localization_delegates.dart';

import 'core/constants/app_constants.dart';
import 'core/logging/app_logger.dart';
import 'core/logging/provider_observer.dart';
import 'core/router/app_router_provider.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

final _log = Logger('waldo');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the Android system bars, so they show the app's background.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  initLogging();
  _log.info('App starting');
  installGlobalErrorLoggers();

  runApp(
    const ProviderScope(
      observers: [if (!kReleaseMode) AppProviderObserver()],
      child: MyApp(),
    ),
  );
}

ThemeMode _toThemeMode(bool? isDarkMode) {
  return switch (isDarkMode) {
    null => ThemeMode.system,
    true => ThemeMode.dark,
    false => ThemeMode.light,
  };
}

SystemUiOverlayStyle _systemBarsStyle(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final icons = isDark ? Brightness.light : Brightness.dark;
  final transparent = context.appColors.transparent;
  return SystemUiOverlayStyle(
    statusBarColor: transparent,
    systemNavigationBarColor: transparent,
    // Otherwise Android adds its own grey scrim behind the 3 buttons.
    systemNavigationBarContrastEnforced: false,
    statusBarIconBrightness: icons,
    systemNavigationBarIconBrightness: icons,
    statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final preferencesAsync = ref.watch(preferencesViewModelProvider);

    // Default to system theme while preferences are still loading,
    // so there's no flash of the wrong theme on cold start.
    final themeMode = switch (preferencesAsync) {
      AsyncData(:final value) => _toThemeMode(value.isDarkMode),
      _ => ThemeMode.system,
    };

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: appName,
      routerConfig: router,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: _systemBarsStyle(context),
        child: child!,
      ),
    );
  }
}
