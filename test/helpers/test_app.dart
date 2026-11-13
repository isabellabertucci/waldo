import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/database/migrations.dart' as migrations;
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/utils/localization_delegates.dart';
import 'package:waldo/core/widgets/stretch_pill.dart';

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
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationsDelegates,
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
  Locale locale = const Locale('en'),
  ThemeData? theme,

  /// Pins "now", for a screen that shows the current month.
  DateTime? now,
}) async {
  final testDb = db ?? await createTestDatabase();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) async => testDb),
        if (now != null) clockProvider.overrideWithValue(() => now),
      ],
      child: MaterialApp(
        theme: theme ?? AppTheme.light,
        locale: locale,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: widget,
      ),
    ),
  );
  await tester.pumpAndSettle();

  return testDb;
}

/// [text] anywhere but a snackbar, so an undo bar naming a deleted item
/// doesn't count as the item still being on screen.
Finder textOutsideSnackBar(String text) => find.byElementPredicate(
  (element) =>
      element.widget is Text &&
      (element.widget as Text).data == text &&
      element.findAncestorWidgetOfExactType<SnackBar>() == null,
  description: 'text "$text" outside a snackbar',
);

/// Records each haptic the app plays, by type, for the rest of the test.
List<Object?> recordHaptics(WidgetTester tester) {
  final haptics = <Object?>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') haptics.add(call.arguments);
      return null;
    },
  );
  return haptics;
}

/// Where the [StretchPill] on screen painted its pill, in its own
/// coordinates.
Rect paintedStretchPill(WidgetTester tester) {
  late RRect pill;
  expect(
    tester.renderObject(
      find
          .descendant(
            of: find.byType(StretchPill),
            matching: find.byType(CustomPaint),
          )
          .first,
    ),
    paints..something((method, arguments) {
      if (method != #drawRRect) return false;
      pill = arguments.first as RRect;
      return true;
    }),
  );
  return pill.outerRect;
}
