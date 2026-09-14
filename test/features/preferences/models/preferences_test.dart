import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/features/preferences/models/preferences.dart';

void main() {
  group('Preferences mapping', () {
    test('toMap/fromMap round-trip preserves all fields', () {
      const preferences = Preferences(
        currency: 'EUR',
        isDarkMode: true,
        dateFormat: 'dd/MM/yyyy',
      );

      final map = preferences.toMap();
      final restored = Preferences.fromMap(map);

      expect(restored, preferences);
    });

    test('toMap stores isDarkMode as null when unset', () {
      const preferences = Preferences();

      expect(preferences.toMap()['theme_dark'], isNull);
    });

    test('toMap stores isDarkMode as 1 when true', () {
      const preferences = Preferences(isDarkMode: true);

      expect(preferences.toMap()['theme_dark'], 1);
    });

    test('toMap stores isDarkMode as 0 when false', () {
      const preferences = Preferences(isDarkMode: false);

      expect(preferences.toMap()['theme_dark'], 0);
    });

    test('fromMap parses a null theme_dark as no preference (system)', () {
      final map = {
        'preferred_currency': 'USD',
        'theme_dark': null,
        'date_format': 'yyyy-MM-dd',
      };

      expect(Preferences.fromMap(map).isDarkMode, isNull);
    });

    test('default values match the schema defaults', () {
      const preferences = Preferences();

      expect(preferences.currency, 'USD');
      expect(preferences.isDarkMode, isNull);
      expect(preferences.dateFormat, 'yyyy-MM-dd');
    });
  });
}
