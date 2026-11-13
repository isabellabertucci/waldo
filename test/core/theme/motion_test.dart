import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/motion.dart';

void main() {
  test("Motion's durations are Material 3's own steps", () {
    expect(Motion.toggle, Durations.short3);
    expect(Motion.scroll, Durations.medium2);
    expect(Motion.enter, Durations.medium3);
    expect(Motion.pillStretch, Durations.long1);
    expect(Motion.chartMorph, Durations.long4);
    expect(Motion.chartLabel, Durations.medium1);
    expect(Motion.sheetExit, Durations.short4);
  });

  for (final reduce in [false, true]) {
    testWidgets('context.motion keeps a duration unless the phone asks for '
        'reduced motion (reduce: $reduce)', (tester) async {
      late Duration duration;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(disableAnimations: reduce),
          child: Builder(
            builder: (context) {
              duration = context.motion(Motion.enter);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(duration, reduce ? Duration.zero : Motion.enter);
    });
  }
}
