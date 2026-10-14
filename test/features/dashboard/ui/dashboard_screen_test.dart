import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/features/dashboard/ui/dashboard_screen.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

import '../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<void> pumpDashboardScreen(WidgetTester tester, {Database? db}) async {
    // The dashboard's content is taller than the default 800x600 test
    // surface, so a ListView further down (e.g. RecentTransactionsList)
    // never gets built by the lazy sliver unless the viewport is tall
    // enough to fit everything without scrolling.
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    currentDb = await pumpWidgetWithProviders(
      tester,
      const DashboardScreen(),
      db: db,
    );
  }

  testWidgets(
    'Shows empty states when there is no wallet or transaction data',
    (tester) async {
      await pumpDashboardScreen(tester);

      expect(find.text('My Finances'), findsOneWidget);
      expect(find.text('No spending yet this month'), findsOneWidget);
      expect(find.text('No transactions yet'), findsOneWidget);
    },
  );

  testWidgets('Shows balance, category spending, and recent transactions', (
    tester,
  ) async {
    final db = await createTestDatabase();
    final walletRepo = WalletRepositoryImpl(db);
    final categoryRepo = CategoryRepositoryImpl(db);
    final transactionRepo = TransactionRepositoryImpl(db);

    final walletId = await walletRepo.insert(
      const Wallet(
        name: 'Test Wallet',
        startingBalance: 10000,
        currentBalance: 10000,
        createdAt: '2026-08-10T12:00:00.000',
      ),
    );
    final groceriesCategory = (await categoryRepo.getAll()).firstWhere(
      (c) => c.type == CategoryType.groceries,
    );

    final today = DateTime.now().toIso8601String();
    await transactionRepo.insert(
      Transaction(
        walletId: walletId,
        categoryId: groceriesCategory.id,
        amount: 2500,
        type: TransactionType.expense,
        date: today,
        description: 'Weekly shop',
        createdAt: today,
      ),
    );

    await pumpDashboardScreen(tester, db: db);

    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('\$75.00'), findsOneWidget); // 10000 - 2500 cents
    expect(find.text('Weekly shop'), findsOneWidget);
    expect(find.text(groceriesCategory.name), findsOneWidget);
  });
}
