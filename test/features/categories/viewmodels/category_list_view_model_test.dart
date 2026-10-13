import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/features/categories/viewmodels/category_list_view_model.dart';

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
      overrides: [categoryRepositoryProvider.overrideWith((ref) => mockRepo)],
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

    notifier.restoreCategory();
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
      // Fetched once on build, once more after the add.
      await container.read(categoryListViewModelProvider.future);
      verify(() => mockRepo.getAll()).called(2);
    },
  );

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
}
