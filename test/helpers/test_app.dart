import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/database/migrations.dart' as migrations;
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/l10n/app_localizations.dart';

GoRouter createTestRouter({String initialLocation = '/dashboard'}) {
  return GoRouter(routes: $appRoutes, initialLocation: initialLocation);
}

Future<Database> createTestDatabase() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfiNoIsolate.openDatabase(
    inMemoryDatabasePath,
  );
  await db.execute('PRAGMA foreign_keys = ON');
  await migrations.onCreate(db, migrations.migrations.length);
  return db;
}

Future<Database> pumpTestApp(
  WidgetTester tester, {
  GoRouter? router,
  Database? db,
}) async {
  final testDb = db ?? await createTestDatabase();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWith((ref) async => testDb)],
      child: MaterialApp.router(
        routerConfig: router ?? createTestRouter(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();

  return testDb;
}

Future<Database> pumpWidgetWithProviders(
  WidgetTester tester,
  Widget widget, {
  Database? db,
}) async {
  final testDb = db ?? await createTestDatabase();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWith((ref) async => testDb)],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: widget,
      ),
    ),
  );
  await tester.pumpAndSettle();

  return testDb;
}
