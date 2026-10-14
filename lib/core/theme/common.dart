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
    // `onSurface` + a hardcoded white content color used to pair up by
    // coincidence in light mode (onSurface is dark there), but `onSurface`
    // flips to a light cream in dark mode - which left white-on-white text
    // and an invisible "Undo" action. A snackbar reads as a solid dark
    // pill either way, so it uses the theme-constant leather pair instead
    // of a token that was only ever dark by accident.
    return SnackBarThemeData(
      // A touch lighter than pure `leather`, not the flat color itself -
      // in dark mode the page behind it is the same near-black as
      // `leather`, so the pill had no visible edge to lift off the page
      // with (same issue as the dashboard's peek card).
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
    Color onColor(Color background) {
      return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }

    return DatePickerThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rounded.lg),
      ),

      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return onColor(colors.primaryStrong);
        }
        if (states.contains(WidgetState.disabled)) {
          return colors.onSurfaceVariant.withValues(alpha: 0.4);
        }
        return colors.onSurface;
      }),
      todayForegroundColor: WidgetStateProperty.all(colors.primaryStrong),

      dividerColor: colors.onSurfaceVariant.withValues(alpha: 0.12),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: colors.onSurfaceVariant,
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: colors.primaryStrong,
      ),
    );
  }

  static FilledButtonThemeData getFilledButtonTheme(AppColors colors) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Rounded.md),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }
}
