class Spacing {
  Spacing._();

  // Micro scale - inside small, dense widgets (toggles, chips).
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
