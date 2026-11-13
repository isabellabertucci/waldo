import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/widgets/edit_delete_menu.dart';

import '../../helpers/test_app.dart';

void main() {
  final picked = <EditDeleteAction>[];

  setUp(picked.clear);

  /// A ⋮ button at [alignment] on the screen.
  Future<void> pumpButton(
    WidgetTester tester, {
    Alignment alignment = Alignment.topRight,
  }) async {
    final db = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: SafeArea(
          child: Align(
            alignment: alignment,
            child: EditDeleteMenuButton(
              tooltip: 'Options for Cash',
              onSelected: picked.add,
              child: const SizedBox(key: Key('dots'), width: 24, height: 24),
            ),
          ),
        ),
      ),
    );
    addTearDown(db.close);
  }

  Rect menuRect(WidgetTester tester) => tester.getRect(
    find.ancestor(of: find.text('Edit'), matching: find.byType(Material)).first,
  );

  /// The menu's own scale: the one growing from a right-hand corner.
  Transform menuScale(WidgetTester tester) => tester
      .widgetList<Transform>(
        find.ancestor(of: find.text('Edit'), matching: find.byType(Transform)),
      )
      .singleWhere(
        (t) =>
            t.alignment == Alignment.topRight ||
            t.alignment == Alignment.bottomRight,
      );

  testWidgets('The menu grows out of the dots, just below them and lined up '
      'on their right edge', (tester) async {
    await pumpButton(tester);
    final dots = tester.getRect(find.byKey(const Key('dots')));

    await tester.tap(find.byKey(const Key('dots')));
    await tester.pump();
    await tester.pump(Motion.menuFadeIn);
    expect(menuScale(tester).alignment, Alignment.topRight);

    await tester.pumpAndSettle();
    final menu = menuRect(tester);
    expect(menu.top, dots.bottom);
    expect(menu.right, dots.right);
  });

  testWidgets('It springs past its size and back, then closes with a plain '
      'fade', (tester) async {
    await pumpButton(tester);

    await tester.tap(find.byKey(const Key('dots')));
    await tester.pump();
    var largest = 0.0;
    for (var i = 0; i < 30; i++) {
      await tester.pump(Motion.bouncyCurve.duration ~/ 30);
      final scale = menuScale(tester).transform.getMaxScaleOnAxis();
      if (scale > largest) largest = scale;
    }
    // One small bounce past full size.
    expect(largest, greaterThan(1));
    expect(menuScale(tester).transform.getMaxScaleOnAxis(), closeTo(1, 0.01));

    await tester.tapAt(const Offset(20, 400));
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tester.pump(Motion.menuClose ~/ 5);
      expect(menuScale(tester).transform.getMaxScaleOnAxis(), 1);
    }
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsNothing);
    expect(picked, isEmpty);
  });

  testWidgets('Near the bottom it opens above the dots, growing from them', (
    tester,
  ) async {
    await pumpButton(tester, alignment: Alignment.bottomRight);
    final dots = tester.getRect(find.byKey(const Key('dots')));

    await tester.tap(find.byKey(const Key('dots')));
    await tester.pumpAndSettle();
    expect(menuRect(tester).bottom, dots.top);
    expect(menuScale(tester).alignment, Alignment.bottomRight);
  });

  testWidgets('Picking an item reports it; the tap clicks lightly', (
    tester,
  ) async {
    final haptics = recordHaptics(tester);
    await pumpButton(tester);

    await tester.tap(find.byKey(const Key('dots')));
    await tester.pumpAndSettle();
    expect(haptics, ['HapticFeedbackType.lightImpact']);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(picked, [EditDeleteAction.delete]);
    expect(find.text('Edit'), findsNothing);
  });

  testWidgets('The button is named for screen readers and has a 48px touch '
      'area', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpButton(tester);

    expect(
      tester.getSemantics(find.byType(EditDeleteMenuButton)),
      isSemantics(isButton: true, tooltip: 'Options for Cash'),
    );
    expect(
      tester.getSize(find.byType(EditDeleteMenuButton)),
      const Size.square(kMinInteractiveDimension),
    );
    semantics.dispose();
  });

  testWidgets('With reduce motion on, the menu is simply there', (
    tester,
  ) async {
    await pumpButton(tester);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pump();

    await tester.tap(find.byKey(const Key('dots')));
    await tester.pump();
    await tester.pump();
    expect(menuScale(tester).transform.getMaxScaleOnAxis(), 1);
  });
}
