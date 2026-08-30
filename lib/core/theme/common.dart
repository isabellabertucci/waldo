import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_colors.dart';

class Common {
  Common._();

  static NavigationBarThemeData getNavigationBarTheme(AppColors color) {
    return NavigationBarThemeData(
      backgroundColor: color.transparent,
      indicatorColor: color.transparent,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? color.secondary : color.onSurfaceVariant,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          color: selected ? color.secondary : color.onSurfaceVariant,
        );
      }),
    );
  }

  static AppBarTheme getAppBarTheme(AppColors colors) {
    return AppBarTheme(backgroundColor: colors.transparent);
  }

  static FloatingActionButtonThemeData getFloatingActionButtonTheme(
    AppColors colors,
  ) {
    return FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
    );
  }
}
