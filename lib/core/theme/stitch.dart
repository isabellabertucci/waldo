/// One dash pattern of the stitch: a dash, then a gap.
typedef StitchPattern = ({double dash, double gap});

/// Waldo's dashed stitch, the leather wallet motif: one thread width and a
/// few dash patterns, finer on small shapes and coarser on large ones.
class Stitch {
  Stitch._();

  /// The thread, in every stitch.
  static const width = 1.5;

  /// Borders and badge rings.
  static const StitchPattern regular = (dash: 4, gap: 3);

  /// A leather wallet's stitch, this far in from its edge.
  static const walletInset = 9.0;
}
