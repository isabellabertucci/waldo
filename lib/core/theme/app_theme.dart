import 'package:flutter/foundation.dart';
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

    // Colored by our scheme, with font sizes merged in up front so the
    // tracking below scales with each style's real size.
    final typography = Typography.material2021(
      platform: defaultTargetPlatform,
      colorScheme: colorScheme,
    );
    final textTheme = _applyTypeScale(
      typography.englishLike.merge(
        brightness == Brightness.dark ? typography.white : typography.black,
      ),
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

/// The DESIGN.md emphasis tokens. Defined on [TextTheme] so component themes,
/// which have no `context`, share them; widgets use the [ThemeContext] getters.
extension AppTextStyles on TextTheme {
  /// `body-md`, semibold (w600).
  TextStyle get bodyMdStrong =>
      bodyMedium!.copyWith(fontWeight: FontWeight.w600);

  /// `body-md`, bold (w700) - the most common emphasis step.
  TextStyle get bodyMdBold => bodyMedium!.copyWith(fontWeight: FontWeight.w700);

  /// `body-sm`, bold - a caption that still needs to read as a value, not
  /// just muted metadata (e.g. a stat card's small bold figure).
  TextStyle get bodySmBold => bodySmall!.copyWith(fontWeight: FontWeight.w700);

  /// `label-lg` pushed to bold - transaction amounts, confirm buttons, and
  /// other labels that need to visually win their row.
  TextStyle get labelLgStrong =>
      labelLarge!.copyWith(fontWeight: FontWeight.w700);

  /// `label-sm`, bold - a small label that still needs emphasis (distinct
  /// from [labelXs], which is specifically the uppercase eyebrow style).
  TextStyle get labelSmBold =>
      labelSmall!.copyWith(fontWeight: FontWeight.w700);

  /// `headline-md` pushed one step, semibold - section headers within a
  /// screen (e.g. "Recent transactions", "Cash Flow").
  TextStyle get headlineMdStrong =>
      titleMedium!.copyWith(fontWeight: FontWeight.w600);

  /// `headline-lg` pushed to extra-bold - the most common "screen/sheet
  /// title" weight: dialog titles, form sheet headers, card titles.
  TextStyle get headlineLgStrong =>
      titleLarge!.copyWith(fontWeight: FontWeight.w800);

  /// `headlineSmall`, extra-bold - an alternate large title.
  TextStyle get headlineSmBold =>
      headlineSmall!.copyWith(fontWeight: FontWeight.w800);

  /// `headlineMedium`, extra-bold - the amount being edited.
  TextStyle get amountDisplayBold =>
      headlineMedium!.copyWith(fontWeight: FontWeight.w800);

  /// `headlineMedium`, black (w900) - the dashboard's total balance.
  TextStyle get headlineDisplayStrong =>
      headlineMedium!.copyWith(fontWeight: FontWeight.w900);

  /// A small uppercase eyebrow label. Callers upper-case the text themselves.
  TextStyle get labelXs =>
      labelSmall!.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.4);
}

extension ThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;

  TextTheme get textTheme => Theme.of(this).textTheme;

  TextStyle get bodyMdStrong => textTheme.bodyMdStrong;
  TextStyle get bodyMdBold => textTheme.bodyMdBold;
  TextStyle get bodySmBold => textTheme.bodySmBold;
  TextStyle get labelLgStrong => textTheme.labelLgStrong;
  TextStyle get labelSmBold => textTheme.labelSmBold;
  TextStyle get headlineMdStrong => textTheme.headlineMdStrong;
  TextStyle get headlineLgStrong => textTheme.headlineLgStrong;
  TextStyle get headlineSmBold => textTheme.headlineSmBold;
  TextStyle get amountDisplayBold => textTheme.amountDisplayBold;
  TextStyle get headlineDisplayStrong => textTheme.headlineDisplayStrong;
  TextStyle get labelXs => textTheme.labelXs;
}
