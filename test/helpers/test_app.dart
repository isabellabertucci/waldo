import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/l10n/app_localizations.dart';

GoRouter createTestRouter({String initialLocation = '/dashboard'}) {
  return GoRouter(routes: $appRoutes, initialLocation: initialLocation);
}

Future<void> pumpTestApp(WidgetTester tester, {GoRouter? router}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: router ?? createTestRouter(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
