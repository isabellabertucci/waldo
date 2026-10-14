import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/features/categories/viewmodels/category_form_view_model.dart';

class MockCategoryRepository extends Mock implements ICategoryRepository {}

void main() {
  late MockCategoryRepository mockRepo;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const Category(name: '', createdAt: '2026-08-10T12:00:00.000'),
    );
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

  test('build(null) starts with an empty name', () {
    final state = container.read(categoryFormViewModelProvider(null));

    expect(state.name, '');
  });

  test('build(category) pre-fills the name from the existing category', () {
    const category = Category(
      id: 1,
      name: 'Groceries',
      createdAt: '2026-08-10T12:00:00.000',
    );

    final state = container.read(categoryFormViewModelProvider(category));

    expect(state.name, 'Groceries');
  });

  test(
    'save with an empty name returns false and never calls insert',
    () async {
      final notifier = container.read(
        categoryFormViewModelProvider(null).notifier,
      );

      final success = await notifier.save(null);

      expect(success, isFalse);
      verifyNever(() => mockRepo.insert(any()));
    },
  );

  test('save with a valid name calls insert', () async {
    when(() => mockRepo.insert(any())).thenAnswer((_) async => 1);

    final notifier = container.read(
      categoryFormViewModelProvider(null).notifier,
    );
    notifier.updateName('Groceries');

    final success = await notifier.save(null);

    expect(success, isTrue);
    verify(() => mockRepo.insert(any())).called(1);
  });

  test('save while editing calls update, not insert', () async {
    const existing = Category(
      id: 5,
      name: 'Old name',
      createdAt: '2026-08-10T12:00:00.000',
    );
    when(() => mockRepo.update(any())).thenAnswer((_) async {});

    final notifier = container.read(
      categoryFormViewModelProvider(existing).notifier,
    );
    notifier.updateName('New name');

    final success = await notifier.save(existing);

    expect(success, isTrue);
    verify(() => mockRepo.update(any())).called(1);
    verifyNever(() => mockRepo.insert(any()));
  });
}
