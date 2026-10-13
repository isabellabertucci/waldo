import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/elevation.dart';
import 'package:waldo/core/theme/rounded.dart';

/// A `surface` card with a large radius and a soft shadow, for grouped content.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Rounded.lg),
        boxShadow: Elevation.low,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Rounded.lg),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
