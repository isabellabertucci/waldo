/// Deliberately sparse: either small (chips), the signature button radius,
/// a large radius for cards/dialogs, or a full pill. The source design
/// system uses 40px for its "large" tier, but that's tuned for full-bleed
/// hero banners; on our much smaller mobile cards it reads as a full
/// stadium shape, so this is scaled down to stay clearly "large" without
/// looking like a pill.
class Rounded {
  Rounded._();

  static const double sm = 12;
  static const double md = 20;
  static const double lg = 28;
  static const double pill = 9999;
}
