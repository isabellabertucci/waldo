import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/router/app_nav_bar.dart';
import 'package:waldo/core/theme/motion.dart';

import '../../helpers/test_app.dart';

void main() {
  final taps = <int>[];

  setUp(() {
    taps.clear();
  });

  Future<void> pumpBar(WidgetTester tester) async {
    var current = 0;
    final db = await pumpWidgetWithProviders(
      tester,
      StatefulBuilder(
        builder: (context, setState) => Scaffold(
          bottomNavigationBar: AppNavBar(
            currentIndex: current,
            onSelect: (index) {
              taps.add(index);
              setState(() => current = index);
            },
          ),
        ),
      ),
    );
    addTearDown(db.close);
  }

  testWidgets('Opening a name only widens its tab; no tab grows taller', (
    tester,
  ) async {
    await pumpBar(tester);

    await tester.tap(find.byKey(const ValueKey('nav-1')));
    await tester.pump();
    await tester.pump(Motion.pillStretch ~/ 2);
    for (final index in [0, 1, 2]) {
      expect(
        tester.getSize(find.byKey(ValueKey('nav-$index'))).height,
        lessThan(kMinInteractiveDimension),
      );
    }
  });

  testWidgets('A new tab clicks once; the current tab only pops back, without '
      'a click', (tester) async {
    final haptics = recordHaptics(tester);
    await pumpBar(tester);

    await tester.tap(find.byKey(const ValueKey('nav-0')));
    await tester.pumpAndSettle();
    expect(haptics, isEmpty);

    await tester.tap(find.byKey(const ValueKey('nav-2')));
    await tester.pumpAndSettle();
    expect(haptics, ['HapticFeedbackType.selectionClick']);
    expect(taps, [0, 2]);
  });
}
