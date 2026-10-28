import 'package:flutter/painting.dart';

/// Dimensions that belong to one component, kept with the other tokens so a
/// widget never holds a raw number. Shared steps live in [Spacing],
/// `BadgeSize` and `IconSize`; the shape of a drawing (the pouch's curve,
/// the barcode's bars) stays in its painter.
class ComponentSize {
  ComponentSize._();

  // Month row

  /// The selected month's side padding: bolder and larger, it gives back
  /// 2px a side so it doesn't grow past its neighbours.
  static const monthSelectedPadding = 14.0;

  // Navbar

  /// The selected tab's vertical padding: one pixel more than an icon-only
  /// tab's, so the pill with its shorter label is just as tall.
  static const navSelectedPadding = 13.0;

  // Wallet cards

  /// A wallet card in the Wallets stack.
  static const walletCard = 187.0;

  /// How much of each card hides under the next one in the stack.
  static const walletCardTuck = walletCard * (1 - 124 / 170);

  /// Room the name leaves for the card's ⋮ button.
  static const walletCardMenuRoom = 36.0;

  /// The shade along a card's top edge, where the card above overlaps it.
  static const walletCardTopShade = 28.0;

  /// The tab at the bottom of a card that has another card below it.
  static const walletCardSeam = Size(36, 5);

  /// The card shown beside a wallet's name on its screen.
  static const walletThumbnail = Size(52, 40);

  /// How far the wallet card behind peeks above the balance pouch, and how
  /// much more of it is tucked under the pouch.
  static const balancePeek = 44.0;
  static const balancePeekTuck = 24.0;

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

  /// Narrower than the wallet card above it.
  static const receiptWidth = 300.0;

  /// The torn edge at the receipt's bottom.
  static const receiptTear = 16.0;

  /// The barcode's height and the gap between its bars.
  static const barcodeHeight = 32.0;
  static const barcodeBarGap = 2.0;

  /// The dotted leader between a receipt line's label and its value.
  static const receiptLeader = 1.5;
  static const receiptLeaderGap = 6.0;

  /// The receipt's own tighter, printed-paper rhythm, tuned to look like a
  /// till slip rather than the page scale: its margins (more at the bottom
  /// when it only holds a message), and the gaps between printed lines,
  /// above the total's rule, and above the barcode.
  static const receiptPadding = EdgeInsets.fromLTRB(22, 20, 22, 18);
  static const receiptMessagePadding = EdgeInsets.fromLTRB(22, 20, 22, 24);
  static const receiptLineGap = 9.0;
  static const receiptTotalGap = 18.0;
  static const receiptBarcodeGap = 20.0;

  // Buttons

  /// A low-emphasis text button, shorter than a full-size one.
  static const compactButton = 32.0;
}
