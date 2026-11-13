import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/stitch.dart';

void main() {
  test('The stitch dashes are longer than their gaps', () {
    expect(Stitch.regular.dash, greaterThan(Stitch.regular.gap));
  });
}
