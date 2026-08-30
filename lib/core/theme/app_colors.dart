import 'package:flutter/material.dart';

class AppColors {
  const AppColors._({
    required this.transparent,
    required this.primary,
    required this.secondary,
    required this.onPrimary,
    required this.onSurfaceVariant,
    required this.bgGradient,
  });

  final Color transparent;
  final Color primary;
  final Color secondary;
  final Color onPrimary;
  final Color onSurfaceVariant;
  final LinearGradient bgGradient;

  static const _primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF192952), Color(0xFF000000)],
  );

  static const light = AppColors._(
    transparent: Colors.transparent,
    primary: Color(0xFF3758F9),
    secondary: Color(0xFF589AFF),
    onPrimary: Color(0xFFFFFFFF),
    onSurfaceVariant: Color(0xFFCCCCCC),
    bgGradient: _primaryGradient,
  );

  static const dark = AppColors._(
    transparent: Colors.transparent,
    primary: Color(0xFF3758F9),
    secondary: Color(0xFF589AFF),
    onPrimary: Color(0xFFFFFFFF),
    onSurfaceVariant: Color(0xFFCCCCCC),
    bgGradient: _primaryGradient,
  );
}
