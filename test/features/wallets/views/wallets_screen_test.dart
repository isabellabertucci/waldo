import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/features/wallets/views/wallets_screen.dart';

import '../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<void> pumpWalletsScreen(WidgetTester tester, {Database? db}) async {
    currentDb = await pumpWidgetWithProviders(
      tester,
      const WalletsScreen(),
      db: db,
    );
  }

  Future<void> createWallet(WidgetTester tester, String name) async {
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), name);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('Shows empty state when there are no wallets', (tester) async {
    await pumpWalletsScreen(tester);

    expect(find.text('No wallets yet'), findsOneWidget);
  });

  testWidgets('Creating a wallet adds it to the list', (tester) async {
    await pumpWalletsScreen(tester);
    await createWallet(tester, 'Cash');

    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('No wallets yet'), findsNothing);
  });

  testWidgets('Shows validation error when name is empty', (tester) async {
    await pumpWalletsScreen(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);
  });

  testWidgets('Deleting a wallet shows a confirmation dialog first', (
    tester,
  ) async {
    await pumpWalletsScreen(tester);
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
      await pumpWalletsScreen(tester);
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
    await pumpWalletsScreen(tester);
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
      await pumpWalletsScreen(tester);
      await createWallet(tester, 'Cash');

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Cash'), findsNothing);

      await tester.pump(const Duration(seconds: 6));

      await pumpWalletsScreen(tester, db: currentDb);

      expect(find.text('Cash'), findsNothing);
      expect(find.text('No wallets yet'), findsOneWidget);
    },
  );
}
