import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_list_view_model.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/features/wallets/viewmodels/wallets_summary_view_model.dart';

import '../../../helpers/test_app.dart';

void main() {
  late Database db;
  late ProviderContainer container;
  late int walletId;

  setUp(() async {
    db = await createTestDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) async => db),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 15, 12)),
      ],
    );
    walletId = await WalletRepositoryImpl(
      db,
    ).insert(const Wallet(name: 'Cash', createdAt: '2026-08-01T12:00:00.000'));
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<int> addTransaction(int amount, TransactionType type, String date) {
    return TransactionRepositoryImpl(db).insert(
      Transaction(
        walletId: walletId,
        amount: amount,
        type: type,
        date: date,
        createdAt: '${date}T12:00:00.000',
      ),
    );
  }

  test(
    'sums only this month: net = income - expense, kept as a % of income',
    () async {
      await addTransaction(100000, TransactionType.income, '2026-10-02');
      await addTransaction(25000, TransactionType.expense, '2026-10-10');
      // Last month - must be ignored.
      await addTransaction(99999, TransactionType.income, '2026-09-30');

      final summary = await container.read(
        walletsSummaryViewModelProvider.future,
      );

      expect(summary.netThisMonth, 75000);
      expect(summary.keptPercent, 75);
    },
  );

  test('keptPercent is null when there is no income this month', () async {
    await addTransaction(25000, TransactionType.expense, '2026-10-10');

    final summary = await container.read(
      walletsSummaryViewModelProvider.future,
    );

    expect(summary.netThisMonth, -25000);
    expect(summary.keptPercent, isNull);
  });

  test('deleting a transaction refreshes the summary', () async {
    await addTransaction(100000, TransactionType.income, '2026-10-02');
    final expenseId = await addTransaction(
      25000,
      TransactionType.expense,
      '2026-10-10',
    );
    container.listen(walletsSummaryViewModelProvider, (_, _) {});
    final list = transactionListViewModelProvider(walletId: walletId);
    await container.read(list.future);

    expect(
      (await container.read(
        walletsSummaryViewModelProvider.future,
      )).netThisMonth,
      75000,
    );

    await container.read(list.notifier).confirmDelete(expenseId);

    expect(
      (await container.read(
        walletsSummaryViewModelProvider.future,
      )).netThisMonth,
      100000,
    );
  });
}
