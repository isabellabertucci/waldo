import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_form_view_model.dart';

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockCategoryRepository extends Mock implements ICategoryRepository {}

const _others = Category(
  id: 6,
  name: 'Others',
  isDefault: true,
  type: CategoryType.others,
  createdAt: '2026-08-10T12:00:00.000',
);

void main() {
  late MockTransactionRepository mockRepo;
  late MockCategoryRepository mockCategoryRepo;
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
    mockCategoryRepo = MockCategoryRepository();
    when(() => mockCategoryRepo.getOthers()).thenAnswer((_) async => _others);
    container = ProviderContainer(
      overrides: [
        transactionRepositoryProvider.overrideWith((ref) => mockRepo),
        categoryRepositoryProvider.overrideWith((ref) => mockCategoryRepo),
        // A fixed clock, so createdAt is checkable.
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 13, 9, 30)),
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

    final success = await notifier.save();

    expect(success, isFalse);
    verifyNever(() => mockRepo.insert(any()));
  });

  test('save returns false when date is missing', () async {
    final notifier = container.read(
      transactionFormViewModelProvider(null, initialWalletId: 1).notifier,
    );
    notifier.updateAmount('10.00');

    final success = await notifier.save();

    expect(success, isFalse);
    verifyNever(() => mockRepo.insert(any()));
  });

  test('save returns false when amount is not positive', () async {
    final notifier = container.read(
      transactionFormViewModelProvider(null, initialWalletId: 1).notifier,
    );
    notifier.updateAmount('0');
    notifier.updateDate(DateTime(2026, 8, 10));

    final success = await notifier.save();

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

    final success = await notifier.save();

    expect(success, isTrue);
    verify(() => mockRepo.insert(any())).called(1);
  });

  test('save with no category files the transaction under Others', () async {
    when(() => mockRepo.insert(any())).thenAnswer((_) async => 1);
    final notifier = container.read(
      transactionFormViewModelProvider(null, initialWalletId: 1).notifier,
    );
    notifier.updateAmount('5.00');
    notifier.updateDate(DateTime(2026, 8, 10));

    await notifier.save();

    final saved =
        verify(() => mockRepo.insert(captureAny())).captured.single
            as Transaction;
    expect(saved.categoryId, _others.id);
    expect(
      saved.createdAt,
      '2026-10-13T09:30:00.000',
      reason: 'stamped by the clock',
    );
  });

  test('save keeps a picked category', () async {
    when(() => mockRepo.insert(any())).thenAnswer((_) async => 1);
    final notifier = container.read(
      transactionFormViewModelProvider(null, initialWalletId: 1).notifier,
    );
    notifier.updateAmount('5.00');
    notifier.updateDate(DateTime(2026, 8, 10));
    notifier.updateCategoryId(2);

    await notifier.save();

    final saved =
        verify(() => mockRepo.insert(captureAny())).captured.single
            as Transaction;
    expect(saved.categoryId, 2);
    verifyNever(() => mockCategoryRepo.getOthers());
  });

  test('a second save while the first is still writing does nothing', () async {
    // A double tap on Save: both calls land before the first insert returns.
    when(() => mockRepo.insert(any())).thenAnswer(
      (_) => Future.delayed(const Duration(milliseconds: 10), () => 1),
    );
    final provider = transactionFormViewModelProvider(null, initialWalletId: 1);
    // Kept alive like the open sheet keeps it.
    container.listen(provider, (_, _) {});
    final notifier = container.read(provider.notifier);
    notifier.updateAmount('5.00');
    notifier.updateDate(DateTime(2026, 8, 10));

    final results = await Future.wait([notifier.save(), notifier.save()]);

    expect(results, [true, false]);
    verify(() => mockRepo.insert(any())).called(1);
  });

  test('a save that throws does not block the next one', () async {
    var calls = 0;
    when(() => mockRepo.insert(any())).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw StateError('db');
      return 1;
    });
    final provider = transactionFormViewModelProvider(null, initialWalletId: 1);
    container.listen(provider, (_, _) {});
    final notifier = container.read(provider.notifier);
    notifier.updateAmount('5.00');
    notifier.updateDate(DateTime(2026, 8, 10));

    await expectLater(notifier.save(), throwsA(isA<StateError>()));
    expect(await notifier.save(), isTrue);
    verify(() => mockRepo.insert(any())).called(2);
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

    final success = await notifier.save();

    expect(success, isTrue);
    verify(() => mockRepo.update(any())).called(1);
    verifyNever(() => mockRepo.insert(any()));
  });
}
