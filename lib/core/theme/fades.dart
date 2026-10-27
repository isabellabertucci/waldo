import 'package:flutter/painting.dart';

/// Masks that fade content out at an edge. Only their opacity is read
/// (`BlendMode.dstIn`), so their colours are never painted.
class Fades {
  Fades._();

  /// A horizontal row's ends, so items slide in and out instead of being cut.
  static const rowEdges = LinearGradient(
    colors: [
      Color(0x00000000),
      Color(0xFF000000),
      Color(0xFF000000),
      Color(0x00000000),
    ],
    stops: [0, 0.04, 0.92, 1],
  );
}
