import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_colors.dart';
import 'package:waldo/core/theme/common.dart';
import 'package:google_fonts/google_fonts.dart';

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
      onSurfaceVariant: colors.onSurfaceVariant,
      error: colors.error,
    );

    final textTheme = GoogleFonts.interTextTheme(
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

      appBarTheme: Common.getAppBarTheme(colors),
      navigationBarTheme: Common.getNavigationBarTheme(colors),
      floatingActionButtonTheme: Common.getFloatingActionButtonTheme(colors),
      cardTheme: Common.getCardTheme(colors),
      dialogTheme: Common.getDialogTheme(colors),
      snackBarTheme: Common.getSnackBarTheme(colors),
      bottomSheetTheme: Common.getBottomSheetTheme(colors),
      listTileTheme: Common.getListTileTheme(colors),
      inputDecorationTheme: Common.getInputDecorationTheme(colors),
    );
  }
}

extension ThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).brightness == Brightness.dark
      ? AppColors.dark
      : AppColors.light;

  TextTheme get textTheme => Theme.of(this).textTheme;
}
