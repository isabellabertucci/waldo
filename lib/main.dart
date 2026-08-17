import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'core/constants/app_constants.dart';
import 'core/logging/app_logger.dart';
import 'core/logging/provider_observer.dart';
import 'core/router/app_router_provider.dart';
import 'l10n/app_localizations.dart';

final _log = Logger('waldo');

void main() {
  runZonedGuarded(
    () {
      initLogging();
      _log.info('App starting');
      installGlobalErrorLoggers();

      runApp(
        const ProviderScope(
          observers: [if (!kReleaseMode) AppProviderObserver()],
          child: MyApp(),
        ),
      );
    },
    (error, stackTrace) {
      _log.severe('Unhandled asynchronous error', error, stackTrace);
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: appName,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
