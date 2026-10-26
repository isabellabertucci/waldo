import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget button) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: button)),
    ),
  );

  testWidgets('Screen readers hear it as a button they can press', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(
      tester,
      DashedStitchButton(label: 'Create wallet', onPressed: () {}),
    );

    expect(
      tester.getSemantics(find.text('Create wallet')),
      isSemantics(
        label: 'Create wallet',
        isButton: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('Without an action it is read as a dimmed button', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, const DashedStitchButton(label: 'Create wallet'));

    expect(
      tester.getSemantics(find.text('Create wallet')),
      isSemantics(isButton: true, isEnabled: false),
    );
    semantics.dispose();
  });

  testWidgets('An icon-only button is read with its tooltip as one button', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(
      tester,
      DashedStitchButton(
        icon: const Icon(AppIcons.add),
        tooltip: 'Add category',
        onPressed: () {},
      ),
    );

    // Name, role and tap on the same node, or VoiceOver says "button" alone.
    expect(
      tester.getSemantics(find.byType(InkWell)),
      isSemantics(
        tooltip: 'Add category',
        isButton: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('Text beside it is not read as part of its name', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(
      tester,
      // A card that is one node, like the empty receipt.
      Semantics(
        container: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nothing here yet'),
            DashedStitchButton(label: 'Add', onPressed: () {}),
          ],
        ),
      ),
    );

    expect(
      tester.getSemantics(find.text('Add')),
      isSemantics(label: 'Add', isButton: true),
    );
    semantics.dispose();
  });

  testWidgets('Every variant is the same size, so a pair always matches', (
    tester,
  ) async {
    await pump(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final variant in StitchVariant.values)
            DashedStitchButton(
              key: ValueKey(variant),
              variant: variant,
              label: 'Save',
              onPressed: () {},
            ),
        ],
      ),
    );

    final sizes = {
      for (final variant in StitchVariant.values)
        tester.getSize(find.byKey(ValueKey(variant))),
    };
    expect(sizes, hasLength(1));
  });
}
