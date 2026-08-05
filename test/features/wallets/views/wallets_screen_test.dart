import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/database/migrations.dart' as migrations;
import 'package:waldo/features/wallets/views/wallets_screen.dart';
import 'package:waldo/l10n/app_localizations.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<Database> createTestDatabase() async {
    final db = await databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
    );
    await db.execute('PRAGMA foreign_keys = ON');
    await migrations.onCreate(db, migrations.migrations.length);
    currentDb = db;
    return db;
  }

  Future<void> pumpWalletsScreen(WidgetTester tester, Database db) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWith((ref) async => db)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WalletsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> createWallet(WidgetTester tester, String name) async {
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Name'), name);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('Shows empty state when there are no wallets', (tester) async {
    final db = await createTestDatabase();

    await pumpWalletsScreen(tester, db);

    expect(find.text('No wallets yet'), findsOneWidget);
  });

  testWidgets('Creating a wallet adds it to the list', (tester) async {
    final db = await createTestDatabase();

    await pumpWalletsScreen(tester, db);
    await createWallet(tester, 'Cash');

    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('No wallets yet'), findsNothing);
  });

  testWidgets('Shows validation error when name is empty', (tester) async {
    final db = await createTestDatabase();

    await pumpWalletsScreen(tester, db);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);
  });

  testWidgets('Deleting a wallet shows a confirmation dialog first', (
    tester,
  ) async {
    final db = await createTestDatabase();

    await pumpWalletsScreen(tester, db);
    await createWallet(tester, 'Cash');

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(find.text('Delete wallet?'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Cash'), findsOneWidget);
  });

  testWidgets(
    'Confirming delete hides the wallet immediately and shows a snackbar',
    (tester) async {
      final db = await createTestDatabase();

      await pumpWalletsScreen(tester, db);
      await createWallet(tester, 'Cash');

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Cash'), findsNothing);
      expect(find.text('Wallet deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.pump(const Duration(seconds: 6));
    },
  );

  testWidgets('Tapping Undo restores the wallet to the list', (tester) async {
    final db = await createTestDatabase();

    await pumpWalletsScreen(tester, db);
    await createWallet(tester, 'Cash');

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Cash'), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Cash'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    expect(find.text('Cash'), findsOneWidget);
  });

  testWidgets(
    'Not tapping Undo permanently deletes the wallet after 5 seconds',
    (tester) async {
      final db = await createTestDatabase();

      await pumpWalletsScreen(tester, db);
      await createWallet(tester, 'Cash');

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Cash'), findsNothing);

      await tester.pump(const Duration(seconds: 6));

      await pumpWalletsScreen(tester, db);

      expect(find.text('Cash'), findsNothing);
      expect(find.text('No wallets yet'), findsOneWidget);
    },
  );
}
