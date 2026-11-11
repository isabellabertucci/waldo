import 'dart:math' as math;

import 'package:corner_radius_plugin/corner_radius_plugin.dart';
import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

/// Opens every bottom sheet in the app: it floats just inside the screen's
/// edges, its corners following the screen's.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  AnimationStyle? sheetAnimationStyle,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    // Grows with its content, then scrolls; never under the status bar.
    isScrollControlled: true,
    useSafeArea: true,
    // The sheet paints its own card; the route's would be edge to edge.
    backgroundColor: context.appColors.transparent,
    elevation: 0,
    sheetAnimationStyle: sheetAnimationStyle,
    builder: (context) => FloatingSheet(child: builder(context)),
  );
}

/// The card a sheet floats in, [Spacing.component] in from the screen's edges (or
/// just above the keyboard), its corners curving with the screen's own.
class FloatingSheet extends StatelessWidget {
  const FloatingSheet({super.key, required this.child});

  final Widget child;

  /// Concentric with the screen's corners: their radius less the gap. A
  /// square screen, or one that doesn't say, gets a card's corners.
  static double radius(double screenRadius) =>
      screenRadius > _gap ? screenRadius - _gap : Rounded.lg;

  static const _gap = Spacing.component;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(_gap, 0, _gap, keyboard + _gap),
      child: Material(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(
          radius(CornerRadiusPlugin.screenRadius.bottomLeft),
        ),
        clipBehavior: Clip.antiAlias,
        // The card clears the keyboard itself; the home indicator it only
        // partly clears, so the sheet keeps the rest of that room.
        child: MediaQuery(
          data: media
              .removeViewInsets(removeBottom: true)
              .copyWith(
                padding: media.padding.copyWith(
                  bottom: keyboard > 0
                      ? 0
                      : math.max(0, media.padding.bottom - _gap),
                ),
              ),
          child: child,
        ),
      ),
    );
  }
}
