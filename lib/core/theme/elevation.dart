import 'package:flutter/material.dart';

/// Waldo is almost entirely flat - most surfaces sit directly on the page
/// with no shadow, separated only by a `surface`/`surfaceContainer` color
/// step. These two levels cover the rare cases that need to visibly lift
/// off the page: a large, low-opacity spread rather than a hard drop
/// shadow, so elevation reads as "resting slightly above" rather than a
/// directional light source.
class Elevation {
  Elevation._();

  static const none = <BoxShadow>[];

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

  /// `shadowColor` form of [high], for widgets (`Card`, `Material`) that
  /// take a single shadow color + `elevation` rather than a `BoxShadow`
  /// list.
  static const highShadowColor = Color(0x1F000000);
}
