import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/features/wallets/ui/wallets_screen.dart';

import '../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<void> pumpWalletsScreen(WidgetTester tester, {Database? db}) async {
    // The fixed total bar + card stack is taller than the default 800x600
    // test surface.
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    currentDb = await pumpWidgetWithProviders(
      tester,
      const WalletsScreen(),
      db: db,
    );
  }

  Future<void> createWallet(WidgetTester tester, String name) async {
    // The add button is the header's dashed-stitch pill now, not a
    // FloatingActionButton.
    await tester.tap(find.byType(DashedStitchButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('walletNameField')), name);
    await tester.tap(find.text('Create wallet'));
    await tester.pumpAndSettle();
  }

  /// Opens the wallet card's overflow menu ("⋯") and taps "Delete", which
  /// triggers the confirmation dialog to open.
  Future<void> openDeleteMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(AppIcons.more));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
  }

  testWidgets('Shows empty state when there are no wallets', (tester) async {
    await pumpWalletsScreen(tester);

    expect(find.text('No wallets yet'), findsOneWidget);
  });

  testWidgets('Creating a wallet adds it to the list', (tester) async {
    await pumpWalletsScreen(tester);
    await createWallet(tester, 'Test Wallet');

    expect(find.text('Test Wallet'), findsOneWidget);
    expect(find.text('No wallets yet'), findsNothing);
  });

  testWidgets('Starting balance accepts a comma as the decimal separator', (
    tester,
  ) async {
    await pumpWalletsScreen(tester);
    await tester.tap(find.byType(DashedStitchButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('walletNameField')), 'Cash');
    // The decimal key on a Portuguese numeric keyboard types ','.
    await tester.enterText(
      find.byKey(const Key('walletBalanceField')),
      '10,50',
    );
    await tester.tap(find.text('Create wallet'));
    await tester.pumpAndSettle();

    expect(find.text(r'$10.50'), findsWidgets);
  });

  testWidgets('The add and eye buttons have accessible names', (tester) async {
    await pumpWalletsScreen(tester);
    await tester.tap(find.byType(DashedStitchButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('walletNameField')), 'Cash');
    await tester.tap(find.text('Create wallet'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('New wallet'), findsOneWidget);
    expect(find.byTooltip('Hide balance'), findsOneWidget);
  });

  testWidgets('Shows validation error when name is empty', (tester) async {
    await pumpWalletsScreen(tester);

    await tester.tap(find.byIcon(AppIcons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create wallet'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);
  });

  testWidgets('Deleting a wallet shows a confirmation dialog first', (
    tester,
  ) async {
    await pumpWalletsScreen(tester);
    await createWallet(tester, 'Test Wallet');

    await openDeleteMenu(tester);

    expect(find.text('Delete wallet?'), findsOneWidget);
    expect(find.text('Test Wallet'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Test Wallet'), findsOneWidget);
  });

  testWidgets(
    'Confirming delete hides the wallet immediately and shows a snackbar',
    (tester) async {
      await pumpWalletsScreen(tester);
      await createWallet(tester, 'Test Wallet');

      await openDeleteMenu(tester);
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(textOutsideSnackBar('Test Wallet'), findsNothing);
      expect(find.text('Wallet deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.pump(const Duration(seconds: 6));
    },
  );

  testWidgets('Tapping Undo restores the wallet to the list', (tester) async {
    await pumpWalletsScreen(tester);
    await createWallet(tester, 'Test Wallet');

    await openDeleteMenu(tester);
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(textOutsideSnackBar('Test Wallet'), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Test Wallet'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    expect(find.text('Test Wallet'), findsOneWidget);
  });

  testWidgets(
    'Not tapping Undo permanently deletes the wallet after 5 seconds',
    (tester) async {
      await pumpWalletsScreen(tester);
      await createWallet(tester, 'Test Wallet');

      await openDeleteMenu(tester);
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(textOutsideSnackBar('Test Wallet'), findsNothing);

      await tester.pump(const Duration(seconds: 6));

      await pumpWalletsScreen(tester, db: currentDb);

      expect(textOutsideSnackBar('Test Wallet'), findsNothing);
      expect(find.text('No wallets yet'), findsOneWidget);
    },
  );

  testWidgets('Every wallet gets its own card, even past the third one', (
    tester,
  ) async {
    await pumpWalletsScreen(tester);
    await createWallet(tester, 'First');
    await createWallet(tester, 'Second');
    await createWallet(tester, 'Third');
    await createWallet(tester, 'Fourth');
    await createWallet(tester, 'Fifth');

    // Every card is built, even off-screen ones (the "cards past 3 vanish" bug).
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    expect(find.text('Third'), findsOneWidget);
    expect(find.text('Fourth'), findsOneWidget);
    expect(find.text('Fifth'), findsOneWidget);
  });
}
