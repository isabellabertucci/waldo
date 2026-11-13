import 'package:flutter/material.dart';

/// The leather wallets' colours (DESIGN.md "Wallets"): the same in both
/// themes, since a wallet is a physical object.
class LeatherColors {
  LeatherColors._();

  /// Each leather as (top, deep, strap): the 150° gradient runs top to deep;
  /// the strap is a tone off the same leather - lighter on black, darker on
  /// the light ones - so it reads as a separate piece.
  static const black = (
    Color(0xFF2E2E30),
    Color(0xFF121213),
    Color(0xFF56565B),
  );
  // Soft, in the green's tone, so it never reads as the yellow main action.
  static const yellow = (
    Color(0xFFFAEDB4),
    Color(0xFFF2DE82),
    Color(0xFFEFD670),
  );
  static const green = (
    Color(0xFFCDE8C3),
    Color(0xFFA9D29B),
    Color(0xFF9CCB8C),
  );
  static const white = (
    Color(0xFFFFFFFF),
    Color(0xFFECEAE5),
    Color(0xFFE3DED4),
  );

  /// The dashed stitch on black leather, and on the light ones.
  static const stitchOnDark = Color.from(
    alpha: 0.28,
    red: 1,
    green: 1,
    blue: 1,
  );
  static const stitchOnLight = Color.from(
    alpha: 0.24,
    red: 0.0784,
    green: 0.0784,
    blue: 0.0784,
  );

  /// Text on black leather, and its gain and loss colours.
  static const onDark = Color(0xFFFFFFFF);
  static const positiveOnDark = Color(0xFF8FD3A5);
  static const negativeOnDark = Color(0xFFFF9B8F);

  /// Text on the light leathers, and their gain and loss colours.
  static const onLight = Color(0xFF141414);
  static const positiveOnLight = Color(0xFF1F5E3A);
  static const negativeOnLight = Color(0xFFA3201F);

  /// Hot-stamped lettering: pressed into the leather, so a line of light
  /// under each letter and a shade over it. Stronger on the light leathers,
  /// where light catches more.
  static const debossLightOnLight = Color.from(
    alpha: 0.55,
    red: 1,
    green: 1,
    blue: 1,
  );
  static const debossShadeOnLight = Color.from(
    alpha: 0.18,
    red: 0,
    green: 0,
    blue: 0,
  );
  static const debossLightOnDark = Color.from(
    alpha: 0.12,
    red: 1,
    green: 1,
    blue: 1,
  );
  static const debossShadeOnDark = Color.from(
    alpha: 0.6,
    red: 0,
    green: 0,
    blue: 0,
  );

  /// The metal button on the strap: a radial highlight, `rivet`, a shade.
  static const rivet = [
    Color(0xFFFFFFFF),
    Color(0xFFB9BABF),
    Color(0xFF8E8F94),
  ];

  /// The button's rim - the one "shadow" the design system allows.
  static const rivetRim = Color.from(alpha: 0.12, red: 0, green: 0, blue: 0);
}
