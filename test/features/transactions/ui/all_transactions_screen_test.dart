import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_row.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:waldo/core/constants/enums.dart';
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

  testWidgets('The eye in the bar hides every amount and shows it is on', (
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
        createdAt: today,
      ),
    );
    currentDb = await pumpWidgetWithProviders(
      tester,
      const AllTransactionsScreen(),
      db: db,
    );
    expect(find.textContaining('25.00'), findsOneWidget);

    await tester.tap(find.byTooltip('Hide balance'));
    await tester.pumpAndSettle();

    expect(find.textContaining('25.00'), findsNothing);
    expect(find.byTooltip('Show balance'), findsOneWidget);
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

    await tester.longPress(find.byType(TransactionRow).first);
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

    await tester.pump(const Duration(seconds: 11));
  });

  testWidgets("Opened for a month, it lists only that month's transactions "
      'from every wallet', (tester) async {
    final db = await createTestDatabase();
    final wallets = WalletRepositoryImpl(db);
    final home = await wallets.insert(
      const Wallet(name: 'Home', createdAt: '2026-08-01T12:00:00.000'),
    );
    final bank = await wallets.insert(
      const Wallet(name: 'Bank', createdAt: '2026-08-01T12:00:00.000'),
    );
    final transactions = TransactionRepositoryImpl(db);
    for (final (walletId, date, name) in [
      (home, '2026-09-03T12:00:00.000', 'September rent'),
      (bank, '2026-09-20T12:00:00.000', 'September salary'),
      (home, '2026-10-02T12:00:00.000', 'October rent'),
    ]) {
      await transactions.insert(
        Transaction(
          walletId: walletId,
          amount: 1000,
          type: TransactionType.expense,
          date: date,
          description: name,
          createdAt: date,
        ),
      );
    }

    currentDb = await pumpWidgetWithProviders(
      tester,
      AllTransactionsScreen(month: DateTime(2026, 9)),
      db: db,
    );

    expect(find.text('Transactions in September 2026'), findsOneWidget);
    expect(find.text('September rent'), findsOneWidget);
    expect(find.text('September salary'), findsOneWidget);
    expect(find.text('October rent'), findsNothing);
  });
}
