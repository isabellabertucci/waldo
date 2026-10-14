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
        expect(formatCents(cents), expected);
      });
    }
  });
}
