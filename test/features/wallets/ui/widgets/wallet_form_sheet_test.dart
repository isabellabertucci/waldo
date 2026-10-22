import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/features/wallets/ui/widgets/wallet_form_sheet.dart';

import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import '../../../../helpers/sheet_keyboard.dart';
import '../../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<void> openNewWalletSheet(WidgetTester tester) async {
    // A portrait phone, so the whole sheet fits.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    currentDb = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showWalletFormSheet(context),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> tapCreate(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Create wallet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create wallet'));
    await tester.pumpAndSettle();
  }

  testWidgets('The name is marked required, and read out as required', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await openNewWalletSheet(tester);

    expect(find.text('Name *', findRichText: true), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Name, required')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('A name taken after the sheet opened shows on the sheet', (
    tester,
  ) async {
    await openNewWalletSheet(tester);
    await tester.enterText(find.byKey(const Key('walletNameField')), 'Cash');
    // Saved elsewhere meanwhile: the name check passes, the database refuses.
    await currentDb!.insert(
      'wallets',
      const Wallet(name: 'Cash', createdAt: '2026-08-10T12:00:00.000').toMap(),
    );

    await tapCreate(tester);

    expect(
      find.text('A wallet with this name already exists').hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('A failed wallet save shows its error on the sheet', (
    tester,
  ) async {
    await openNewWalletSheet(tester);
    await tester.enterText(find.byKey(const Key('walletNameField')), 'Cash');
    // No table to write to, so the insert throws.
    await currentDb!.execute('DROP TABLE wallets');

    await tapCreate(tester);

    expect(
      find.text("Couldn't save the wallet. Nothing was changed.").hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets(
    'On a small phone the sheet stays below the status bar and scrolls',
    (tester) async {
      // iPhone SE: 375x667 with a 20pt status bar.
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      tester.view.padding = const FakeViewPadding(top: 20);
      addTearDown(tester.view.reset);

      currentDb = await pumpWidgetWithProviders(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showWalletFormSheet(context),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getTopLeft(find.byType(WalletFormSheet)).dy,
        greaterThanOrEqualTo(20),
      );

      await tester.ensureVisible(find.text('Create wallet'));
      await tester.pumpAndSettle();
      expect(find.text('Create wallet').hitTestable(), findsOneWidget);
    },
  );

  testWidgets('On a small Android phone with large text, dragging the sheet '
      'reveals the button above the navigation bar', (tester) async {
    // 360x640 with a 24dp status bar and a 48dp three-button nav bar.
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    currentDb = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showWalletFormSheet(context),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.drag(find.text('TYPE'), const Offset(0, -400));
    await tester.pumpAndSettle();

    // The content really overflowed, so the drag scrolled it.
    final scrollable = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byType(WalletFormSheet),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(scrollable.position.pixels, greaterThan(0));

    final button = find.text('Create wallet');
    expect(button.hitTestable(), findsOneWidget);
    expect(tester.getBottomLeft(button).dy, lessThanOrEqualTo(640 - 48));
  });

  testWidgets('With the keyboard open the sheet scrolls instead of '
      'overflowing', (tester) async {
    useSmallAndroidPhone(tester);
    currentDb = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showWalletFormSheet(context),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await expectSheetScrollsWithKeyboard(
      tester,
      field: find.byKey(const Key('walletNameField')),
      sheet: find.byType(WalletFormSheet),
      lastButton: find.text('Create wallet'),
    );
  });

  testWidgets('The name stops at 50 characters and shows a counter', (
    tester,
  ) async {
    currentDb = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showWalletFormSheet(context),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('walletNameField')), 'a' * 60);
    await tester.pump();
    expect(find.text('50/50'), findsOneWidget);
  });

  /// A button that opens the sheet, over a database with one "Pocket cash".
  Future<Wallet> pumpWithOneWallet(
    WidgetTester tester, {
    bool editIt = false,
  }) async {
    // A portrait phone, so the save button is on screen.
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await createTestDatabase();
    final repo = WalletRepositoryImpl(db);
    final id = await repo.insert(
      const Wallet(name: 'Pocket cash', createdAt: '2026-08-04T12:00:00.000'),
    );
    final wallet = (await repo.getById(id))!;
    currentDb = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                showWalletFormSheet(context, wallet: editIt ? wallet : null),
            child: const Text('open'),
          ),
        ),
      ),
      db: db,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return wallet;
  }

  testWidgets('A name another wallet uses is flagged, ignoring case', (
    tester,
  ) async {
    await pumpWithOneWallet(tester);

    await tester.enterText(
      find.byKey(const Key('walletNameField')),
      'pocket CASH',
    );
    await tester.tap(find.text('Create wallet'));
    await tester.pumpAndSettle();

    expect(find.text('A wallet with this name already exists'), findsOne);
    expect(
      await WalletRepositoryImpl(currentDb!).getCount(),
      1,
      reason: 'nothing saved',
    );
  });

  testWidgets('Editing a wallet keeps its own name without a warning', (
    tester,
  ) async {
    await pumpWithOneWallet(tester, editIt: true);

    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('A wallet with this name already exists'), findsNothing);
    expect(find.text('Save changes'), findsNothing, reason: 'sheet closed');
  });
}
