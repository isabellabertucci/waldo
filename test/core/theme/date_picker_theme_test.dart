import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/l10n/app_localizations.dart';

void main() {
  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
  ]) {
    testWidgets('The selected day reads on its fill ($name), even when it is '
        'today', (tester) async {
      final today = DateTime(2026, 10, 12);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDatePicker(
                context: context,
                initialDate: today,
                currentDate: today,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(CalendarDatePicker));
      final colors = context.appColors;
      final day = tester.widget<Text>(find.text('12'));
      final dayColor = DefaultTextStyle.of(
        tester.element(find.text('12')),
      ).style.merge(day.style).color;
      expect(dayColor, colors.onPrimary);
    });
  }
}
