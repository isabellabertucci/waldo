import 'package:flutter/material.dart';

class AppColors {
  const AppColors._({
    required this.transparent,
    required this.surface,
    required this.onSurface,
    required this.surfaceContainer,
    required this.primary,
    required this.primaryStrong,
    required this.primaryContainer,
    required this.secondary,
    required this.onPrimary,
    required this.onSurfaceVariant,
    required this.error,
  });

  final Color transparent;
  final Color surface;
  final Color onSurface;
  final Color surfaceContainer;
  final Color primary;
  final Color primaryStrong;
  final Color primaryContainer;
  final Color secondary;
  final Color onPrimary;
  final Color onSurfaceVariant;
  final Color error;

  static const light = AppColors._(
    transparent: Colors.transparent,
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF131412),
    surfaceContainer: Color(0xFFF3F5F2),
    primary: Color(0xFF63DC78),
    primaryStrong: Color(0xFF177B3D),
    primaryContainer: Color(0xFFE3F6D8),
    secondary: Color(0xFF38C8FF),
    onPrimary: Color(0xFF0E0F0C),
    onSurfaceVariant: Color(0xFF4A4B47),
    error: Color(0xFFFF383C),
  );

  static const dark = AppColors._(
    transparent: Colors.transparent,
    surface: Color(0xFF1E221E),
    onSurface: Color(0xFFE8EBE5),
    surfaceContainer: Color(0xFF141715),
    primary: Color(0xFF6FDF84),
    primaryStrong: Color(0xFF6FDF84),
    primaryContainer: Color(0xFF1D3527),
    secondary: Color(0xFF4CCFFF),
    onPrimary: Color(0xFF0D130F),
    onSurfaceVariant: Color(0xFFB4B8B1),
    error: Color(0xFFFF383C),
  );
}
