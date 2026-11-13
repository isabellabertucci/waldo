import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

        // (style, size, weight): the design system's type scale, then the
        // styles screens used to set by hand.
        final styles = [
          (textTheme.amountHero, 32.0, FontWeight.w700),
          (textTheme.amountWallet, 20.0, FontWeight.w700),
          (textTheme.amountRow, 15.0, FontWeight.w600),
          (textTheme.titlePage, 28.0, FontWeight.w700),
          (textTheme.titleSection, 20.0, FontWeight.w700),
          (textTheme.titleCard, 16.0, FontWeight.w600),
          (textTheme.bodyMedium!, 15.0, FontWeight.w500),
          (textTheme.bodyStrong, 15.0, FontWeight.w600),
          (textTheme.label, 13.0, FontWeight.w500),
          (textTheme.caption, 12.0, FontWeight.w500),
          (textTheme.overline, 11.0, FontWeight.w700),
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
          expect(style!.color, colors.ink);
        }
      });

      testWidgets('Tracking scales with each style\'s own font size', (
        tester,
      ) async {
        await pumpTheme(tester);

        for (final (style, ratio) in [
          (textTheme.amountHero, -0.03),
          (textTheme.amountWallet, -0.02),
          (textTheme.titlePage, -0.02),
          (textTheme.titleSection, -0.01),
          (textTheme.titleCard, 0.0),
          (textTheme.bodyMedium!, 0.0),
          (textTheme.overline, 0.1),
        ]) {
          expect(style.letterSpacing, closeTo(style.fontSize! * ratio, 1e-9));
        }
      });
    });

    testWidgets('A screen with an AppBar keeps readable status bar text '
        '($name)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(appBar: AppBar(title: const Text('Title'))),
        ),
      );

      final style = tester
          .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
            find.descendant(
              of: find.byType(AppBar),
              matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
            ),
          )
          .value;
      final isDark = theme.brightness == Brightness.dark;
      expect(
        style.statusBarIconBrightness,
        isDark ? Brightness.light : Brightness.dark,
      );
      expect(style.statusBarBrightness, theme.brightness); // iOS
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
