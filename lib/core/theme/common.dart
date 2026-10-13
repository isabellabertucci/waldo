import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_colors.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

class Common {
  Common._();

  static AppBarTheme getAppBarTheme(AppColors colors) {
    return AppBarTheme(backgroundColor: colors.transparent, centerTitle: false);
  }

  static FloatingActionButtonThemeData getFloatingActionButtonTheme(
    AppColors colors,
  ) {
    return FloatingActionButtonThemeData(
      elevation: 0,
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rounded.pill),
      ),
    );
  }

  static CardThemeData getCardTheme(AppColors colors) {
    return CardThemeData(
      color: colors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rounded.lg),
      ),
    );
  }

  static DialogThemeData getDialogTheme(AppColors colors) {
    return DialogThemeData(
      backgroundColor: colors.surface,
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
      backgroundColor: Color.lerp(
        colors.leather,
        colors.onSurfaceVariant,
        0.25,
      ),
      contentTextStyle: TextStyle(color: colors.onLeather),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rounded.pill),
      ),
      behavior: SnackBarBehavior.floating,
      actionTextColor: colors.error,
    );
  }

  static BottomSheetThemeData getBottomSheetTheme(AppColors colors) {
    return BottomSheetThemeData(backgroundColor: colors.surface);
  }

  static ListTileThemeData getListTileTheme(AppColors colors) {
    return ListTileThemeData(
      tileColor: colors.surface,
      textColor: colors.onSurface,
      iconColor: colors.onSurfaceVariant,
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
      fillColor: colors.fieldFill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: 10,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: TextStyle(color: colors.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rounded.md),
        borderSide: BorderSide(color: colors.fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rounded.md),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rounded.md),
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rounded.md),
        borderSide: BorderSide(color: colors.error, width: 2),
      ),
    );
  }

  static DatePickerThemeData getDatePickerTheme(AppColors colors) {
    // The selected day (today included) is an ink disc with on-primary text,
    // like every other selected pill in the app.
    Color? selectedFill(Set<WidgetState> states) =>
        states.contains(WidgetState.selected) ? colors.primary : null;

    return DatePickerThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rounded.lg),
      ),

      dayBackgroundColor: WidgetStateProperty.resolveWith(selectedFill),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colors.onPrimary;
        if (states.contains(WidgetState.disabled)) {
          return colors.onSurfaceVariant.withValues(alpha: 0.4);
        }
        return colors.onSurface;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith(selectedFill),
      todayForegroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.onPrimary
            : colors.primaryStrong,
      ),
      yearBackgroundColor: WidgetStateProperty.resolveWith(selectedFill),
      yearForegroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.onPrimary
            : colors.onSurface,
      ),

      dividerColor: colors.onSurfaceVariant.withValues(alpha: 0.12),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: colors.onSurfaceVariant,
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: colors.primaryStrong,
      ),
    );
  }

  /// Same pill and `label-lg-strong` as `DashedStitchButton`, the app's
  /// primary button, for any plain `FilledButton`.
  static FilledButtonThemeData getFilledButtonTheme(
    AppColors colors,
    TextTheme textTheme,
  ) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Rounded.pill),
        ),
        // label-lg-strong (context.labelLgStrong has no context here).
        textStyle: textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
