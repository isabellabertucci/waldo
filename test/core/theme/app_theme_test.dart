import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/app_colors.dart';
import 'package:waldo/core/theme/app_theme.dart';

void main() {
  for (final (name, theme, colors) in [
    ('light', AppTheme.light, AppColors.light),
    ('dark', AppTheme.dark, AppColors.dark),
  ]) {
    group('Text theme ($name)', () {
      late TextTheme textTheme;

      Future<void> pumpTheme(WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                textTheme = Theme.of(context).textTheme;
                return const SizedBox();
              },
            ),
          ),
        );
      }

      testWidgets('Text defaults to the onSurface token', (tester) async {
        await pumpTheme(tester);

        for (final style in [
          textTheme.headlineMedium,
          textTheme.titleLarge,
          textTheme.bodyMedium,
          textTheme.labelLarge,
          textTheme.labelSmall,
        ]) {
          expect(style!.color, colors.onSurface);
        }
      });

      testWidgets('Tracking scales with each style\'s own font size', (
        tester,
      ) async {
        await pumpTheme(tester);

        for (final (style, ratio) in [
          (textTheme.headlineMedium!, -0.02),
          (textTheme.titleLarge!, -0.02),
          (textTheme.titleMedium!, -0.02),
          (textTheme.bodyMedium!, -0.005),
          (textTheme.bodySmall!, -0.005),
          (textTheme.labelLarge!, -0.03),
          (textTheme.labelSmall!, -0.03),
        ]) {
          expect(style.letterSpacing, closeTo(style.fontSize! * ratio, 1e-9));
        }
      });
    });
  }
}
