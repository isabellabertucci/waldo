import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/utils/dash_path.dart';

void main() {
  test('cuts a line into dashes with gaps, the last one cut short', () {
    // 0-4, 7-11, 14-18, then 21-22 cut short by the end of the line.
    final line = Path()
      ..moveTo(0, 0)
      ..lineTo(22, 0);

    final dashes = dashPath(line, dashLength: 4, gapLength: 3).computeMetrics();

    expect(dashes.map((d) => d.length), [4, 4, 4, 1]);
  });

  test('an empty path gives no dashes', () {
    expect(
      dashPath(Path(), dashLength: 4, gapLength: 3).computeMetrics(),
      isEmpty,
    );
  });
}
