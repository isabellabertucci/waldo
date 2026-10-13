import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/features/settings/ui/settings_screen.dart';

import '../helpers/golden_test_app.dart';
import '../helpers/test_app.dart';

void main() {
  late Database db;

  setUp(() async {
    db = await createTestDatabase();
  });

  tearDown(() => db.close());

  goldenTest(
    'Settings screen - light',
    fileName: 'settings_screen_light',
    constraints: BoxConstraints.tight(const Size(460, 900)),
    builder: () => wrapForGolden(
      child: const SettingsScreen(),
      db: db,
      brightness: Brightness.light,
    ),
  );

  goldenTest(
    'Settings screen - dark',
    fileName: 'settings_screen_dark',
    constraints: BoxConstraints.tight(const Size(460, 900)),
    builder: () => wrapForGolden(
      child: const SettingsScreen(),
      db: db,
      brightness: Brightness.dark,
    ),
  );

  group('Portuguese', () {
    usePortuguesePhone();

    goldenTest(
      'Settings screen - Portuguese, light',
      fileName: 'settings_screen_pt_light',
      constraints: BoxConstraints.tight(const Size(460, 900)),
      builder: () => wrapForGolden(
        child: const SettingsScreen(),
        db: db,
        brightness: Brightness.light,
        locale: const Locale('pt'),
      ),
    );
  });
}
