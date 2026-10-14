import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_form_view_model.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';

import '../../../helpers/test_app.dart';

void main() {
  late Database db;
  late ProviderContainer container;

  setUp(() async {
    db = await createTestDatabase();
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWith((ref) async => db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('creating a wallet through the form invalidates the dashboard, '
      'so totalBalance reflects it without a manual refresh', () async {
    final before = await container.read(dashboardViewModelProvider.future);
    expect(before.totalBalance, 0);

    final formNotifier = container.read(
      walletFormViewModelProvider(null).notifier,
    );
    formNotifier.updateName('Checking');
    formNotifier.updateBalance('100.00');
    await formNotifier.save(null);

    final after = await container.read(dashboardViewModelProvider.future);
    expect(after.totalBalance, 10000);
  });

  test(
    'deleting a wallet invalidates the dashboard so totalBalance drops',
    () async {
      final formNotifier = container.read(
        walletFormViewModelProvider(null).notifier,
      );
      formNotifier.updateName('Checking');
      formNotifier.updateBalance('50.00');
      await formNotifier.save(null);

      final withWallet = await container.read(
        dashboardViewModelProvider.future,
      );
      expect(withWallet.totalBalance, 5000);

      final repo = await container.read(walletRepositoryProvider.future);
      final inserted = (await repo.getAll()).first;

      await container
          .read(walletListViewModelProvider().notifier)
          .confirmDelete(inserted.id!);

      final afterDelete = await container.read(
        dashboardViewModelProvider.future,
      );
      expect(afterDelete.totalBalance, 0);
    },
  );

  test(
    'category lines plus uncategorized always add up to monthlyExpense',
    () async {
      final fixed = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => db),
          clockProvider.overrideWithValue(() => DateTime(2026, 10, 15, 12)),
        ],
      );
      addTearDown(fixed.dispose);
      final walletId = await WalletRepositoryImpl(db).insert(
        const Wallet(name: 'Cash', createdAt: '2026-08-01T12:00:00.000'),
      );
      final groceries = (await CategoryRepositoryImpl(
        db,
      ).getAll()).firstWhere((c) => c.type == CategoryType.groceries);
      final transactions = TransactionRepositoryImpl(db);
      await transactions.insert(
        Transaction(
          walletId: walletId,
          categoryId: groceries.id,
          amount: 7000,
          type: TransactionType.expense,
          date: '2026-10-05',
          createdAt: '2026-10-05T12:00:00.000',
        ),
      );
      await transactions.insert(
        Transaction(
          walletId: walletId,
          amount: 3000,
          type: TransactionType.expense,
          date: '2026-10-06',
          createdAt: '2026-10-06T12:00:00.000',
        ),
      );

      final data = await fixed.read(dashboardViewModelProvider.future);

      expect(data.monthlyExpense, 10000);
      expect(data.spendingByCategory.single.amount, 7000);
      expect(data.uncategorizedSpending, 3000);
    },
  );

  group('SelectedDashboardMonth', () {
    ProviderContainer containerAt(DateTime now) {
      final c = ProviderContainer(
        overrides: [clockProvider.overrideWithValue(() => now)],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('defaults to the current month', () {
      final c = containerAt(DateTime(2026, 10, 15, 12));
      expect(c.read(selectedDashboardMonthProvider), DateTime(2026, 10));
    });

    test('select keeps only the year and month', () {
      final c = containerAt(DateTime(2026, 10, 15, 12));
      c
          .read(selectedDashboardMonthProvider.notifier)
          .select(DateTime(2026, 8, 20, 13, 45));
      expect(c.read(selectedDashboardMonthProvider), DateTime(2026, 8));
    });
  });
}
