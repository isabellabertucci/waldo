/// Corner radii (DESIGN.md "Radii"): `radius-sm` (straps, chips), `md`
/// (cards in a sheet), `lg` (wallets, dialogs), `sheet`, pill.
class Rounded {
  Rounded._();

  static const double sm = 14;
  static const double md = 22;
  static const double lg = 24;

  /// The top corners of the white sheet.
  static const double sheet = 32;
  static const double pill = 9999;
}
