import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_list_view_model.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/features/wallets/viewmodels/pending_wallet_deletes.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/features/wallets/viewmodels/wallets_summary_view_model.dart';

import '../../../helpers/test_app.dart';

class MockWalletRepository extends Mock implements IWalletRepository {}

void main() {
  late MockWalletRepository mockRepo;
  late ProviderContainer container;

  const older = Wallet(name: 'Older', createdAt: '2026-08-01T00:00:00.000');
  const newer = Wallet(name: 'Newer', createdAt: '2026-08-03T00:00:00.000');

  setUp(() {
    mockRepo = MockWalletRepository();
    container = ProviderContainer(
      overrides: [walletRepositoryProvider.overrideWith((ref) => mockRepo)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'with no sortOrder, defaults to desc and calls repo.getAll(desc)',
    () async {
      when(
        () => mockRepo.getAll(sortOrder: SortOrder.desc),
      ).thenAnswer((_) async => [newer, older]);

      final wallets = await container.read(
        walletListViewModelProvider().future,
      );

      expect(wallets.first.name, 'Newer');
      verify(() => mockRepo.getAll(sortOrder: SortOrder.desc)).called(1);
    },
  );

  test(
    'with sortOrder asc, calls repo.getAll(asc) and returns oldest first',
    () async {
      when(
        () => mockRepo.getAll(sortOrder: SortOrder.asc),
      ).thenAnswer((_) async => [older, newer]);

      final wallets = await container.read(
        walletListViewModelProvider(sortOrder: SortOrder.asc).future,
      );

      expect(wallets.first.name, 'Older');
      verify(() => mockRepo.getAll(sortOrder: SortOrder.asc)).called(1);
    },
  );

  group('a wallet inside its Undo window', () {
    late Database db;
    late ProviderContainer real;
    late int homeId;

    setUp(() async {
      db = await createTestDatabase();
      real = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => db),
          clockProvider.overrideWithValue(() => DateTime(2026, 8, 20)),
        ],
      );
      final wallets = WalletRepositoryImpl(db);
      final transactions = TransactionRepositoryImpl(db);
      homeId = await wallets.insert(
        const Wallet(
          name: 'Home',
          currentBalance: 10000,
          createdAt: '2026-08-01T00:00:00.000',
        ),
      );
      final bankId = await wallets.insert(
        const Wallet(
          name: 'Bank',
          currentBalance: 5000,
          createdAt: '2026-08-02T00:00:00.000',
        ),
      );
      for (final (walletId, amount, type) in [
        (homeId, 2000, TransactionType.income),
        (bankId, 500, TransactionType.expense),
      ]) {
        await transactions.insert(
          Transaction(
            walletId: walletId,
            amount: amount,
            type: type,
            date: '2026-08-10',
            createdAt: '2026-08-10T12:00:00.000',
          ),
        );
      }
    });

    tearDown(() async {
      real.dispose();
      await db.close();
    });

    // Total, wallet count, August income, August net, transactions listed.
    Future<(int, int, int, int, int)> numbers() async {
      final dashboard = await real.read(dashboardViewModelProvider.future);
      final month = await real.read(walletsSummaryViewModelProvider.future);
      final all = await real.read(transactionListViewModelProvider().future);
      return (
        dashboard.totalBalance,
        dashboard.walletCount,
        dashboard.monthlyIncome,
        month.netThisMonth,
        all.length,
      );
    }

    test('is gone from every total and list, and Undo puts it back', () async {
      expect(await numbers(), (16500, 2, 2000, 1500, 2));

      final notifier = real.read(walletListViewModelProvider().notifier);
      await real.read(walletListViewModelProvider().future);
      expect(notifier.hideWallet(homeId), isTrue);
      // Only Bank and its 500 expense are left.
      expect(await numbers(), (4500, 1, 0, -500, 1));
      expect(
        (await real.read(
          walletListViewModelProvider().future,
        )).map((w) => w.name),
        ['Bank'],
      );

      notifier.restoreWallet(homeId);
      expect(await numbers(), (16500, 2, 2000, 1500, 2));
    });

    test('confirming deletes it and clears the pending set', () async {
      final notifier = real.read(walletListViewModelProvider().notifier);
      await real.read(walletListViewModelProvider().future);
      notifier.hideWallet(homeId);
      await notifier.confirmDelete(homeId);

      expect(real.read(pendingWalletDeletesProvider), isEmpty);
      expect(await numbers(), (4500, 1, 0, -500, 1));
    });
  });
}
