import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/features/transactions/ui/all_transactions_screen.dart';

import '../helpers/golden_seed.dart';
import '../helpers/golden_test_app.dart';
import '../helpers/test_app.dart';

void main() {
  late Database db;

  setUp(() async {
    db = await createTestDatabase();
    await seedGoldenData(db);
  });

  tearDown(() => db.close());

  goldenTest(
    'All transactions screen - light',
    fileName: 'all_transactions_screen_light',
    constraints: BoxConstraints.tight(const Size(460, 1200)),
    builder: () => wrapForGolden(
      child: const AllTransactionsScreen(),
      db: db,
      brightness: Brightness.light,
    ),
  );

  goldenTest(
    'All transactions screen - dark',
    fileName: 'all_transactions_screen_dark',
    constraints: BoxConstraints.tight(const Size(460, 1200)),
    builder: () => wrapForGolden(
      child: const AllTransactionsScreen(),
      db: db,
      brightness: Brightness.dark,
    ),
  );
}
