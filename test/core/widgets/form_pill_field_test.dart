import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/app_colors.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/widgets/dashed_border.dart';
import 'package:waldo/core/widgets/form_pill_field.dart';
import 'package:waldo/l10n/app_localizations.dart';

void main() {
  testWidgets('A tap on the disc focuses the field and shows the stitch', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: FormPillField(
            leading: const Icon(AppIcons.note),
            controller: controller,
            label: 'Note',
            hint: 'Add a note',
          ),
        ),
      ),
    );
    Color stitch() =>
        tester.widget<DashedBorder>(find.byType(DashedBorder)).color;
    expect(stitch(), AppColors.light.transparent);

    await tester.tap(find.byIcon(AppIcons.note));
    await tester.pump();

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );
    expect(stitch(), AppColors.light.primary);
  });

  testWidgets('The placeholder is full-strength secondary text', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: FormPillField(
            leading: const Icon(AppIcons.note),
            controller: controller,
            label: 'Note',
            hint: 'Add a note',
          ),
        ),
      ),
    );

    // Faded, it would drop under 4.5:1 (WCAG 1.4.3).
    final decoration = tester
        .widget<InputDecorator>(find.byType(InputDecorator))
        .decoration;
    expect(decoration.hintStyle?.color, AppColors.light.onSurfaceVariant);
  });
}
