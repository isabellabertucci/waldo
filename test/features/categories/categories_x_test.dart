import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/l10n/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Category builtIn(int id, CategoryType type) => Category(
    id: id,
    name: type.name,
    isDefault: true,
    type: type,
    createdAt: '2026-01-01T00:00:00.000',
  );

  Category custom(int id, String name, String createdAt) =>
      Category(id: id, name: name, createdAt: createdAt);

  test('Built-ins come first A-Z with Others closing them, then the newest '
      'custom ones', () {
    final ordered = [
      custom(10, 'Apples', '2026-03-01T09:00:00.000'),
      builtIn(1, CategoryType.others),
      builtIn(2, CategoryType.transportation),
      custom(11, 'Zoo', '2026-05-01T09:00:00.000'),
      builtIn(3, CategoryType.education),
      custom(12, 'Books', '2026-04-01T09:00:00.000'),
    ].inDisplayOrder(l10n);

    expect(ordered.map((c) => c.displayName(l10n)), [
      'Education',
      'Transportation',
      'Others',
      'Zoo',
      'Books',
      'Apples',
    ]);
  });

  test('Custom ones added at the same moment list the last one first', () {
    const createdAt = '2026-04-01T09:00:00.000';
    final ordered = [
      custom(20, 'First', createdAt),
      custom(21, 'Second', createdAt),
    ].inDisplayOrder(l10n);

    expect(ordered.map((c) => c.name), ['Second', 'First']);
  });
}
