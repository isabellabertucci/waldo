import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:waldo/features/wallets/ui/wallets_screen.dart';

import '../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<void> pumpWalletsScreen(WidgetTester tester, {Database? db}) async {
    // The top and the list are taller than the default 800x600 test
    // surface.
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
    await tester.tap(find.byKey(const Key('newWalletAction')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('walletNameField')), name);
    await tester.tap(find.text('Create wallet'));
    await tester.pumpAndSettle();
  }

  /// Long-presses the wallet's row and taps "Delete" in its actions, which
  /// triggers the confirmation dialog to open.
  Future<void> openDeleteMenu(WidgetTester tester) async {
    await tester.longPress(find.text('Test Wallet'));
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
    await tester.tap(find.byKey(const Key('newWalletAction')));
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

  testWidgets('The actions have accessible names', (tester) async {
    await pumpWalletsScreen(tester);
    await createWallet(tester, 'Cash');

    expect(find.bySemanticsLabel('Hide'), findsOneWidget);
    expect(find.bySemanticsLabel('Filter'), findsOneWidget);
    expect(find.bySemanticsLabel('New wallet'), findsOneWidget);
  });

  testWidgets('Search and the type filter narrow the list', (tester) async {
    await pumpWalletsScreen(tester);
    await createWallet(tester, 'Groceries');
    await createWallet(tester, 'Holiday');

    await tester.enterText(find.byType(TextField), 'holi');
    await tester.pumpAndSettle();
    expect(find.text('Holiday'), findsOneWidget);
    expect(find.text('Groceries'), findsNothing);
    expect(find.text('1 of 2'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.byKey(const Key('walletsFilterAction')));
    await tester.pumpAndSettle();
    // New wallets are cash; none is credit.
    await tester.tap(find.text('Credit card'));
    await tester.pumpAndSettle();
    expect(find.text('No wallets found'), findsOneWidget);
    expect(find.text('0 of 2'), findsOneWidget);

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Holiday'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
  });

  testWidgets('Shows validation error when name is empty', (tester) async {
    await pumpWalletsScreen(tester);

    await tester.tap(find.byKey(const Key('newWalletAction')));
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

      await tester.pump(const Duration(seconds: 11));
    },
  );

  testWidgets('Deleting a wallet says how many transactions go with it', (
    tester,
  ) async {
    await pumpWalletsScreen(tester);
    await createWallet(tester, 'Test Wallet');
    final walletId = (await WalletRepositoryImpl(
      currentDb!,
    ).getAll()).single.id!;
    final transactions = TransactionRepositoryImpl(currentDb!);
    for (var i = 0; i < 3; i++) {
      await transactions.insert(
        Transaction(
          walletId: walletId,
          amount: 100,
          type: TransactionType.expense,
          date: '2026-08-10',
          createdAt: '2026-08-10T12:00:00.000',
        ),
      );
    }

    await openDeleteMenu(tester);

    expect(
      find.text(
        'This will permanently delete "Test Wallet" and its 3 transactions.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

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

    await tester.pump(const Duration(seconds: 11));
    expect(find.text('Test Wallet'), findsOneWidget);
  });

  testWidgets(
    'Not tapping Undo permanently deletes the wallet after 10 seconds',
    (tester) async {
      await pumpWalletsScreen(tester);
      await createWallet(tester, 'Test Wallet');

      await openDeleteMenu(tester);
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(textOutsideSnackBar('Test Wallet'), findsNothing);

      await tester.pump(const Duration(seconds: 11));

      await pumpWalletsScreen(tester, db: currentDb);

      expect(textOutsideSnackBar('Test Wallet'), findsNothing);
      expect(find.text('No wallets yet'), findsOneWidget);
    },
  );

  testWidgets('A group leads with its richest wallet, and its header says '
      'how many and what they hold', (tester) async {
    final db = await createTestDatabase();
    final repo = WalletRepositoryImpl(db);
    for (final (name, cents) in [
      ('Small', 1000),
      ('Big', 5000),
      ('Mid', 2500),
    ]) {
      await repo.insert(
        Wallet(
          name: name,
          type: WalletType.cash,
          startingBalance: cents,
          currentBalance: cents,
          createdAt: '2026-08-10T12:00:00.000',
        ),
      );
    }
    await pumpWalletsScreen(tester, db: db);

    expect(find.text('CASH · 3'), findsOneWidget);
    // The group's total, beside its name (the top shows it too).
    final header = find
        .ancestor(of: find.text('CASH · 3'), matching: find.byType(Row))
        .first;
    expect(
      find.descendant(of: header, matching: find.textContaining('85.00')),
      findsOneWidget,
    );
    final top = [
      for (final name in ['Big', 'Mid', 'Small'])
        tester.getTopLeft(find.text(name)).dy,
    ];
    expect(top, orderedEquals([...top]..sort()), reason: 'richest first');
  });

  testWidgets('Scrolled past the top, a slim bar keeps the eye in reach', (
    tester,
  ) async {
    final db = await createTestDatabase();
    final repo = WalletRepositoryImpl(db);
    for (var i = 0; i < 20; i++) {
      await repo.insert(
        Wallet(name: 'Wallet $i', createdAt: '2026-08-10T12:00:00.000'),
      );
    }
    await pumpWalletsScreen(tester, db: db);
    final bar = find.byKey(const Key('sheetPageBar'));
    expect(bar, findsNothing);

    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(bar, findsOneWidget);
    await tester.tap(
      find.descendant(of: bar, matching: find.byTooltip('Hide balance')),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: bar, matching: find.byTooltip('Show balance')),
      findsOneWidget,
    );
  });

  testWidgets('Every wallet gets its own row, even past the third one', (
    tester,
  ) async {
    await pumpWalletsScreen(tester);
    await createWallet(tester, 'First');
    await createWallet(tester, 'Second');
    await createWallet(tester, 'Third');
    await createWallet(tester, 'Fourth');
    await createWallet(tester, 'Fifth');

    // Every row is built, even past the old stack's three cards.
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    expect(find.text('Third'), findsOneWidget);
    expect(find.text('Fourth'), findsOneWidget);
    expect(find.text('Fifth'), findsOneWidget);
  });
}
