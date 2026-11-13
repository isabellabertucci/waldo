import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';

void main() {
  test('At the default size nothing changes', () {
    const scaler = DynamicTypeScaler(1);
    for (final size in [11.0, 14.0, 22.0, 28.0]) {
      expect(scaler.scale(size), size);
    }
  });

  test('Body text and smaller grow with the system factor', () {
    const scaler = DynamicTypeScaler(53 / 17);
    expect(scaler.scale(14), closeTo(14 * 53 / 17, 0.001));
    expect(scaler.scale(11), closeTo(11 * 53 / 17, 0.001));
  });

  test("At AX5 titles follow Apple's table, close to body text", () {
    const scaler = DynamicTypeScaler(53 / 17);
    // Waldo's 28 is Apple's Large Title (34), which is 60 at AX5.
    expect(scaler.scale(28), closeTo(60 * 14 / 17, 0.001));
    // Waldo's 22 sits between Title 2 and Title 1 (56 and 58 at AX5).
    expect(scaler.scale(22), lessThan(58 * 14 / 17));
    expect(scaler.scale(22), greaterThan(56 * 14 / 17));
  });

  test('A bigger style is never smaller, and every size grows with the '
      'setting', () {
    const sizes = [11.0, 12.0, 14.0, 16.0, 22.0, 24.0, 28.0, 40.0];
    for (final factor in [14 / 17, 1.0, 23 / 17, 33 / 17, 53 / 17]) {
      final scaler = DynamicTypeScaler(factor);
      for (var i = 1; i < sizes.length; i++) {
        expect(scaler.scale(sizes[i]), greaterThan(scaler.scale(sizes[i - 1])));
      }
    }
    for (final size in sizes) {
      expect(
        const DynamicTypeScaler(33 / 17).scale(size),
        greaterThan(const DynamicTypeScaler(28 / 17).scale(size)),
      );
    }
  });

  test('Clamping keeps the Apple curve', () {
    final clamped = const DynamicTypeScaler(
      53 / 17,
    ).clamp(maxScaleFactor: DynamicTypeScaler.barMaxScale);
    expect(clamped, const DynamicTypeScaler(DynamicTypeScaler.barMaxScale));
  });

  testWidgets('Accessibility sizes start at AX1', (tester) async {
    late bool below;
    late bool at;
    Widget probe(double factor, void Function(bool) report) => MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(factor)),
      child: Builder(
        builder: (context) {
          report(DynamicTypeScaler.isAccessibilitySize(context));
          return const SizedBox();
        },
      ),
    );

    await tester.pumpWidget(probe(23 / 17, (v) => below = v));
    await tester.pumpWidget(probe(28 / 17, (v) => at = v));

    expect(below, isFalse);
    expect(at, isTrue);
  });
}
