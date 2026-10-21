import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
