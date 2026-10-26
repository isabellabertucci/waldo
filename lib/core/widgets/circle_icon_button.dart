import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/elevation.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/min_tap_target.dart';

/// A `surface` disc with a soft shadow, for secondary header actions.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.flat = false,
    this.tint,
  }) : assert(tint == null || flat, 'Only a flat disc takes a tint');

  final VoidCallback onPressed;
  final Widget child;

  /// What the button does, for screen readers and long-press - required in
  /// practice whenever [child] is only an icon.
  final String? tooltip;

  /// Tinted and without a shadow, for a control inside a sheet.
  final bool flat;

  /// A flat disc's fill in place of `surfaceContainer`, e.g. a faint orange
  /// behind a delete.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final button = Material(
      color: flat ? (tint ?? colors.surfaceContainer) : colors.surface,
      shape: const CircleBorder(),
      elevation: flat ? 0 : 1,
      shadowColor: Elevation.highShadowColor,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.component),
          child: child,
        ),
      ),
    );

    final tooltip = this.tooltip;
    // Outside the tooltip, as Flutter's IconButton does, so the name, the
    // button role and the tap end up in one node for screen readers; its own
    // node, as Flutter's buttons are, so text beside it never joins its name.
    return Semantics(
      container: true,
      button: true,
      child: MinTapTarget(
        onTap: onPressed,
        child: tooltip == null
            ? button
            : Tooltip(message: tooltip, child: button),
      ),
    );
  }
}
