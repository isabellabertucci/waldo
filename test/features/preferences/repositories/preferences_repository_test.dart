import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waldo/features/preferences/repositories/preferences_repository.dart';

import '../../../helpers/test_app.dart';

void main() {
  late Database db;
  late PreferencesRepositoryImpl repo;

  setUp(() async {
    db = await createTestDatabase();
    repo = PreferencesRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('PreferencesRepositoryImpl', () {
    test('getPreferences inserts and returns defaults on first run', () async {
      final preferences = await repo.getPreferences();

      expect(preferences.currency, 'USD');
      expect(preferences.isDarkMode, isNull);
      expect(preferences.dateFormat, 'yyyy-MM-dd');
    });

    test('getPreferences returns the same row on subsequent reads', () async {
      await repo.getPreferences();
      await repo.setCurrency('EUR');

      final preferences = await repo.getPreferences();

      expect(preferences.currency, 'EUR');
    });

    test('setCurrency updates the currency', () async {
      await repo.getPreferences();

      await repo.setCurrency('GBP');
      final preferences = await repo.getPreferences();

      expect(preferences.currency, 'GBP');
    });

    test('setDateFormat updates the date format', () async {
      await repo.getPreferences();

      await repo.setDateFormat('dd/MM/yyyy');
      final preferences = await repo.getPreferences();

      expect(preferences.dateFormat, 'dd/MM/yyyy');
    });

    test('setDarkMode updates theme_dark to a specific value', () async {
      await repo.getPreferences();

      await repo.setDarkMode(true);
      final preferences = await repo.getPreferences();

      expect(preferences.isDarkMode, isTrue);
    });

    test('setDarkMode can reset theme_dark back to null', () async {
      await repo.getPreferences();
      await repo.setDarkMode(true);

      await repo.setDarkMode(null);
      final preferences = await repo.getPreferences();

      expect(preferences.isDarkMode, isNull);
    });
  });
}
