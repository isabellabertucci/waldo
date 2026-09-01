import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_colors.dart';
import 'package:waldo/core/theme/rounded.dart';

class Common {
  Common._();

  static NavigationBarThemeData getNavigationBarTheme(AppColors color) {
    return NavigationBarThemeData(
      backgroundColor: color.surface,
      indicatorColor: color.primaryContainer,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? color.primaryStrong : color.onSurfaceVariant,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          color: selected ? color.primaryStrong : color.onSurfaceVariant,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        );
      }),
    );
  }

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
        borderRadius: BorderRadius.circular(Rounded.xl),
      ),
    );
  }

  static SnackBarThemeData getSnackBarTheme(AppColors colors) {
    return SnackBarThemeData(
      backgroundColor: colors.onSurface,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rounded.pill),
      ),
      behavior: SnackBarBehavior.floating,
      actionTextColor: colors.primary,
    );
  }

  static BottomSheetThemeData getBottomSheetTheme(AppColors colors) {
    return BottomSheetThemeData(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Rounded.xl)),
      ),
    );
  }

  static ListTileThemeData getListTileTheme(AppColors colors) {
    return ListTileThemeData(
      tileColor: colors.surface,
      textColor: colors.onSurface,
      iconColor: colors.onSurfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rounded.xl),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 6,
      ), // era 12
    );
  }

  static InputDecorationThemeData getInputDecorationTheme(AppColors colors) {
    return InputDecorationThemeData(
      filled: true,
      fillColor: colors.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: TextStyle(color: colors.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rounded.lg),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rounded.lg),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rounded.lg),
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Rounded.lg),
        borderSide: BorderSide(color: colors.error, width: 2),
      ),
    );
  }
}
