import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/motion.dart';

void main() {
  test("Motion's durations are Material 3's own steps", () {
    expect(Motion.toggle, Durations.short3);
    expect(Motion.navigation, Durations.short4);
    expect(Motion.scroll, Durations.medium2);
    expect(Motion.enter, Durations.medium3);
  });
}
