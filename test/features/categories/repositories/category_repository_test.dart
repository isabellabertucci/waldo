import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';

import '../../../helpers/test_app.dart';

void main() {
  late Database db;
  late CategoryRepositoryImpl repo;

  setUp(() async {
    db = await createTestDatabase();
    repo = CategoryRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryRepositoryImpl', () {
    test('insert then getAll returns the inserted category', () async {
      final before = await repo.getAll();

      await repo.insert(
        const Category(
          name: 'Groceries Test',
          createdAt: '2026-08-10T12:00:00.000',
        ),
      );

      final categories = await repo.getAll();

      expect(categories, hasLength(before.length + 1));
      expect(categories.map((c) => c.name), contains('Groceries Test'));
    });

    test('getById returns null for a non-existent id', () async {
      expect(await repo.getById(999), isNull);
    });

    test('update only changes name, not createdAt', () async {
      final id = await repo.insert(
        const Category(
          name: 'Groceries Test',
          createdAt: '2026-08-10T12:00:00.000',
        ),
      );
      final category = await repo.getById(id);

      await repo.update(
        category!.copyWith(
          name: 'Mercado',
          createdAt: '2020-01-01T00:00:00.000',
        ),
      );
      final updated = await repo.getById(id);

      expect(updated!.name, 'Mercado');
      expect(updated.createdAt, '2026-08-10T12:00:00.000');
    });

    test('update throws when the category has no id', () async {
      const categoryWithoutId = Category(
        name: 'No id',
        createdAt: '2026-08-10T12:00:00.000',
      );

      expect(
        () => repo.update(categoryWithoutId),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('delete removes a category with no transactions', () async {
      final id = await repo.insert(
        const Category(
          name: 'Groceries Test',
          createdAt: '2026-08-10T12:00:00.000',
        ),
      );

      await repo.delete(id);

      expect(await repo.getById(id), isNull);
    });
  });
}
