import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:waldo/core/router/app_router.dart';

GoRouter createTestRouter({String initialLocation = '/dashboard'}) {
  return GoRouter(routes: $appRoutes, initialLocation: initialLocation);
}

Future<void> pumpTestApp(WidgetTester tester, {GoRouter? router}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(routerConfig: router ?? createTestRouter()),
    ),
  );
  await tester.pumpAndSettle();
}
