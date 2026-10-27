import 'package:flutter/painting.dart';

/// The colours of Waldo's two materials, the brushed metal of the wallet
/// cards and the leather of the balance pouch. They don't follow the light
/// and dark themes the way [AppColors] does: they imitate real objects.
class FinishColors {
  FinishColors._();

  /// Dark-mode metal, as (edge, shine): the lighter shine runs across the
  /// middle of the card's gradient. Light mode uses a photo instead.
  static const (Color, Color) platinumDark = (
    Color(0xFF1C1E21),
    Color(0xFF6E7378),
  );
  static const (Color, Color) goldDark = (Color(0xFF241A0E), Color(0xFF8C6A3C));
  static const (Color, Color) bronzeDark = (
    Color(0xFF241310),
    Color(0xFF8A5244),
  );

  /// Engraved text on metal: a light edge below, a dark one above.
  static const engravedHighlight = Color(0x8CFFFFFF);
  static const engravedShadow = Color(0x4D000000);

  /// How much lighter than dark-mode `error` a negative balance is on the
  /// dark metal, where plain `error` drops to about 1.7:1 on the shine.
  static const negativeOnMetalLift = 0.18;

  /// White light falling across the leather, and how much of it shows.
  static const leatherSheen = Color(0xFFFFFFFF);
  static const leatherSheenAmount = 0.1;
}
