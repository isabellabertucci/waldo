import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/transactions/views/transaction_detail_screen.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

import '../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<(int walletId, int transactionId)> pumpDetailScreen(
    WidgetTester tester, {
    String description = 'Groceries',
    TransactionType type = TransactionType.expense,
  }) async {
    final db = await createTestDatabase();
    final walletRepo = WalletRepositoryImpl(db);
    final walletId = await walletRepo.insert(
      const Wallet(
        name: 'Test Wallet',
        startingBalance: 1000,
        currentBalance: 1000,
        createdAt: '2026-08-10T12:00:00.000',
      ),
    );

    final transactionRepo = TransactionRepositoryImpl(db);
    final transactionId = await transactionRepo.insert(
      Transaction(
        walletId: walletId,
        amount: 500,
        type: type,
        date: '2026-08-10',
        description: description,
        createdAt: '2026-08-10T12:00:00.000',
      ),
    );

    currentDb = await pumpWidgetWithProviders(
      tester,
      TransactionDetailScreen(walletId: walletId, id: transactionId),
      db: db,
    );

    return (walletId, transactionId);
  }

  testWidgets('Shows the transaction description and amount', (tester) async {
    await pumpDetailScreen(tester, description: 'Groceries');

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.textContaining('5.00'), findsOneWidget);
  });

  testWidgets('Shows the wallet name', (tester) async {
    await pumpDetailScreen(tester);

    expect(find.textContaining('Test Wallet'), findsOneWidget);
  });

  testWidgets('Deleting a transaction shows a confirmation dialog first', (
    tester,
  ) async {
    await pumpDetailScreen(tester);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete transaction?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
  });

  testWidgets('Editing a transaction opens the edit form', (tester) async {
    await pumpDetailScreen(tester);

    await tester.tap(find.text('Edit Transaction'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Transaction'), findsWidgets);
    expect(find.widgetWithText(TextFormField, 'Amount'), findsOneWidget);
  });
}
