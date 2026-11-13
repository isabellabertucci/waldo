import 'package:flutter/material.dart';
import 'package:waldo/core/utils/utils.dart';

/// A balance behind the eye toggle: the amount, or dots while hidden.
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

  /// The side the amount sits on in its line.
  final AlignmentDirectional alignment;

  /// [amount] in styled parts (the hero's muted cents), shown instead of it.
  final InlineSpan? richAmount;

  @override
  Widget build(BuildContext context) {
    // Only one is in the tree, so a screen reader never reads a hidden
    // balance.
    return Align(
      alignment: alignment,
      widthFactor: 1,
      heightFactor: 1,
      child: hidden || richAmount == null
          ? Text(hidden ? hiddenAmount : amount, style: style)
          : Text.rich(richAmount!, style: style, semanticsLabel: amount),
    );
  }
}
