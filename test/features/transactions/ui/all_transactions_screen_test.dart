import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/transactions/ui/all_transactions_screen.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

import '../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  testWidgets('Deleting a row hides it at once and Undo brings it back', (
    tester,
  ) async {
    final db = await createTestDatabase();
    final walletId = await WalletRepositoryImpl(db).insert(
      const Wallet(name: 'Test Wallet', createdAt: '2026-08-10T12:00:00.000'),
    );
    final today = DateTime.now().toIso8601String();
    await TransactionRepositoryImpl(db).insert(
      Transaction(
        walletId: walletId,
        amount: 2500,
        type: TransactionType.expense,
        date: today,
        description: 'Weekly shop',
        createdAt: today,
      ),
    );

    currentDb = await pumpWidgetWithProviders(
      tester,
      const AllTransactionsScreen(),
      db: db,
    );
    expect(find.text('Weekly shop'), findsOneWidget);

    await tester.tap(find.byIcon(AppIcons.more));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    // The confirmation dialog's own Delete button.
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(textOutsideSnackBar('Weekly shop'), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Weekly shop'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
  });
}
