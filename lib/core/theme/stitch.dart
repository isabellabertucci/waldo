/// One dash pattern of the stitch: a dash, then a gap.
typedef StitchPattern = ({double dash, double gap});

/// Waldo's dashed stitch, the leather wallet motif: one thread width and a
/// few dash patterns, finer on small shapes and coarser on large ones.
class Stitch {
  Stitch._();

  /// The thread, in every stitch.
  static const width = 1.5;

  /// Inside a pill (buttons, the navbar's selected tab), close to its edge.
  static const StitchPattern fine = (dash: 3, gap: 2.5);
  static const pillInset = 5.0;

  /// Borders and badge rings.
  static const StitchPattern regular = (dash: 4, gap: 3);

  /// The receipt's printed rules.
  static const StitchPattern receipt = (dash: 5, gap: 4);

  /// The balance pouch, the largest shape, further in from its edge.
  static const StitchPattern coarse = (dash: 6, gap: 5);
  static const pouchInset = 7.0;
}
