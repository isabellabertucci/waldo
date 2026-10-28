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
      dividerTheme: Common.getDividerTheme(colors),
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
/// A weight suffix always means the same: Strong w600, Bold w700,
/// ExtraBold w800, Black w900.
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
  TextStyle get labelLgBold =>
      labelLarge!.copyWith(fontWeight: FontWeight.w700);

  /// `label-sm`, bold - a small label that still needs emphasis (distinct
  /// from [labelXs], which is specifically the uppercase eyebrow style).
  TextStyle get labelSmBold =>
      labelSmall!.copyWith(fontWeight: FontWeight.w700);

  /// `headline-md` pushed one step, semibold - section headers within a
  /// screen (e.g. "Recent transactions", "Cash flow").
  TextStyle get headlineMdStrong =>
      titleMedium!.copyWith(fontWeight: FontWeight.w600);

  /// `headline-lg` pushed to extra-bold - the most common "screen/sheet
  /// title" weight: dialog titles, form sheet headers, card titles.
  TextStyle get headlineLgExtraBold =>
      titleLarge!.copyWith(fontWeight: FontWeight.w800);

  /// `headlineSmall`, extra-bold - an alternate large title.
  TextStyle get headlineSmExtraBold =>
      headlineSmall!.copyWith(fontWeight: FontWeight.w800);

  /// `headlineMedium`, extra-bold - the amount being edited.
  TextStyle get amountDisplayExtraBold =>
      headlineMedium!.copyWith(fontWeight: FontWeight.w800);

  /// `headlineMedium`, black (w900) - the dashboard's total balance.
  TextStyle get headlineDisplayBlack =>
      headlineMedium!.copyWith(fontWeight: FontWeight.w900);

  /// A small uppercase eyebrow label. Callers upper-case the text themselves.
  TextStyle get labelXs =>
      labelSmall!.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.4);

  /// `body-sm`, semibold - an unselected choice beside a bold selected one,
  /// and the name on the wallet card peeking behind the balance.
  TextStyle get bodySmStrong =>
      bodySmall!.copyWith(fontWeight: FontWeight.w600);

  /// `body-md`, extra-bold - a figure that must win its line, e.g. the
  /// balance after a wallet's type.
  TextStyle get bodyMdExtraBold =>
      bodyMedium!.copyWith(fontWeight: FontWeight.w800);

  /// The balance figure on a wallet card.
  TextStyle get walletCardBalance =>
      titleMedium!.copyWith(fontWeight: FontWeight.w800);

  /// An unselected month pill: a step under `body-md`, so the selected
  /// month ([bodyMdBold]) reads larger.
  TextStyle get monthPill =>
      bodyMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500);

  /// A line printed on the month receipt; [receiptLineBold] for totals.
  TextStyle get receiptLine =>
      bodyMedium!.copyWith(fontSize: 12.5, fontWeight: FontWeight.w400);
  TextStyle get receiptLineBold =>
      receiptLine.copyWith(fontWeight: FontWeight.w700);

  /// The receipt's bottom line (the net), larger than the rest.
  TextStyle get receiptTotal =>
      bodyMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.w700);

  /// The receipt's small, widely tracked header ("WALDO · OCTOBER 2026").
  TextStyle get receiptHeader =>
      bodySmall!.copyWith(fontSize: 11, letterSpacing: 0.8);

  /// The cash flow chart's month labels: `body-md`, the default text style,
  /// a size smaller.
  TextStyle get chartAxis => bodyMedium!.copyWith(fontSize: 11);
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

  TextStyle get bodyMdStrong => textTheme.bodyMdStrong;
  TextStyle get bodyMdBold => textTheme.bodyMdBold;
  TextStyle get bodySmBold => textTheme.bodySmBold;
  TextStyle get labelLgBold => textTheme.labelLgBold;
  TextStyle get labelSmBold => textTheme.labelSmBold;
  TextStyle get headlineMdStrong => textTheme.headlineMdStrong;
  TextStyle get headlineLgExtraBold => textTheme.headlineLgExtraBold;
  TextStyle get headlineSmExtraBold => textTheme.headlineSmExtraBold;
  TextStyle get amountDisplayExtraBold => textTheme.amountDisplayExtraBold;
  TextStyle get headlineDisplayBlack => textTheme.headlineDisplayBlack;
  TextStyle get labelXs => textTheme.labelXs;
  TextStyle get bodySmStrong => textTheme.bodySmStrong;
  TextStyle get bodyMdExtraBold => textTheme.bodyMdExtraBold;
  TextStyle get walletCardBalance => textTheme.walletCardBalance;
  TextStyle get monthPill => textTheme.monthPill;
  TextStyle get receiptLine => textTheme.receiptLine;
  TextStyle get receiptLineBold => textTheme.receiptLineBold;
  TextStyle get receiptTotal => textTheme.receiptTotal;
  TextStyle get receiptHeader => textTheme.receiptHeader;
  TextStyle get chartAxis => textTheme.chartAxis;
}
