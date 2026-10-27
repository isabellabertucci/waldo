import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/stitch.dart';

void main() {
  test('The stitch grows coarser with the shape it is on', () {
    final patterns = [
      Stitch.fine,
      Stitch.regular,
      Stitch.receipt,
      Stitch.coarse,
    ];
    for (var i = 1; i < patterns.length; i++) {
      expect(patterns[i].dash, greaterThan(patterns[i - 1].dash));
      expect(patterns[i].gap, greaterThan(patterns[i - 1].gap));
    }
  });
}
