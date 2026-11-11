import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/motion.dart';

void main() {
  test("Motion's durations are Material 3's own steps", () {
    expect(Motion.toggle, Durations.short3);
    expect(Motion.scroll, Durations.medium2);
    expect(Motion.enter, Durations.medium3);
    expect(Motion.balanceTuck, Durations.medium2);
    expect(Motion.receiptPrint, Durations.long4);
    expect(Motion.cardDropFade, Durations.short2);
    expect(Motion.cardFall, Durations.medium4);
    expect(Motion.cardSettle, Durations.medium2);
    expect(Motion.pouchSquash, Durations.short2);
    expect(Motion.pouchRebound, Durations.medium1);
    expect(Motion.pillStretch, Durations.long1);
    expect(Motion.pillLabel, Durations.medium1);
    expect(Motion.chartDraw, Durations.extralong2);
    expect(Motion.chartMorph, Durations.long4);
    expect(Motion.chartLabelDelay, Durations.short2);
    expect(Motion.chartLabel, Durations.medium1);
    expect(Motion.menuFadeIn, Durations.short2);
    expect(Motion.menuClose, Durations.short4);
    expect(Motion.menuDip, Durations.short4);
    expect(Motion.cardLeave, Durations.medium4);
    expect(Motion.cardGapDelay, Durations.medium1);
    expect(Motion.cardReturn, Durations.medium2);
    expect(Motion.cardLandFade, Durations.short2);
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

  test('A spring curve settles at 1 in the time it takes to come to rest', () {
    // The playground's figure for the bouncy spring.
    expect(Motion.bouncyCurve.duration.inMilliseconds, closeTo(888, 1));
    expect(Motion.bouncyCurve.transform(1), 1);
    // Under-damped: it overshoots on the way.
    expect([
      for (var t = 0.0; t < 1; t += 0.05) Motion.bouncyCurve.transform(t),
    ], contains(greaterThan(1)));
  });
}
