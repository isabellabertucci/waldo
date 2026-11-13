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
      primary: colors.ink,
      onPrimary: colors.onInk,
      primaryContainer: colors.card,
      onPrimaryContainer: colors.ink,
      onSurfaceVariant: colors.inkMuted,
      error: colors.negative,
      // `onPrimary` already contrasts with `error` in both themes.
      onError: colors.onInk,
      surface: colors.sheet,
      onSurface: colors.ink,
      surfaceContainer: colors.bg,
      outline: colors.line,
      // Material 3 tints elevated surfaces toward `primary` by default;
      // Waldo's surfaces are flat, with no such tint anywhere.
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
      scaffoldBackgroundColor: colors.bg,
      extensions: [colors],

      appBarTheme: Common.getAppBarTheme(colors, brightness),
      floatingActionButtonTheme: Common.getFloatingActionButtonTheme(colors),
      cardTheme: Common.getCardTheme(colors),
      dialogTheme: Common.getDialogTheme(colors),
      snackBarTheme: Common.getSnackBarTheme(colors),
      bottomSheetTheme: Common.getBottomSheetTheme(colors),
      dividerTheme: Common.getDividerTheme(colors),
      listTileTheme: Common.getListTileTheme(colors),
      inputDecorationTheme: Common.getInputDecorationTheme(colors),
      datePickerTheme: Common.getDatePickerTheme(colors),
      filledButtonTheme: Common.getFilledButtonTheme(colors, textTheme),
    );
  }

  /// The design system's type scale (DESIGN.md "Typography"): one family,
  /// the hierarchy from size and weight alone.
  static TextTheme _applyTypeScale(TextTheme base) {
    TextStyle? style(
      TextStyle? from,
      double size,
      double lineHeight,
      FontWeight weight, [
      double trackingEm = 0,
    ]) => from?.copyWith(
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: size * trackingEm,
    );

    return base.copyWith(
      // `amount-hero`: the larger displays only ever show an amount.
      displayLarge: style(base.displayLarge, 32, 38, FontWeight.w700, -0.03),
      displayMedium: style(base.displayMedium, 32, 38, FontWeight.w700, -0.03),
      displaySmall: style(base.displaySmall, 32, 38, FontWeight.w700, -0.03),
      headlineLarge: style(base.headlineLarge, 32, 38, FontWeight.w700, -0.03),
      headlineMedium: style(
        base.headlineMedium,
        32,
        38,
        FontWeight.w700,
        -0.03,
      ),
      // `title-page`
      headlineSmall: style(base.headlineSmall, 28, 34, FontWeight.w700, -0.02),
      // `title-section`
      titleLarge: style(base.titleLarge, 20, 26, FontWeight.w700, -0.01),
      // `title-card`
      titleMedium: style(base.titleMedium, 16, 22, FontWeight.w600),
      // `body-strong`
      titleSmall: style(base.titleSmall, 15, 20, FontWeight.w600),
      // `body`
      bodyLarge: style(base.bodyLarge, 15, 20, FontWeight.w500),
      bodyMedium: style(base.bodyMedium, 15, 20, FontWeight.w500),
      // `label`
      bodySmall: style(base.bodySmall, 13, 18, FontWeight.w500),
      // `body-strong`: buttons
      labelLarge: style(base.labelLarge, 15, 20, FontWeight.w600),
      // `label`
      labelMedium: style(base.labelMedium, 13, 18, FontWeight.w500),
      // `caption`
      labelSmall: style(base.labelSmall, 12, 16, FontWeight.w500),
    );
  }
}

/// The DESIGN.md emphasis tokens. Defined on [TextTheme] so component themes,
/// which have no `context`, share them; widgets use the [ThemeContext] getters.
/// A weight suffix always means the same: Strong w600, Bold w700,
/// ExtraBold w800, Black w900.
extension AppTextStyles on TextTheme {
  /// `amount-hero`: the total balance only. Every amount style has tabular
  /// figures, so digits line up and don't jiggle as they change.
  TextStyle get amountHero => headlineMedium!.copyWith(fontFeatures: _tabular);

  /// `amount-wallet`: a balance inside a wallet - never larger, so it
  /// doesn't compete with the total.
  TextStyle get amountWallet => titleLarge!.copyWith(
    letterSpacing: titleLarge!.fontSize! * -0.02,
    fontFeatures: _tabular,
  );

  /// `amount-row`: an amount in a list row.
  TextStyle get amountRow => titleSmall!.copyWith(fontFeatures: _tabular);

  /// `title-page`: a page without a balance on top (Settings).
  TextStyle get titlePage => headlineSmall!;

  /// `title-section`: every section, never mixed with another size.
  TextStyle get titleSection => titleLarge!;

  /// `title-card`: a title inside a card.
  TextStyle get titleCard => titleMedium!;

  /// `body`: running text - a note, a field's value, a message.
  TextStyle get body => bodyMedium!;

  /// `body-strong`: a list row's name.
  TextStyle get bodyStrong => titleSmall!;

  /// `label`: labels and secondary text.
  TextStyle get label => bodySmall!;

  /// `caption`
  TextStyle get caption => labelSmall!;

  /// `overline`: a group header ("TODAY", "8 NOV."). Callers upper-case it.
  TextStyle get overline => labelSmall!.copyWith(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 11 * 0.1,
  );

  static const _tabular = [FontFeature.tabularFigures()];
}

extension ThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;

  TextTheme get textTheme => Theme.of(this).textTheme;

  /// The style a [Text] with [style] draws in: the inherited default plus
  /// [style], bold when the user turns on Bold Text, as [Text] does.
  TextStyle effectiveTextStyle(TextStyle? style) {
    final resolved = DefaultTextStyle.of(this).style.merge(style);
    return MediaQuery.boldTextOf(this)
        ? resolved.merge(const TextStyle(fontWeight: FontWeight.bold))
        : resolved;
  }

  TextStyle get amountHero => textTheme.amountHero;
  TextStyle get amountWallet => textTheme.amountWallet;
  TextStyle get amountRow => textTheme.amountRow;
  TextStyle get titlePage => textTheme.titlePage;
  TextStyle get titleSection => textTheme.titleSection;
  TextStyle get titleCard => textTheme.titleCard;
  TextStyle get body => textTheme.body;
  TextStyle get bodyStrong => textTheme.bodyStrong;
  TextStyle get label => textTheme.label;
  TextStyle get caption => textTheme.caption;
  TextStyle get overline => textTheme.overline;
}
