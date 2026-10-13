import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/utils/amount_input_formatter.dart';

void main() {
  String type(String before, String after, {bool allowNegative = false}) {
    return AmountInputFormatter(allowNegative: allowNegative)
        .formatEditUpdate(
          TextEditingValue(text: before),
          TextEditingValue(text: after),
        )
        .text;
  }

  test('accepts up to nine whole digits and two decimals', () {
    expect(type('', '123456789.12'), '123456789.12');
    expect(type('', '12,5'), '12,5');
  });

  test('ignores a tenth whole digit', () {
    expect(type('123456789', '1234567890'), '123456789');
  });

  test('ignores a third decimal', () {
    expect(type('1.25', '1.255'), '1.25');
  });

  test('ignores letters and a second separator', () {
    expect(type('1', '1a'), '1');
    expect(type('1.2', '1.2.'), '1.2');
  });

  test('takes a minus sign only when negatives are allowed', () {
    expect(type('', '-'), '');
    expect(type('', '-5', allowNegative: true), '-5');
  });
}
