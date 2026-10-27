/// How strongly a colour shows over what's behind it: the opacity steps a
/// widget picks from instead of a number of its own.
class Alpha {
  Alpha._();

  /// A barely-there tint: a track behind segments, a hint disc.
  static const faint = 0.06;

  /// A pressed or tinted surface: an ink highlight, a delete disc.
  static const tint = 0.08;

  /// A soft fill: a badge disc, the sheet grabber, a splash.
  static const soft = 0.12;

  /// A visible but quiet shape: the undo bar's countdown track.
  static const medium = 0.18;

  /// The stitch, a receipt's dotted leader, a chart's fill.
  static const stitch = 0.3;

  /// A line or outline that must read as one: a dashed guide or border.
  static const line = 0.4;

  /// Secondary ink on a coloured or textured surface.
  static const muted = 0.6;

  /// Ink that is nearly full, just a touch quieter than the main text.
  static const strong = 0.8;
}
