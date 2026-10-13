import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/features/dashboard/ui/dashboard_screen.dart';

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
    'Dashboard screen - light',
    fileName: 'dashboard_screen_light',
    constraints: BoxConstraints.tight(const Size(460, 2400)),
    builder: () => wrapForGolden(
      child: const DashboardScreen(),
      db: db,
      brightness: Brightness.light,
    ),
  );

  goldenTest(
    'Dashboard screen - dark',
    fileName: 'dashboard_screen_dark',
    constraints: BoxConstraints.tight(const Size(460, 2400)),
    builder: () => wrapForGolden(
      child: const DashboardScreen(),
      db: db,
      brightness: Brightness.dark,
    ),
  );

  goldenTest(
    'Dashboard screen, balance hidden - light',
    fileName: 'dashboard_screen_hidden_light',
    constraints: BoxConstraints.tight(const Size(460, 2400)),
    builder: () => wrapForGolden(
      child: const DashboardScreen(),
      db: db,
      brightness: Brightness.light,
      isBalanceHidden: true,
    ),
  );

  goldenTest(
    'Dashboard screen, balance hidden - dark',
    fileName: 'dashboard_screen_hidden_dark',
    constraints: BoxConstraints.tight(const Size(460, 2400)),
    builder: () => wrapForGolden(
      child: const DashboardScreen(),
      db: db,
      brightness: Brightness.dark,
      isBalanceHidden: true,
    ),
  );

  group('Portuguese', () {
    usePortuguesePhone();

    goldenTest(
      'Dashboard screen - Portuguese, light',
      fileName: 'dashboard_screen_pt_light',
      constraints: BoxConstraints.tight(const Size(460, 2400)),
      builder: () => wrapForGolden(
        child: const DashboardScreen(),
        db: db,
        brightness: Brightness.light,
        locale: const Locale('pt'),
      ),
    );
  });
}
