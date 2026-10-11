class Spacing {
  Spacing._();

  // Micro scale - internals of small, dense widgets (pill toggles, filter
  // chips, dialog action rows) where the page scale below reads as too
  // loose.
  static const double xxs = 4;
  static const double component = 12;

  // Page scale - gaps between sections, cards, and list rows.
  static const double xs = 8;
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
  static const double xl = 48;

  /// The side margin every page uses for its outer content - the single
  /// source of truth so it never drifts out of sync between screens.
  static const double pageMargin = 24;
}
