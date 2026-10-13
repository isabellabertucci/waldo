import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/transactions/viewmodels/pending_transaction_deletes.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_form_view_model.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_list_view_model.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

import '../../../helpers/test_app.dart';

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

void main() {
  late MockTransactionRepository mockRepo;
  late ProviderContainer container;

  const older = Transaction(
    walletId: 1,
    amount: 100,
    type: TransactionType.income,
    date: '2026-08-01',
    createdAt: '2026-08-01T00:00:00.000',
  );
  const newer = Transaction(
    walletId: 1,
    amount: 200,
    type: TransactionType.income,
    date: '2026-08-03',
    createdAt: '2026-08-03T00:00:00.000',
  );

  setUp(() {
    mockRepo = MockTransactionRepository();
    container = ProviderContainer(
      overrides: [
        transactionRepositoryProvider.overrideWith((ref) => mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'with no sortOrder, defaults to desc and calls repo.getByWallet(desc)',
    () async {
      when(
        () => mockRepo.getByWallet(1, sortOrder: SortOrder.desc),
      ).thenAnswer((_) async => [newer, older]);

      final transactions = await container.read(
        transactionListViewModelProvider(walletId: 1).future,
      );

      expect(transactions.first.date, '2026-08-03');
      verify(
        () => mockRepo.getByWallet(1, sortOrder: SortOrder.desc),
      ).called(1);
    },
  );

  test(
    'with sortOrder asc, calls repo.getByWallet(asc) and returns oldest first',
    () async {
      when(
        () => mockRepo.getByWallet(1, sortOrder: SortOrder.asc),
      ).thenAnswer((_) async => [older, newer]);

      final transactions = await container.read(
        transactionListViewModelProvider(
          walletId: 1,
          sortOrder: SortOrder.asc,
        ).future,
      );

      expect(transactions.first.date, '2026-08-01');
      verify(() => mockRepo.getByWallet(1, sortOrder: SortOrder.asc)).called(1);
    },
  );

  group('the "all transactions" list (no walletId)', () {
    late Database db;
    late ProviderContainer real;
    late int walletId;
    late int transactionId;

    setUp(() async {
      db = await createTestDatabase();
      real = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWith((ref) async => db)],
      );
      walletId = await WalletRepositoryImpl(db).insert(
        const Wallet(name: 'Cash', createdAt: '2026-08-01T12:00:00.000'),
      );
      transactionId = await TransactionRepositoryImpl(db).insert(
        Transaction(
          walletId: walletId,
          amount: 500,
          type: TransactionType.expense,
          date: '2026-08-10',
          createdAt: '2026-08-10T12:00:00.000',
        ),
      );
      // Both lists on screen, like opening a transaction from "All".
      real.listen(transactionListViewModelProvider(), (_, _) {});
      real.listen(
        transactionListViewModelProvider(walletId: walletId),
        (_, _) {},
      );
      await real.read(transactionListViewModelProvider().future);
      await real.read(
        transactionListViewModelProvider(walletId: walletId).future,
      );
    });

    tearDown(() async {
      real.dispose();
      await db.close();
    });

    test('is refreshed after a transaction is edited', () async {
      final existing = (await real.read(
        transactionListViewModelProvider().future,
      )).single;
      final form = real.read(
        transactionFormViewModelProvider(existing).notifier,
      );
      form.updateAmount('7.00');
      await form.save(existing);

      final all = await real.read(transactionListViewModelProvider().future);
      expect(all.single.amount, 700);
    });

    test('is refreshed after a transaction is deleted', () async {
      await real
          .read(transactionListViewModelProvider(walletId: walletId).notifier)
          .confirmDelete(transactionId);

      final all = await real.read(transactionListViewModelProvider().future);
      expect(all, isEmpty);
    });

    test('hiding it in the wallet\'s list hides it from "All" and the '
        'dashboard too', () async {
      real
          .read(selectedDashboardMonthProvider.notifier)
          .select(DateTime(2026, 8));
      real
          .read(transactionListViewModelProvider(walletId: walletId).notifier)
          .hideTransaction(transactionId);

      expect(
        await real.read(transactionListViewModelProvider().future),
        isEmpty,
      );
      final dashboard = await real.read(dashboardViewModelProvider.future);
      expect(dashboard.recentTransactions, isEmpty);
      expect(dashboard.monthlyExpense, 0);
    });

    test('a refetch inside the Undo window does not bring it back', () async {
      real
          .read(transactionListViewModelProvider(walletId: walletId).notifier)
          .hideTransaction(transactionId);
      // What another delete or a save does to every list.
      real.invalidate(transactionListViewModelProvider);

      expect(
        await real.read(transactionListViewModelProvider().future),
        isEmpty,
      );
      expect(
        await real.read(
          transactionListViewModelProvider(walletId: walletId).future,
        ),
        isEmpty,
      );
    });

    test('restoring puts it back in every list', () async {
      final notifier = real.read(
        transactionListViewModelProvider(walletId: walletId).notifier,
      );
      notifier.hideTransaction(transactionId);
      notifier.restoreTransaction(transactionId);

      final all = await real.read(transactionListViewModelProvider().future);
      expect(all.single.id, transactionId);
      expect(
        (await real.read(
          transactionListViewModelProvider(walletId: walletId).future,
        )).single.id,
        transactionId,
      );
    });

    test('confirming clears it from the pending set', () async {
      final notifier = real.read(
        transactionListViewModelProvider(walletId: walletId).notifier,
      );
      notifier.hideTransaction(transactionId);
      await notifier.confirmDelete(transactionId);

      expect(real.read(pendingTransactionDeletesProvider), isEmpty);
      expect(
        await real.read(transactionListViewModelProvider().future),
        isEmpty,
      );
    });
  });
}
