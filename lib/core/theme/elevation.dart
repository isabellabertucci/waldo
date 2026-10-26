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
}
