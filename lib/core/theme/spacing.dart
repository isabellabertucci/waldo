class Spacing {
  Spacing._();

  // Micro scale - inside small, dense widgets (toggles, chips).
  static const double xxs = 4; // space-1
  static const double component = 12; // space-3

  // Page scale - gaps between sections, cards, and list rows.
  static const double xs = 8; // space-2
  static const double sm = 16; // space-4
  static const double md = 24; // space-5
  static const double lg = 32; // space-6
  static const double xl = 56; // space-7

  /// The side margin every page uses for its outer content - the single
  /// source of truth so it never drifts out of sync between screens.
  static const double pageMargin = 16;

  /// The widest a page gets on a tablet; matches the 640 Material gives
  /// bottom sheets, so a sheet lines up with the page under it.
  static const double maxPageWidth = 640;
}
