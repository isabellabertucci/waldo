import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/utils/utils.dart';

void main() {
  group('parseToCents', () {
    final cases = <(String, bool, int?)>[
      ('10', false, 1000),
      ('10.5', false, 1050),
      ('10.50', false, 1050),
      ('0', false, 0),
      ('', false, null),
      ('abc', false, null),
      ('-5', false, null),
      ('-5', true, -500),
      ('10.999', false, null),
      ('123456789.99', false, 12345678999),
      ('9999999999999999999999', false, null),
    ];

    for (final (input, allowNegative, expected) in cases) {
      test(
        'parseToCents("$input", allowNegative: $allowNegative) => $expected',
        () {
          final result = parseToCents(input, allowNegative: allowNegative);
          expect(result, expected);
        },
      );
    }
  });

  test('zeroAmountHint uses the phone\'s decimal separator', () {
    expect(zeroAmountHint('en_US'), '0.00');
    expect(zeroAmountHint('pt_PT'), '0,00');
  });

  test('decimalSeparator follows the locale', () {
    expect(decimalSeparator('en_US'), '.');
    expect(decimalSeparator('pt_PT'), ',');
  });

  group('formatCentsForInput', () {
    final cases = <(int, String)>[
      (1000, '10.00'),
      (1050, '10.50'),
      (0, '0.00'),
      (-500, '-5.00'),
    ];

    for (final (cents, expected) in cases) {
      test('formatCentsForInput($cents) => "$expected"', () {
        expect(formatCentsForInput(cents), expected);
      });
    }
  });

  group('formatCents', () {
    final cases = <(int, String)>[
      (1000, '\$10.00'),
      (1050, '\$10.50'),
      (-4000000, '-\$40,000.00'),
    ];

    for (final (cents, expected) in cases) {
      test('formatCents($cents) => "$expected"', () {
        expect(formatCents(cents, locale: 'en_US'), expected);
      });
    }
  });

  test('formatCents follows the locale: a Portuguese phone puts the euro '
      'after the number, with a decimal comma and spaced thousands', () {
    expect(
      formatCents(123450, locale: 'pt_PT', currencyCode: 'EUR'),
      '1\u00a0234,50\u00a0€',
    );
    expect(formatCents(100, locale: 'en_US', currencyCode: 'EUR'), '€1.00');
  });

  testWidgets('moneyLocale reads the device region', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('pt', 'PT');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    late String locale;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          locale = moneyLocale(context);
          return const SizedBox();
        },
      ),
    );

    expect(locale, 'pt_PT');
  });

  testWidgets('moneyLocale falls back to en_US for a region intl lacks', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('xx', 'YY');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    late String locale;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          locale = moneyLocale(context);
          return const SizedBox();
        },
      ),
    );

    expect(locale, 'en_US');
  });

  test('nameKey ignores spaces at the ends and case, accents included', () {
    expect(nameKey('  CAFÉ '), nameKey('Café'));
    expect(nameKey('POUPANÇA'), 'poupança');
    expect(nameKey('Cafe'), isNot(nameKey('Café')));
  });
}
