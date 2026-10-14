import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/features/categories/ui/categories_screen.dart';

import '../helpers/golden_test_app.dart';
import '../helpers/test_app.dart';

void main() {
  late Database db;

  setUp(() async {
    db = await createTestDatabase();
  });

  tearDown(() => db.close());

  goldenTest(
    'Categories screen - light',
    fileName: 'categories_screen_light',
    constraints: BoxConstraints.tight(const Size(460, 1400)),
    builder: () => wrapForGolden(
      child: const CategoriesScreen(),
      db: db,
      brightness: Brightness.light,
    ),
  );

  goldenTest(
    'Categories screen - dark',
    fileName: 'categories_screen_dark',
    constraints: BoxConstraints.tight(const Size(460, 1400)),
    builder: () => wrapForGolden(
      child: const CategoriesScreen(),
      db: db,
      brightness: Brightness.dark,
    ),
  );
}
