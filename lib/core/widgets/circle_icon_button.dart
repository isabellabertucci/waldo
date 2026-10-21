import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/elevation.dart';
import 'package:waldo/core/theme/spacing.dart';

/// A `surface` disc with a soft shadow, for secondary header actions.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
  });

  final VoidCallback onPressed;
  final Widget child;

  /// What the button does, for screen readers and long-press - required in
  /// practice whenever [child] is only an icon.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final button = Material(
      color: colors.surface,
      shape: const CircleBorder(),
      elevation: 1,
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
    // button role and the tap end up in one node for screen readers.
    return Semantics(
      button: true,
      child: tooltip == null
          ? button
          : Tooltip(message: tooltip, child: button),
    );
  }
}
