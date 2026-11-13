import 'package:flutter/material.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/spacing.dart';

/// A badge beside its text, as list rows have. At accessibility sizes the
/// badge moves above the text, so the text keeps the row's whole width.
class BadgeRow extends StatelessWidget {
  const BadgeRow({
    super.key,
    required this.badge,
    required this.child,
    this.trailing,
    this.gap = Spacing.sm,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final Widget badge;
  final Widget child;
  final Widget? trailing;

  /// The space between the badge and the text when side by side.
  final double gap;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final stacked = DynamicTypeScaler.isAccessibilitySize(context);
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (!stacked) ...[badge, SizedBox(width: gap)],
        Expanded(
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    badge,
                    const SizedBox(height: Spacing.xs),
                    child,
                  ],
                )
              : child,
        ),
        ?trailing,
      ],
    );
  }
}
