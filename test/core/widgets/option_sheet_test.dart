import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/app_colors.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/widgets/dashed_border.dart';
import 'package:waldo/core/widgets/option_sheet.dart';
import 'package:waldo/l10n/app_localizations.dart';

void main() {
  testWidgets('Only the selected option has the app stitch', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: OptionSheet<int>(
            title: 'Theme',
            initialValue: 1,
            onConfirm: (_) {},
            options: const [
              SheetOption(value: 1, label: 'Light', icon: AppIcons.add),
              SheetOption(value: 2, label: 'Dark', icon: AppIcons.add),
            ],
          ),
        ),
      ),
    );

    Color stitchOf(String label) => tester
        .widget<DashedBorder>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(DashedBorder),
          ),
        )
        .color;
    expect(stitchOf('Light'), AppColors.light.primary);
    expect(stitchOf('Dark'), AppColors.light.transparent);
  });

  Future<void> openSheet(
    WidgetTester tester, {
    required ValueChanged<int> onConfirm,
    SheetAction? action,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showOptionSheet<int>(
                context,
                title: 'Wallet',
                initialValue: 1,
                pickOnTap: true,
                action: action,
                options: const [
                  SheetOption(value: 1, label: 'Home', icon: AppIcons.add),
                  SheetOption(value: 2, label: 'Bank', icon: AppIcons.add),
                ],
                onConfirm: onConfirm,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('In a form a tap picks the option and closes, with no Done', (
    tester,
  ) async {
    int? picked;
    await openSheet(tester, onConfirm: (value) => picked = value);
    expect(find.text('Done'), findsNothing);

    await tester.tap(find.text('Bank'));
    await tester.pumpAndSettle();

    expect(picked, 2);
    expect(find.text('Bank'), findsNothing, reason: 'the sheet closed');
  });

  testWidgets('The action tile comes first, without a ring, and runs', (
    tester,
  ) async {
    var ran = false;
    await openSheet(
      tester,
      onConfirm: (_) {},
      action: (
        icon: AppIcons.add,
        label: 'New wallet',
        onTap: () => ran = true,
      ),
    );

    final action = tester.getRect(find.text('New wallet'));
    expect(action.top, lessThan(tester.getRect(find.text('Home')).top));
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('New wallet'),
          matching: find.byType(InkWell),
        ),
        matching: find.byIcon(AppIcons.radioUnselected),
      ),
      findsNothing,
    );

    await tester.tap(find.text('New wallet'));
    await tester.pumpAndSettle();
    expect(ran, isTrue);
  });
}
