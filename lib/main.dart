import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:corner_radius_plugin/corner_radius_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/core/utils/localization_delegates.dart';

import 'package:waldo/features/transactions/ui/transaction_shortcuts.dart';

import 'core/constants/app_constants.dart';
import 'core/logging/app_logger.dart';
import 'core/logging/provider_observer.dart';
import 'core/router/app_router_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/common.dart';
import 'core/theme/dynamic_type_scaler.dart';
import 'l10n/app_localizations.dart';

final _log = Logger('waldo');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the Android system bars, so they show the app's background.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  initLogging();
  _log.info('App starting');
  installGlobalErrorLoggers();
  // The screen's corner radius, read before the first frame so every sheet
  // already curves with it. A phone that doesn't say counts as square.
  try {
    await CornerRadiusPlugin.init();
  } on Exception catch (e) {
    _log.warning('Screen corner radius unavailable', e);
  }

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

/// On iOS, titles grow less than body text, as in Apple's apps. Android 14+
/// already scales that way itself.
Widget _withDynamicType(BuildContext context, Widget child) {
  if (defaultTargetPlatform != TargetPlatform.iOS) return child;
  final media = MediaQuery.of(context);
  return MediaQuery(
    data: media.copyWith(textScaler: DynamicTypeScaler.from(media.textScaler)),
    child: child,
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
      AsyncValue(:final value?) => _toThemeMode(value.isDarkMode),
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
        value: Common.getSystemBarsStyle(
          context.appColors,
          Theme.of(context).brightness,
        ),
        child: TransactionShortcuts(
          router: router,
          child: _withDynamicType(context, child!),
        ),
      ),
    );
  }
}
