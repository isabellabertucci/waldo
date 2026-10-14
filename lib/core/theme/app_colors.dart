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
  // A punchier tonal step beyond `primary` - same ink/cream hue family,
  // pushed to the far end (pure black / pure white) rather than a new
  // color - reserved for the few things that need to read as the single
  // most emphasized element on a plain surface (income amounts, the "see
  // all" link, the date picker's "today" marker). Not a substitute for
  // `primary` on filled buttons/chips.
  final Color primaryStrong;
  final Color primaryContainer;
  final Color onPrimary;
  final Color onSurfaceVariant;
  final Color error;
  // Neutral gray, deliberately not tinted toward the warm cream palette -
  // text fields need to read as "a field", visually distinct from the cream
  // cards and page background around them.
  final Color fieldFill;
  final Color fieldBorder;
  // The wallet/balance card's own dark leather material - a physical
  // object, not a themed surface, so unlike `primary` (which deliberately
  // inverts in dark mode as the CTA color) this pair stays the same dark
  // ink + cream text in both themes. A real leather wallet doesn't turn
  // pale just because the room lights dimmed.
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
    error: Color(0xFFCF4500),
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
