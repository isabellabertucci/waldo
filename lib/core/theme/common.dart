import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waldo/core/theme/app_colors.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

class Common {
  Common._();

  /// Dark status bar text on the light theme, light on the dark one.
  static SystemUiOverlayStyle getSystemBarsStyle(
    AppColors colors,
    Brightness brightness,
  ) {
    final isDark = brightness == Brightness.dark;
    final icons = isDark ? Brightness.light : Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: colors.transparent,
      systemNavigationBarColor: colors.transparent,
      // Otherwise Android adds its own grey scrim behind the 3 buttons.
      systemNavigationBarContrastEnforced: false,
      statusBarIconBrightness: icons,
      systemNavigationBarIconBrightness: icons,
      statusBarBrightness: brightness, // iOS
    );
  }

  static AppBarTheme getAppBarTheme(AppColors colors, Brightness brightness) {
    return AppBarTheme(
      backgroundColor: colors.transparent,
      centerTitle: false,
      // Without it, the transparent background reads as dark: white text.
      systemOverlayStyle: getSystemBarsStyle(colors, brightness),
    );
  }

  static FloatingActionButtonThemeData getFloatingActionButtonTheme(
    AppColors colors,
  ) {
    return FloatingActionButtonThemeData(
      elevation: 0,
      backgroundColor: colors.ink,
      foregroundColor: colors.onInk,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rounded.pill),
      ),
    );
  }

  static CardThemeData getCardTheme(AppColors colors) {
    return CardThemeData(
      color: colors.sheet,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rounded.lg),
      ),
    );
  }

  static DialogThemeData getDialogTheme(AppColors colors) {
    return DialogThemeData(
      backgroundColor: colors.sheet,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rounded.lg),
      ),
    );
  }

  static SnackBarThemeData getSnackBarTheme(AppColors colors) {
    // The leather pair, so the snackbar is a dark pill with readable text in
    // both themes (`onSurface` turns light in dark mode).
    return SnackBarThemeData(
      // Slightly lighter than `leather`, so it shows against the dark-mode page.
      backgroundColor: Color.lerp(colors.leather, colors.inkMuted, 0.25),
      contentTextStyle: TextStyle(color: colors.onLeather),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rounded.pill),
      ),
      behavior: SnackBarBehavior.floating,
      actionTextColor: colors.negative,
    );
  }

  /// The hairline between rows of a card: one pixel, no extra space.
  static DividerThemeData getDividerTheme(AppColors colors) {
    return DividerThemeData(color: colors.line, thickness: 1, space: 1);
  }

  static BottomSheetThemeData getBottomSheetTheme(AppColors colors) {
    return BottomSheetThemeData(backgroundColor: colors.sheet);
  }

  static ListTileThemeData getListTileTheme(AppColors colors) {
    return ListTileThemeData(
      tileColor: colors.sheet,
      textColor: colors.ink,
      iconColor: colors.inkMuted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rounded.lg),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
    );
  }

  static InputDecorationThemeData getInputDecorationTheme(AppColors colors) {
    return InputDecorationThemeData(
      filled: true,
      fillColor: colors.card,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: 10,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: TextStyle(color: colors.inkMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rounded.md),
        borderSide: BorderSide(color: colors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rounded.md),
        borderSide: BorderSide(color: colors.ink, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rounded.md),
        borderSide: BorderSide(color: colors.negative, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rounded.md),
        borderSide: BorderSide(color: colors.negative, width: 2),
      ),
    );
  }

  static DatePickerThemeData getDatePickerTheme(AppColors colors) {
    // The selected day (today included) is an ink disc with on-primary text,
    // like every other selected pill in the app.
    Color? selectedFill(Set<WidgetState> states) =>
        states.contains(WidgetState.selected) ? colors.ink : null;

    return DatePickerThemeData(
      backgroundColor: colors.sheet,
      surfaceTintColor: colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rounded.lg),
      ),

      dayBackgroundColor: WidgetStateProperty.resolveWith(selectedFill),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colors.onInk;
        if (states.contains(WidgetState.disabled)) {
          return colors.inkMuted.withValues(alpha: 0.4);
        }
        return colors.ink;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith(selectedFill),
      todayForegroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.onInk
            // Ink, as every state: green is only for amounts.
            : colors.ink,
      ),
      yearBackgroundColor: WidgetStateProperty.resolveWith(selectedFill),
      yearForegroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? colors.onInk : colors.ink,
      ),

      dividerColor: colors.inkMuted.withValues(alpha: 0.12),
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: colors.inkMuted),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: colors.ink),
    );
  }

  /// Same pill and `label-lg-strong` as `PillButton`, the app's
  /// primary button, for any plain `FilledButton`.
  static FilledButtonThemeData getFilledButtonTheme(
    AppColors colors,
    TextTheme textTheme,
  ) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.ink,
        foregroundColor: colors.onInk,
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Rounded.pill),
        ),
        textStyle: textTheme.bodyStrong,
      ),
    );
  }
}
