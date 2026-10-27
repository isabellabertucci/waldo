import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.transparent,
    required this.surface,
    required this.onSurface,
    required this.surfaceContainer,
    required this.primary,
    required this.primaryStrong,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onSurfaceVariant,
    required this.error,
    required this.fieldFill,
    required this.fieldBorder,
    required this.leather,
    required this.onLeather,
  });

  final Color transparent;
  final Color surface;
  final Color onSurface;
  final Color surfaceContainer;
  final Color primary;
  // Pure black / pure white, for the few things that must stand out most
  // (income amounts, links). Not for filled buttons - use `primary`.
  final Color primaryStrong;
  final Color primaryContainer;
  final Color onPrimary;
  final Color onSurfaceVariant;
  final Color error;
  // Neutral gray, so text fields stand apart from the cream surfaces.
  final Color fieldFill;
  final Color fieldBorder;
  // The leather wallet card: the same in both themes, since it's a physical object.
  final Color leather;
  final Color onLeather;

  /// Canvas Cream background, Lifted Cream surfaces, Ink Black CTAs,
  /// Signal Orange as the single sparing accent (errors/destructive only).
  static const light = AppColors(
    transparent: Colors.transparent,
    surface: Color(0xFFFCFBFA),
    onSurface: Color(0xFF141413),
    surfaceContainer: Color(0xFFF3F0EE),
    primary: Color(0xFF141413),
    primaryStrong: Color(0xFF000000),
    primaryContainer: Color(0xFFF4F4F4),
    onPrimary: Color(0xFFF3F0EE),
    onSurfaceVariant: Color(0xFF696969),
    error: Color(0xFFC44100),
    fieldFill: Color(0xFFF5F5F5),
    fieldBorder: Color(0xFFEEEEEE),
    leather: Color(0xFF141413),
    onLeather: Color(0xFFF3F0EE),
  );

  /// Dark mode inverts the canvas/CTA relationship: Ink Black becomes the
  /// background, Canvas Cream becomes the CTA color.
  static const dark = AppColors(
    transparent: Colors.transparent,
    surface: Color(0xFF1F1D1B),
    onSurface: Color(0xFFF3F0EE),
    surfaceContainer: Color(0xFF141413),
    primary: Color(0xFFF3F0EE),
    primaryStrong: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF2A2724),
    onPrimary: Color(0xFF141413),
    onSurfaceVariant: Color(0xFFA39E97),
    error: Color(0xFFF37338),
    fieldFill: Color(0xFF242422),
    fieldBorder: Color(0xFF353330),
    leather: Color(0xFF141413),
    onLeather: Color(0xFFF3F0EE),
  );

  @override
  AppColors copyWith({
    Color? transparent,
    Color? surface,
    Color? onSurface,
    Color? surfaceContainer,
    Color? primary,
    Color? primaryStrong,
    Color? primaryContainer,
    Color? onPrimary,
    Color? onSurfaceVariant,
    Color? error,
    Color? fieldFill,
    Color? fieldBorder,
    Color? leather,
    Color? onLeather,
  }) {
    return AppColors(
      transparent: transparent ?? this.transparent,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      primary: primary ?? this.primary,
      primaryStrong: primaryStrong ?? this.primaryStrong,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimary: onPrimary ?? this.onPrimary,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      error: error ?? this.error,
      fieldFill: fieldFill ?? this.fieldFill,
      fieldBorder: fieldBorder ?? this.fieldBorder,
      leather: leather ?? this.leather,
      onLeather: onLeather ?? this.onLeather,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      transparent: Color.lerp(transparent, other.transparent, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryStrong: Color.lerp(primaryStrong, other.primaryStrong, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onSurfaceVariant: Color.lerp(
        onSurfaceVariant,
        other.onSurfaceVariant,
        t,
      )!,
      error: Color.lerp(error, other.error, t)!,
      fieldFill: Color.lerp(fieldFill, other.fieldFill, t)!,
      fieldBorder: Color.lerp(fieldBorder, other.fieldBorder, t)!,
      leather: Color.lerp(leather, other.leather, t)!,
      onLeather: Color.lerp(onLeather, other.onLeather, t)!,
    );
  }
}
