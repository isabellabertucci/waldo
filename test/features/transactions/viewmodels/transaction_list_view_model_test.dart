import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_list_view_model.dart';

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
}
