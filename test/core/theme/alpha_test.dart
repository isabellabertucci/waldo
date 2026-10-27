import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/alpha.dart';

void main() {
  test('Each opacity step is stronger than the one before', () {
    const steps = [
      Alpha.faint,
      Alpha.tint,
      Alpha.soft,
      Alpha.medium,
      Alpha.stitch,
      Alpha.line,
      Alpha.muted,
      Alpha.strong,
    ];
    for (var i = 1; i < steps.length; i++) {
      expect(steps[i], greaterThan(steps[i - 1]));
    }
  });
}
