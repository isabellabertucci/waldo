import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_colors.dart';
import 'package:waldo/core/theme/common.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(AppColors.light, Brightness.light);

  static ThemeData get dark => _buildTheme(AppColors.dark, Brightness.dark);

  static ThemeData _buildTheme(AppColors colors, Brightness brightness) {
    final baseScheme = brightness == Brightness.dark
        ? const ColorScheme.dark()
        : const ColorScheme.light();

    final colorScheme = baseScheme.copyWith(
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryContainer,
      // The container is near-white in both themes, so it pairs with `onSurface`.
      onPrimaryContainer: colors.onSurface,
      onSurfaceVariant: colors.onSurfaceVariant,
      error: colors.error,
      // `onPrimary` already contrasts with `error` in both themes.
      onError: colors.onPrimary,
      surface: colors.surface,
      onSurface: colors.onSurface,
      surfaceContainer: colors.surfaceContainer,
      outline: colors.fieldBorder,
      // Material 3 tints elevated surfaces toward `primary` by default;
      // Waldo's surfaces are flat ink/cream with no such tint anywhere.
      surfaceTint: colors.transparent,
    );

    final textTheme = _applyTypeScale(
      brightness == Brightness.dark
          ? ThemeData.dark().textTheme
          : ThemeData.light().textTheme,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colors.surfaceContainer,
      extensions: [colors],

      appBarTheme: Common.getAppBarTheme(colors),
      floatingActionButtonTheme: Common.getFloatingActionButtonTheme(colors),
      cardTheme: Common.getCardTheme(colors),
      dialogTheme: Common.getDialogTheme(colors),
      snackBarTheme: Common.getSnackBarTheme(colors),
      bottomSheetTheme: Common.getBottomSheetTheme(colors),
      listTileTheme: Common.getListTileTheme(colors),
      inputDecorationTheme: Common.getInputDecorationTheme(colors),
      datePickerTheme: Common.getDatePickerTheme(colors),
      filledButtonTheme: Common.getFilledButtonTheme(colors, textTheme),
    );
  }

  /// Headlines w500 at -2% tracking, body w400 at -0.5%, labels w500 at -3%.
  static TextTheme _applyTypeScale(TextTheme base) {
    TextStyle? display(TextStyle? style) =>
        _tracked(style, FontWeight.w500, -0.02);
    TextStyle? body(TextStyle? style) =>
        _tracked(style, FontWeight.w400, -0.005);
    TextStyle? label(TextStyle? style) =>
        _tracked(style, FontWeight.w500, -0.03);

    return base.copyWith(
      displayLarge: display(base.displayLarge),
      displayMedium: display(base.displayMedium),
      displaySmall: display(base.displaySmall),
      headlineLarge: display(base.headlineLarge),
      headlineMedium: display(base.headlineMedium),
      headlineSmall: display(base.headlineSmall),
      titleLarge: display(base.titleLarge),
      titleMedium: display(base.titleMedium),
      titleSmall: display(base.titleSmall),
      bodyLarge: body(base.bodyLarge),
      bodyMedium: body(base.bodyMedium),
      bodySmall: body(base.bodySmall),
      labelLarge: label(base.labelLarge),
      labelMedium: label(base.labelMedium),
      labelSmall: label(base.labelSmall),
    );
  }

  static TextStyle? _tracked(
    TextStyle? style,
    FontWeight weight,
    double trackingRatio,
  ) {
    if (style == null) return null;
    final fontSize = style.fontSize ?? 14;
    return style.copyWith(
      fontWeight: weight,
      letterSpacing: fontSize * trackingRatio,
    );
  }
}

extension ThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;

  TextTheme get textTheme => Theme.of(this).textTheme;

  /// `body-md`, semibold (w600).
  TextStyle get bodyMdStrong =>
      textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600);

  /// `body-md`, bold (w700) - the most common emphasis step.
  TextStyle get bodyMdBold =>
      textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w700);

  /// `body-sm`, bold - a caption that still needs to read as a value, not
  /// just muted metadata (e.g. a stat card's small bold figure).
  TextStyle get bodySmBold =>
      textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w700);

  /// `label-lg` pushed to bold - transaction amounts, confirm buttons, and
  /// other labels that need to visually win their row.
  TextStyle get labelLgStrong =>
      textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w700);

  /// `label-sm`, bold - a small label that still needs emphasis (distinct
  /// from [labelXs], which is specifically the uppercase eyebrow style).
  TextStyle get labelSmBold =>
      textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w700);

  /// `headline-md` pushed one step, semibold - section headers within a
  /// screen (e.g. "Recent transactions", "Cash Flow").
  TextStyle get headlineMdStrong =>
      textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600);

  /// `headline-lg` pushed to extra-bold - the most common "screen/sheet
  /// title" weight: dialog titles, form sheet headers, card titles.
  TextStyle get headlineLgStrong =>
      textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w800);

  /// `headlineSmall`, extra-bold - an alternate large title.
  TextStyle get headlineSmBold =>
      textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w800);

  /// `headlineMedium`, extra-bold - the amount being edited.
  TextStyle get amountDisplayBold =>
      textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w800);

  /// `headlineMedium`, black (w900) - the dashboard's total balance.
  TextStyle get headlineDisplayStrong =>
      textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w900);

  /// A small uppercase eyebrow label. Callers upper-case the text themselves.
  TextStyle get labelXs => textTheme.labelSmall!.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );
}
