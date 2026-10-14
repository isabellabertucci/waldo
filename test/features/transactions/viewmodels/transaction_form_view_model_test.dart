import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_form_view_model.dart';

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

void main() {
  late MockTransactionRepository mockRepo;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const Transaction(
        walletId: 0,
        amount: 0,
        type: TransactionType.expense,
        date: '',
        createdAt: '2026-08-10T12:00:00.000',
      ),
    );
  });

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

  test('build(null) starts empty with the default type', () {
    final state = container.read(transactionFormViewModelProvider(null));

    expect(state.amount, '');
    expect(state.type, TransactionType.expense);
    expect(state.date, isNull);
    expect(state.walletId, isNull);
  });

  test('build(null) with initialWalletId pre-fills the wallet', () {
    final state = container.read(
      transactionFormViewModelProvider(null, initialWalletId: 7),
    );

    expect(state.walletId, 7);
  });

  test('build(transaction) pre-fills fields from the existing transaction', () {
    final transaction = const Transaction(
      id: 1,
      walletId: 5,
      amount: 1050,
      type: TransactionType.income,
      date: '2026-08-10',
      description: 'Salary',
      createdAt: '2026-08-10T12:00:00.000',
    );

    final state = container.read(transactionFormViewModelProvider(transaction));

    expect(state.amount, '10.50');
    expect(state.type, TransactionType.income);
    expect(state.walletId, 5);
    expect(state.description, 'Salary');
  });

  test('save returns false when wallet is missing', () async {
    final notifier = container.read(
      transactionFormViewModelProvider(null).notifier,
    );
    notifier.updateAmount('10.00');
    notifier.updateDate(DateTime(2026, 8, 10));

    final success = await notifier.save(null);

    expect(success, isFalse);
    verifyNever(() => mockRepo.insert(any()));
  });

  test('save returns false when date is missing', () async {
    final notifier = container.read(
      transactionFormViewModelProvider(null, initialWalletId: 1).notifier,
    );
    notifier.updateAmount('10.00');

    final success = await notifier.save(null);

    expect(success, isFalse);
    verifyNever(() => mockRepo.insert(any()));
  });

  test('save returns false when amount is not positive', () async {
    final notifier = container.read(
      transactionFormViewModelProvider(null, initialWalletId: 1).notifier,
    );
    notifier.updateAmount('0');
    notifier.updateDate(DateTime(2026, 8, 10));

    final success = await notifier.save(null);

    expect(success, isFalse);
    verifyNever(() => mockRepo.insert(any()));
  });

  test('save with valid data calls insert with parsed cents', () async {
    when(() => mockRepo.insert(any())).thenAnswer((_) async => 1);

    final notifier = container.read(
      transactionFormViewModelProvider(null, initialWalletId: 1).notifier,
    );
    notifier.updateAmount('25.50');
    notifier.updateDate(DateTime(2026, 8, 10));
    notifier.updateType(TransactionType.income);

    final success = await notifier.save(null);

    expect(success, isTrue);
    verify(() => mockRepo.insert(any())).called(1);
  });

  test('save while editing calls update, not insert', () async {
    final existing = const Transaction(
      id: 9,
      walletId: 1,
      amount: 500,
      type: TransactionType.expense,
      date: '2026-08-01',
      createdAt: '2026-08-01T12:00:00.000',
    );
    when(() => mockRepo.update(any())).thenAnswer((_) async {});

    final notifier = container.read(
      transactionFormViewModelProvider(existing).notifier,
    );
    notifier.updateAmount('7.00');

    final success = await notifier.save(existing);

    expect(success, isTrue);
    verify(() => mockRepo.update(any())).called(1);
    verifyNever(() => mockRepo.insert(any()));
  });
}
