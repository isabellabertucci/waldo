import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/features/categories/viewmodels/category_list_view_model.dart';
import 'package:waldo/features/categories/viewmodels/pending_category_deletes.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

import '../../../helpers/test_app.dart';

class MockCategoryRepository extends Mock implements ICategoryRepository {}

void main() {
  late MockCategoryRepository mockRepo;
  late ProviderContainer container;

  const groceries = Category(
    id: 1,
    name: 'Groceries',
    isDefault: true,
    createdAt: '2026-08-01T00:00:00.000',
  );
  const custom = Category(
    id: 2,
    name: 'My Category',
    createdAt: '2026-08-02T00:00:00.000',
  );

  setUpAll(() {
    registerFallbackValue(custom);
  });

  setUp(() {
    mockRepo = MockCategoryRepository();
    container = ProviderContainer(
      overrides: [
        categoryRepositoryProvider.overrideWith((ref) => mockRepo),
        // A fixed clock, so createdAt is checkable.
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 13, 9, 30)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('build returns the categories from repo.getAll()', () async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => [groceries, custom]);

    final categories = await container.read(
      categoryListViewModelProvider.future,
    );

    expect(categories, [groceries, custom]);
  });

  test('categoriesById is empty while loading, then keyed by id', () async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => [groceries, custom]);
    // Kept listened, as a screen would, so it follows the list as it loads.
    container.listen(categoriesByIdProvider, (_, _) {});

    expect(container.read(categoriesByIdProvider), isEmpty);
    await container.read(categoryListViewModelProvider.future);
    expect(container.read(categoriesByIdProvider), {1: groceries, 2: custom});
  });

  test('hideCategory removes the category from state optimistically', () async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => [groceries, custom]);
    await container.read(categoryListViewModelProvider.future);

    final notifier = container.read(categoryListViewModelProvider.notifier);
    final result = notifier.hideCategory(custom.id!);

    expect(result, isTrue);
    expect(container.read(categoryListViewModelProvider).value, [groceries]);
    verifyNever(() => mockRepo.delete(any()));
  });

  test('confirmDelete calls repo.delete with the category id', () async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => [groceries, custom]);
    when(() => mockRepo.delete(custom.id!)).thenAnswer((_) async {});
    await container.read(categoryListViewModelProvider.future);

    final notifier = container.read(categoryListViewModelProvider.notifier);
    notifier.hideCategory(custom.id!);
    await notifier.confirmDelete(custom.id!);

    verify(() => mockRepo.delete(custom.id!)).called(1);
  });

  test('restoreCategory re-fetches and brings the category back', () async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => [groceries, custom]);
    await container.read(categoryListViewModelProvider.future);

    final notifier = container.read(categoryListViewModelProvider.notifier);
    notifier.hideCategory(custom.id!);
    expect(container.read(categoryListViewModelProvider).value, [groceries]);

    notifier.restoreCategory(custom.id!);
    final restored = await container.read(categoryListViewModelProvider.future);

    expect(restored, [groceries, custom]);
  });

  test(
    'add inserts a trimmed custom category and refreshes the list',
    () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => [groceries]);
      when(() => mockRepo.insert(any())).thenAnswer((_) async => 3);
      await container.read(categoryListViewModelProvider.future);

      await container
          .read(categoryListViewModelProvider.notifier)
          .add('  Gym ');

      final inserted =
          verify(() => mockRepo.insert(captureAny())).captured.single
              as Category;
      expect(inserted.name, 'Gym');
      expect(inserted.isDefault, isFalse);
      expect(
        inserted.createdAt,
        '2026-10-13T09:30:00.000',
        reason: 'stamped by the clock',
      );
      // Fetched once on build, once more after the add.
      await container.read(categoryListViewModelProvider.future);
      verify(() => mockRepo.getAll()).called(2);
    },
  );

  test('two adds fired together insert the category once', () async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => [groceries]);
    when(() => mockRepo.insert(any())).thenAnswer(
      (_) => Future.delayed(const Duration(milliseconds: 10), () => 3),
    );
    container.listen(categoryListViewModelProvider, (_, _) {});
    await container.read(categoryListViewModelProvider.future);
    final notifier = container.read(categoryListViewModelProvider.notifier);

    // The + button and the keyboard's done key at the same moment.
    await Future.wait([notifier.add('Gym'), notifier.add('Gym')]);

    verify(() => mockRepo.insert(any())).called(1);
  });

  test('an add that throws does not block the next one', () async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => [groceries]);
    var calls = 0;
    when(() => mockRepo.insert(any())).thenAnswer((_) async {
      // The first insert fails; the lock must still open for the retry.
      if (calls++ == 0) throw StateError('db');
      return 3;
    });
    container.listen(categoryListViewModelProvider, (_, _) {});
    await container.read(categoryListViewModelProvider.future);
    final notifier = container.read(categoryListViewModelProvider.notifier);

    await expectLater(notifier.add('Gym'), throwsA(isA<StateError>()));
    await notifier.add('Gym');

    verify(() => mockRepo.insert(any())).called(2);
  });

  test('add lets a duplicate-name error reach the screen', () async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => [groceries]);
    when(
      () => mockRepo.insert(any()),
    ).thenThrow(DuplicateCategoryNameException());
    await container.read(categoryListViewModelProvider.future);

    expect(
      () => container.read(categoryListViewModelProvider.notifier).add('Gym'),
      throwsA(isA<DuplicateCategoryNameException>()),
    );
  });

  test('add returns the new category\'s id', () async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => [groceries]);
    when(() => mockRepo.insert(any())).thenAnswer((_) async => 7);
    await container.read(categoryListViewModelProvider.future);

    final id = await container
        .read(categoryListViewModelProvider.notifier)
        .add('Gym');

    expect(id, 7);
  });

  test('rename saves the new name and fetches the list again', () async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => [groceries, custom]);
    when(() => mockRepo.rename(custom.id!, 'Gym')).thenAnswer((_) async {});
    container.listen(categoryListViewModelProvider, (_, _) {});
    await container.read(categoryListViewModelProvider.future);

    await container
        .read(categoryListViewModelProvider.notifier)
        .rename(custom.id!, '  Gym ');

    verify(() => mockRepo.rename(custom.id!, 'Gym')).called(1);
    await container.read(categoryListViewModelProvider.future);
    verify(() => mockRepo.getAll()).called(2);
  });

  test('rename lets a duplicate-name error reach the screen', () async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => [groceries, custom]);
    when(
      () => mockRepo.rename(custom.id!, 'Groceries'),
    ).thenThrow(DuplicateCategoryNameException());
    await container.read(categoryListViewModelProvider.future);

    expect(
      () => container
          .read(categoryListViewModelProvider.notifier)
          .rename(custom.id!, 'Groceries'),
      throwsA(isA<DuplicateCategoryNameException>()),
    );
  });

  test('transactionCount asks the repository', () async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => [groceries, custom]);
    when(
      () => mockRepo.countTransactions(custom.id!),
    ).thenAnswer((_) async => 4);

    final count = await container
        .read(categoryListViewModelProvider.notifier)
        .transactionCount(custom.id!);

    expect(count, 4);
  });

  test(
    'a failed confirmDelete reaches the screen, so it can restore',
    () async {
      when(
        () => mockRepo.getAll(),
      ).thenAnswer((_) async => [groceries, custom]);
      when(() => mockRepo.delete(custom.id!)).thenThrow(StateError('db'));
      await container.read(categoryListViewModelProvider.future);

      expect(
        () => container
            .read(categoryListViewModelProvider.notifier)
            .confirmDelete(custom.id!),
        throwsA(isA<StateError>()),
      );
    },
  );

  test('during its Undo window a category\'s spending and rows already show '
      'as Others, and Undo puts it back', () async {
    final db = await createTestDatabase();
    addTearDown(db.close);
    final real = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) async => db),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 20)),
      ],
    );
    addTearDown(real.dispose);
    real.listen(categoriesByIdProvider, (_, _) {});
    final gymId = await CategoryRepositoryImpl(
      db,
    ).insert(const Category(name: 'Gym', createdAt: '2026-10-01T00:00:00.000'));
    final walletId = await WalletRepositoryImpl(
      db,
    ).insert(const Wallet(name: 'Cash', createdAt: '2026-10-01T00:00:00.000'));
    await TransactionRepositoryImpl(db).insert(
      Transaction(
        walletId: walletId,
        categoryId: gymId,
        amount: 3000,
        type: TransactionType.expense,
        date: '2026-10-10',
        createdAt: '2026-10-10T12:00:00.000',
      ),
    );

    // The receipt's lines, and the name a row shows for the transaction.
    Future<(String, String?)> shown() async {
      final dashboard = await real.read(dashboardViewModelProvider.future);
      await real.read(categoryListViewModelProvider.future);
      return (
        dashboard.spendingByCategory.map((s) => s.category.name).join(', '),
        real.read(categoriesByIdProvider)[gymId]?.name,
      );
    }

    expect(await shown(), ('Gym', 'Gym'));

    final notifier = real.read(categoryListViewModelProvider.notifier);
    expect(notifier.hideCategory(gymId), isTrue);
    expect(await shown(), ('Others', 'Others'));

    notifier.restoreCategory(gymId);
    expect(await shown(), ('Gym', 'Gym'));
    expect(real.read(pendingCategoryDeletesProvider), isEmpty);
  });
}
