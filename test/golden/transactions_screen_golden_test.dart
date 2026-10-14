import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/features/transactions/ui/transactions_screen.dart';

import '../helpers/golden_seed.dart';
import '../helpers/golden_test_app.dart';
import '../helpers/test_app.dart';

void main() {
  late Database db;
  late GoldenSeed seed;

  setUp(() async {
    db = await createTestDatabase();
    seed = await seedGoldenData(db);
  });

  tearDown(() => db.close());

  goldenTest(
    'Per-wallet transactions screen - light',
    fileName: 'transactions_screen_light',
    constraints: BoxConstraints.tight(const Size(460, 1400)),
    builder: () => wrapForGolden(
      child: TransactionsScreen(walletId: seed.walletId),
      db: db,
      brightness: Brightness.light,
    ),
  );

  goldenTest(
    'Per-wallet transactions screen - dark',
    fileName: 'transactions_screen_dark',
    constraints: BoxConstraints.tight(const Size(460, 1400)),
    builder: () => wrapForGolden(
      child: TransactionsScreen(walletId: seed.walletId),
      db: db,
      brightness: Brightness.dark,
    ),
  );
}
