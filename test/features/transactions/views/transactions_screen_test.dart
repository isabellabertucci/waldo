import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/features/transactions/views/transactions_screen.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

import '../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<int> pumpTransactionsScreen(WidgetTester tester) async {
    final db = await createTestDatabase();
    final walletRepo = WalletRepositoryImpl(db);
    final walletId = await walletRepo.insert(
      const Wallet(name: 'Test Wallet', createdAt: '2026-08-10T12:00:00.000'),
    );

    currentDb = await pumpWidgetWithProviders(
      tester,
      TransactionsScreen(walletId: walletId),
      db: db,
    );
    return walletId;
  }

  Future<void> createTransaction(
    WidgetTester tester, {
    String amount = '10.00',
    String description = '',
  }) async {
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount'),
      amount,
    );
    if (description.isNotEmpty) {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'),
        description,
      );
    }

    await tester.tap(find.text('Date'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('Shows empty state when there are no transactions', (
    tester,
  ) async {
    await pumpTransactionsScreen(tester);

    expect(find.text('No transactions yet'), findsOneWidget);
  });

  testWidgets('Creating a transaction adds it to the list', (tester) async {
    await pumpTransactionsScreen(tester);
    await createTransaction(tester, amount: '25.00', description: 'Groceries');

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('No transactions yet'), findsNothing);
  });

  testWidgets('Shows the default description when none is given', (
    tester,
  ) async {
    await pumpTransactionsScreen(tester);
    await createTransaction(tester, amount: '15.00');

    expect(find.text('Transaction'), findsOneWidget);
  });

  testWidgets('Shows validation error when amount is empty', (tester) async {
    await pumpTransactionsScreen(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Date'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Amount is required'), findsOneWidget);
  });

  testWidgets('Shows validation error when date is not selected', (
    tester,
  ) async {
    await pumpTransactionsScreen(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount'),
      '10.00',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Date is required'), findsOneWidget);
  });
}
