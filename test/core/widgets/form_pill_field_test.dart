import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/app_colors.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/widgets/form_pill_field.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// The filled box round the input.
final _box = find
    .ancestor(
      of: find.byType(EditableText),
      matching: find.byWidgetPredicate(
        (w) => w is Container && w.decoration is BoxDecoration,
      ),
    )
    .first;

void main() {
  testWidgets(
    'A tap anywhere on the box focuses the field and shows the ink line',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FormPillField(
              controller: controller,
              label: 'Note',
              hint: 'Add a note',
            ),
          ),
        ),
      );
      Color line() {
        final box = tester.widget<Container>(_box);
        return ((box.decoration! as BoxDecoration).border! as Border).top.color;
      }

      expect(line(), AppColors.light.transparent);

      // The box's padding, beside the input rather than on it.
      final box = tester.getRect(_box);
      await tester.tapAt(box.topLeft + const Offset(4, 4));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );
      expect(line(), AppColors.light.ink);
    },
  );

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
    expect(decoration.hintStyle?.color, AppColors.light.inkMuted);
  });

  testWidgets('An error shows under the pill, not inside it', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final form = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Form(
            key: form,
            child: FormPillField(
              controller: controller,
              label: 'Name',
              hint: 'Add a name',
              validator: (value) =>
                  value == null || value.isEmpty ? 'Name is required' : null,
            ),
          ),
        ),
      ),
    );

    expect(form.currentState!.validate(), isFalse);
    await tester.pump();

    final pill = tester.getRect(_box);
    final error = tester.getRect(find.text('Name is required'));
    expect(error.top, greaterThanOrEqualTo(pill.bottom));

    // Typed into, it checks what was typed.
    await tester.enterText(find.byType(TextFormField), 'Gym');
    expect(form.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Name is required'), findsNothing);
  });
}
