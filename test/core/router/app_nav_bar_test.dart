import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/router/app_nav_bar.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/widgets/stretch_pill.dart';

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

  /// The tab's rect where the pill paints it, relative to the bar's row.
  Rect tabRect(WidgetTester tester, int index) => tester
      .getRect(find.byKey(ValueKey('nav-$index')))
      .shift(-tester.getTopLeft(find.byType(StretchPill)));

  testWidgets('The new tab\'s name opens while the old one closes, and the '
      'pill ends on the new tab', (tester) async {
    await pumpBar(tester);
    expect(paintedStretchPill(tester), tabRect(tester, 0));

    await tester.tap(find.byKey(const ValueKey('nav-1')));
    await tester.pump();
    await tester.pump(Motion.pillStretch ~/ 2);
    // Mid-way both names show, part open.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Wallets'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Home'), findsNothing);
    expect(find.text('Wallets'), findsOneWidget);
    // Read while the tab was still growing, so it fits it exactly.
    expect(paintedStretchPill(tester), tabRect(tester, 1));
  });

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
