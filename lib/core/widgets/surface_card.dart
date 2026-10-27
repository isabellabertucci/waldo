import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/elevation.dart';
import 'package:waldo/core/theme/rounded.dart';

/// The "surface + large radius + soft shadow" card treatment used for
/// grouped content (transaction lists, summary cards) - previously
/// hand-rolled independently wherever it appeared. `Common.getCardTheme`
/// covers the flat, shadowless `Card` case; this is for the subset of
/// cards that need to visibly lift off the page (see DESIGN.md's
/// Elevation & Depth: Low).
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
