import 'package:flutter/painting.dart';

/// Dimensions that belong to one component, kept with the other tokens so a
/// widget never holds a raw number. Shared steps live in [Spacing],
/// `BadgeSize` and `IconSize`; the shape of a drawing (the pouch's curve,
/// the barcode's bars) stays in its painter.
class ComponentSize {
  ComponentSize._();

  // Leather wallet (DESIGN.md "Wallets")

  /// A full-size wallet's height; its width follows the page.
  static const wallet = 180.0;

  /// The strap: a square tab on the wallet's right edge, poking past it by
  /// [walletStrapOverhang], and the metal button on it.
  /// A wallet shown alone (its own screen): wallet-shaped, not stretched
  /// to the page's width - about the front one in Home's stack.
  static const walletAloneWidth = 264.0;

  /// The wallet form's preview: the wallet alone, scaled down.
  static const walletPreview = Size(211, 144);

  /// A leather swatch in the wallet form, and the ink ring (with a gap)
  /// around the chosen one.
  static const swatch = 52.0;
  static const swatchRing = 2.5;
  static const swatchRingGap = 3.0;

  static const walletStrap = 46.0;
  static const walletStrapOverhang = 4.0;
  static const walletRivet = 15.0;
  static const walletRivetRim = 2.0;

  /// Room the content leaves for the strap.
  static const walletStrapRoom = 66.0;

  /// A wallet's thumbnail in a list row, and how much larger it's drawn
  /// before being scaled down to it.
  static const walletThumb = Size(64, 48);
  static const walletThumbScale = 2.5;

  // Empty states (DESIGN.md "Empty states")

  /// A ghost's line of text: its thickness, and how much of the row a title
  /// and a subtitle take.
  static const ghostLine = 10.0;
  static const ghostTitle = 0.55;
  static const ghostSubtitle = 0.35;

  /// A ghost row's amount, at its end.
  static const ghostAmount = 56.0;

  /// A ghost wallet in Home's empty stack: of the page's width.
  static const ghostWalletWidth = 0.62;

  /// A wallet behind another in a stack: this much further right and down,
  /// and this much shorter.
  static const walletStackStep = Offset(40, 8);
  static const walletStackShrink = 16.0;

  /// The most wallets a stack shows.
  static const walletStackMax = 4;

  // Spending by day

  /// A category's bar under its name in "Spending by category".
  static const categoryBar = 6.0;

  // Action circles

  /// The round buttons over the page, labelled underneath.
  static const actionCircle = 58.0;

  /// The yellow dot on an action circle that's changing something (a filter
  /// that's on), and its ring.
  static const actionMark = 14.0;
  static const actionMarkRing = 2.0;

  // Month row

  /// The selected month's side padding: bolder and larger, it gives back
  /// 2px a side so it doesn't grow past its neighbours.
  static const monthSelectedPadding = 14.0;

  // Navbar

  /// The selected tab's vertical padding: one pixel more than an icon-only
  /// tab's, so the pill with its shorter label is just as tall.
  static const navSelectedPadding = 13.0;

  // Wallet cards

  /// A ⋮ menu's narrowest and widest, and the steps it grows by: Material's
  /// own popup menu sizes.
  static const menuMinWidth = 112.0;
  static const menuMaxWidth = 280.0;
  static const menuWidthStep = 56.0;

  // Sheet grabber

  static const grabber = Size(36, 4);

  // Undo bar

  /// The countdown ring.
  static const undoRing = 32.0;

  // Cash flow chart

  static const chartHeight = 160.0;
  static const chartLine = 2.5;
  static const chartGuide = 1.5;
  static const chartDotRadius = 4.0;
  static const chartDotRing = 2.0;

  /// The dashed guide under a touched point: dashes and gaps alike, in the
  /// whole pixels fl_chart takes.
  static const chartGuideDash = 4;

  // Receipt

  // Buttons

  /// A low-emphasis text button, shorter than a full-size one.
  static const compactButton = 32.0;
}
