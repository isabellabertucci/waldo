import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('The menu opens just below the dots, lined up on their right '
      'edge', (tester) async {
    await pumpButton(tester);
    final dots = tester.getRect(find.byKey(const Key('dots')));

    await tester.tap(find.byKey(const Key('dots')));
    await tester.pumpAndSettle();
    final menu = menuRect(tester);
    expect(menu.top, dots.bottom);
    expect(menu.right, dots.right);
  });

  testWidgets('Near the bottom it opens above the dots', (tester) async {
    await pumpButton(tester, alignment: Alignment.bottomRight);
    final dots = tester.getRect(find.byKey(const Key('dots')));

    await tester.tap(find.byKey(const Key('dots')));
    await tester.pumpAndSettle();
    expect(menuRect(tester).bottom, dots.top);
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
}
