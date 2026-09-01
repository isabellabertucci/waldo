import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/features/categories/models/category.dart';

void main() {
  group('Category mapping', () {
    test('toMap/fromMap round-trip preserves all fields', () {
      const category = Category(
        id: 1,
        name: 'Groceries',
        createdAt: '2026-08-10T12:00:00.000',
      );

      final map = category.toMap();
      final restored = Category.fromMap(map);

      expect(restored, category);
    });

    test('toMap stores the name as-is', () {
      const category = Category(
        name: 'Netflix',
        createdAt: '2026-08-10T12:00:00.000',
      );

      expect(category.toMap()['name'], 'Netflix');
    });

    test('fromMap parses a null id as a new category', () {
      final map = {
        'id': null,
        'name': 'Bus fare',
        'created_at': '2026-08-10T12:00:00.000',
      };

      expect(Category.fromMap(map).id, isNull);
    });
  });
}
