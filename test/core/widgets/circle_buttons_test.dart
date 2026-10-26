import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/widgets/circle_icon_button.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/l10n/app_localizations.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    ),
  );

  testWidgets('A circle icon button is read as a button with its tooltip', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(
      tester,
      CircleIconButton(
        tooltip: 'New wallet',
        onPressed: () {},
        child: const Icon(AppIcons.add),
      ),
    );

    expect(
      tester.getSemantics(
        find.descendant(
          of: find.byType(CircleIconButton),
          matching: find.byType(InkWell),
        ),
      ),
      isSemantics(tooltip: 'New wallet', isButton: true, hasTapAction: true),
    );
    semantics.dispose();
  });

  testWidgets('The sheet close button is read as a "Close" button', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, const SheetCloseButton());

    expect(
      tester.getSemantics(
        find.descendant(
          of: find.byType(SheetCloseButton),
          matching: find.byType(InkWell),
        ),
      ),
      isSemantics(tooltip: 'Close', isButton: true, hasTapAction: true),
    );
    semantics.dispose();
  });

  // Measured directly: Flutter's tap target guideline skips controls at a
  // scrollable's edge, where the sheet's ✕ sits.
  testWidgets('Both circle buttons can be tapped across 48px', (tester) async {
    await pump(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleIconButton(
            tooltip: 'Back',
            onPressed: () {},
            child: const Icon(AppIcons.back),
          ),
          const SheetCloseButton(),
        ],
      ),
    );

    for (final type in [CircleIconButton, SheetCloseButton]) {
      final size = tester.getSize(find.byType(type).first);
      expect(size.width, greaterThanOrEqualTo(kMinInteractiveDimension));
      expect(size.height, greaterThanOrEqualTo(kMinInteractiveDimension));
    }
  });
}
