import 'package:flutter/material.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/utils/utils.dart';

/// A balance behind the eye toggle (the dashboard pouch, the wallets total and
/// cards). Hiding it tucks the amount down out of its line while the dots drop
/// in from above; showing it plays that backwards.
class BalanceAmount extends StatelessWidget {
  const BalanceAmount({
    super.key,
    required this.amount,
    required this.hidden,
    required this.style,
    this.alignment = AlignmentDirectional.centerStart,
    this.richAmount,
  });

  /// The formatted balance, shown when not [hidden].
  final String amount;
  final bool hidden;
  final TextStyle style;

  /// The side the amount sits on in its line, so the amount and the dots
  /// animate there instead of jumping over when they settle.
  final AlignmentDirectional alignment;

  /// [amount] in styled parts (the hero's muted cents), shown instead of it.
  final InlineSpan? richAmount;

  @override
  Widget build(BuildContext context) {
    // Clipped, so what slides out of the line disappears instead of overlapping.
    return ClipRect(
      child: AnimatedSwitcher(
        duration: context.motion(Motion.balanceTuck),
        layoutBuilder: (current, previous) =>
            Stack(alignment: alignment, children: [...previous, ?current]),
        transitionBuilder: (child, animation) {
          // The amount lives below the line, the dots above it: each leaves
          // and comes back the way it went.
          final isDots = child.key == const ValueKey(true);
          final curved = CurvedAnimation(
            parent: animation,
            curve: isDots ? Motion.settleCurve : Motion.balanceTuckCurve,
            // Leaving, it goes at once, so the two never sit on each other.
            reverseCurve: Motion.balanceTuckCurve.flipped,
          );
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: Offset(0, isDots ? -1 : 1),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        // Only one is in the tree once it settles, so a screen reader never
        // reads a hidden balance.
        child: hidden || richAmount == null
            ? Text(
                hidden ? hiddenAmount : amount,
                key: ValueKey(hidden),
                style: style,
              )
            : Text.rich(
                richAmount!,
                key: ValueKey(hidden),
                style: style,
                semanticsLabel: amount,
              ),
      ),
    );
  }
}
