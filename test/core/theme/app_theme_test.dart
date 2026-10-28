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

      testWidgets('The named styles keep their size and weight', (
        tester,
      ) async {
        await pumpTheme(tester);

        // (style, size, weight): what each screen used to set by hand.
        final styles = [
          (textTheme.monthPill, 13.0, FontWeight.w500),
          (textTheme.bodyMdBold, 14.0, FontWeight.w700),
          (textTheme.receiptLine, 12.5, FontWeight.w400),
          (textTheme.receiptLineBold, 12.5, FontWeight.w700),
          (textTheme.receiptTotal, 15.0, FontWeight.w700),
          (textTheme.receiptHeader, 11.0, FontWeight.w400),
          (textTheme.chartAxis, 11.0, FontWeight.w400),
          (textTheme.bodySmStrong, 12.0, FontWeight.w600),
          (textTheme.bodyMdExtraBold, 14.0, FontWeight.w800),
          (textTheme.walletCardBalance, 16.0, FontWeight.w800),
        ];
        for (final (style, size, weight) in styles) {
          expect(style.fontSize, size);
          expect(style.fontWeight, weight);
        }
      });

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

  testWidgets('With Bold Text on, text measures in bold, as Text draws it', (
    tester,
  ) async {
    late TextStyle normal;
    late TextStyle bold;
    Widget probe(bool boldText, void Function(TextStyle) report) => MediaQuery(
      data: MediaQueryData(boldText: boldText),
      child: Builder(
        builder: (context) {
          report(context.effectiveTextStyle(const TextStyle(fontSize: 14)));
          return const SizedBox();
        },
      ),
    );

    await tester.pumpWidget(probe(false, (s) => normal = s));
    await tester.pumpWidget(probe(true, (s) => bold = s));

    expect(normal.fontWeight, isNot(FontWeight.bold));
    expect(bold.fontWeight, FontWeight.bold);
    expect(bold.fontSize, 14);
  });
}
