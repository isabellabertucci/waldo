import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';

/// The app's one card: `surface`, flat. Every list of rows sits in one: a
/// single row is a pill, like the app's buttons and fields; several share a
/// card's large corners (a tall pill would round into a stadium).
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.pill = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Fully rounded ends: for a card holding one row.
  final bool pill;

  @override
  Widget build(BuildContext context) {
    // A Material, so the rows' ripples paint on the card, clipped to it.
    return Material(
      color: context.appColors.surface,
      borderRadius: BorderRadius.circular(pill ? Rounded.pill : Rounded.lg),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}
