import 'package:flutter/material.dart';

/// Shadows for the few surfaces that lift off the page: a large, soft spread
/// rather than a hard drop shadow.
class Elevation {
  Elevation._();

  static const low = [
    BoxShadow(
      color: Color(0x0A000000), // Colors.black @ 4%
      offset: Offset(0, 4),
      blurRadius: 24,
    ),
  ];

  static const high = [
    BoxShadow(
      color: Color(0x1F000000), // Colors.black @ 12%
      offset: Offset(0, 4),
      blurRadius: 24,
    ),
  ];

  /// [high] as a single `shadowColor`, for widgets that take `elevation`.
  static const highShadowColor = Color(0x1F000000);

  /// The shade one stacked wallet card casts on the card below it, fading
  /// out downwards. Shadows stay black in both themes.
  static const stackShade = [
    Color.from(alpha: 0.16, red: 0, green: 0, blue: 0),
    Color.from(alpha: 0, red: 0, green: 0, blue: 0),
  ];
}
