import 'package:flutter/material.dart';

/// The Waldo design system's palette (DESIGN.md "Colors"). Each field has
/// its design token's name (`ink-muted` is [inkMuted]), so code and design
/// system read the same.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.transparent,
    required this.bg,
    required this.bgTop,
    required this.sheet,
    required this.card,
    required this.chip,
    required this.line,
    required this.divider,
    required this.ink,
    required this.onInk,
    required this.inkMuted,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.positive,
    required this.negative,
    required this.navActive,
    required this.onNavActive,
    required this.leather,
    required this.onLeather,
  });

  final Color transparent;

  /// `bg`: the page under everything.
  final Color bg;

  /// `bg-top`: where the page's top gradient starts, fading into `bg`.
  final Color bgTop;

  /// `sheet`: the white sheet content sits on, and cards over the page.
  final Color sheet;

  /// `card`: blocks inside a sheet, fields, segmented controls, icon discs.
  final Color card;

  /// `chip`: round buttons and pills on the page (secondary action circles).
  final Color chip;

  /// `line`: 1px outlines (round buttons, the navbar, menus) and the
  /// hairlines inside a `card` block - the design separates by colour and
  /// outline, never by shadow.
  final Color line;

  /// `divider`: hairlines between rows of a list on the white sheet (the
  /// transactions). Inside a `card` block rows divide with [line] instead,
  /// which still shows on the card.
  final Color divider;

  /// `ink`: text and icons on every surface, and the ink fill - the picked
  /// side of a segmented choice, ink buttons.
  final Color ink;

  /// Text and icons on an [ink] fill. Not a design system name: the
  /// system writes it as "white on ink" (DESIGN.md "Colors").
  final Color onInk;

  /// `ink-muted`: secondary text (labels, metadata).
  final Color inkMuted;

  /// `primary`: the yellow of the one main action on a screen, never text.
  final Color primary;

  /// `on-primary`: text and icons on [primary].
  final Color onPrimary;

  /// `accent`: details and good news - the month's change pill, an active
  /// filter, a picked option's disc.
  final Color accent;

  /// `on-accent`: text and icons on [accent].
  final Color onAccent;

  /// `positive`: a gain - sign and figure together.
  final Color positive;

  /// `negative`: a loss, errors and destructive actions.
  final Color negative;

  /// `nav-active`: the navbar's chosen tab - ink in light, the yellow in
  /// dark, where a white pill would glare.
  final Color navActive;

  /// `on-nav-active`: the chosen tab's icon and label.
  final Color onNavActive;

  // The undo bar: the same in both themes, as leather is.
  final Color leather;

  final Color onLeather;

  static const light = AppColors(
    transparent: Colors.transparent,
    bg: Color(0xFFEFEEEA),
    bgTop: Color(0xFFE6E1D8),
    sheet: Color(0xFFFFFFFF),
    card: Color(0xFFF4F2EC),
    chip: Color(0xFFFFFFFF),
    line: Color(0xFFE3DED4),
    divider: Color(0xFFEFEEEA),
    ink: Color(0xFF141414),
    onInk: Color(0xFFFFFFFF),
    inkMuted: Color(0xFF6B6B70),
    primary: Color(0xFFF3D33F),
    onPrimary: Color(0xFF141414),
    accent: Color(0xFFBFE0B4),
    onAccent: Color(0xFF141414),
    positive: Color(0xFF2E7D4F),
    negative: Color(0xFFC62828),
    navActive: Color(0xFF141414),
    onNavActive: Color(0xFFFFFFFF),
    leather: Color(0xFF141414),
    onLeather: Color(0xFFFFFFFF),
  );

  /// Near-black page, the sheet a step up, cards a step above that.
  static const dark = AppColors(
    transparent: Colors.transparent,
    bg: Color(0xFF141414),
    bgTop: Color(0xFF1E1E20),
    sheet: Color(0xFF1C1C1E),
    card: Color(0xFF26262A),
    chip: Color(0xFF323236),
    line: Color(0xFF38383C),
    divider: Color(0xFF2A2A2D),
    ink: Color(0xFFFFFFFF),
    onInk: Color(0xFF141414),
    inkMuted: Color(0xFFA3A3A8),
    primary: Color(0xFFF3D33F),
    onPrimary: Color(0xFF141414),
    accent: Color(0xFFBFE0B4),
    onAccent: Color(0xFF141414),
    positive: Color(0xFF8FD3A5),
    negative: Color(0xFFFF9B8F),
    navActive: Color(0xFFF3D33F),
    onNavActive: Color(0xFF141414),
    leather: Color(0xFF141414),
    onLeather: Color(0xFFFFFFFF),
  );

  @override
  AppColors copyWith({
    Color? transparent,
    Color? bg,
    Color? bgTop,
    Color? sheet,
    Color? card,
    Color? chip,
    Color? line,
    Color? divider,
    Color? ink,
    Color? onInk,
    Color? inkMuted,
    Color? primary,
    Color? onPrimary,
    Color? accent,
    Color? onAccent,
    Color? positive,
    Color? negative,
    Color? navActive,
    Color? onNavActive,
    Color? leather,
    Color? onLeather,
  }) {
    return AppColors(
      transparent: transparent ?? this.transparent,
      bg: bg ?? this.bg,
      bgTop: bgTop ?? this.bgTop,
      sheet: sheet ?? this.sheet,
      card: card ?? this.card,
      chip: chip ?? this.chip,
      line: line ?? this.line,
      divider: divider ?? this.divider,
      ink: ink ?? this.ink,
      onInk: onInk ?? this.onInk,
      inkMuted: inkMuted ?? this.inkMuted,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      navActive: navActive ?? this.navActive,
      onNavActive: onNavActive ?? this.onNavActive,
      leather: leather ?? this.leather,
      onLeather: onLeather ?? this.onLeather,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      transparent: Color.lerp(transparent, other.transparent, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      bgTop: Color.lerp(bgTop, other.bgTop, t)!,
      sheet: Color.lerp(sheet, other.sheet, t)!,
      card: Color.lerp(card, other.card, t)!,
      chip: Color.lerp(chip, other.chip, t)!,
      line: Color.lerp(line, other.line, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      onInk: Color.lerp(onInk, other.onInk, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      navActive: Color.lerp(navActive, other.navActive, t)!,
      onNavActive: Color.lerp(onNavActive, other.onNavActive, t)!,
      leather: Color.lerp(leather, other.leather, t)!,
      onLeather: Color.lerp(onLeather, other.onLeather, t)!,
    );
  }
}
