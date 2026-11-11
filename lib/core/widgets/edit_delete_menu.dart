import 'dart:ui' show SemanticsRole, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/elevation.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/min_tap_target.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// What a row or card's ⋮ menu offers.
enum EditDeleteAction { edit, delete }

/// The ⋮ menu's items: Edit, then Delete in the error orange.
List<PopupMenuEntry<EditDeleteAction>> editDeleteMenuItems(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);
  final colors = context.appColors;

  return [
    PopupMenuItem(
      value: EditDeleteAction.edit,
      child: Row(
        children: [
          const Icon(AppIcons.edit, size: IconSize.lg),
          const SizedBox(width: Spacing.xs),
          Text(l10n.edit),
        ],
      ),
    ),
    PopupMenuItem(
      value: EditDeleteAction.delete,
      child: Row(
        children: [
          Icon(AppIcons.delete, size: IconSize.lg, color: colors.error),
          const SizedBox(width: Spacing.xs),
          Text(l10n.delete, style: TextStyle(color: colors.error)),
        ],
      ),
    ),
  ];
}

/// A ⋮ button whose Edit/Delete menu grows out of the dots with a small
/// bounce, and closes with a quick fade. [child] is the dots; the touch area
/// around them is 48px.
class EditDeleteMenuButton extends StatefulWidget {
  const EditDeleteMenuButton({
    super.key,
    required this.tooltip,
    required this.onSelected,
    required this.child,
  });

  final String tooltip;
  final ValueChanged<EditDeleteAction> onSelected;
  final Widget child;

  @override
  State<EditDeleteMenuButton> createState() => _EditDeleteMenuButtonState();
}

class _EditDeleteMenuButtonState extends State<EditDeleteMenuButton>
    with SingleTickerProviderStateMixin {
  final _dotsKey = GlobalKey();

  /// The dots dip a little as they're tapped.
  late final _dip = AnimationController(vsync: this, duration: Motion.menuDip);
  late final _scale = TweenSequence([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: Motion.menuDipScale),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(begin: Motion.menuDipScale, end: 1.0),
      weight: 1,
    ),
  ]).chain(CurveTween(curve: Motion.emphasizedCurve)).animate(_dip);

  @override
  void dispose() {
    _dip.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final navigator = Navigator.of(context);
    final dots = _dotsKey.currentContext!.findRenderObject()! as RenderBox;
    final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
    final anchor =
        dots.localToGlobal(Offset.zero, ancestor: overlay) & dots.size;
    final reduceMotion = context.reduceMotion;

    if (!reduceMotion) _dip.forward(from: 0);
    HapticFeedback.lightImpact();
    final action = await navigator.push(
      _MenuRoute(
        anchor: anchor,
        reduceMotion: reduceMotion,
        barrierLabel: MaterialLocalizations.of(
          context,
        ).modalBarrierDismissLabel,
      ),
    );
    if (action != null && mounted) widget.onSelected(action);
  }

  @override
  Widget build(BuildContext context) {
    // A named button to screen readers, the size of its touch area.
    return Semantics(
      button: true,
      child: Tooltip(
        message: widget.tooltip,
        child: MinTapTarget(
          onTap: _open,
          child: ScaleTransition(
            scale: _scale,
            child: KeyedSubtree(key: _dotsKey, child: widget.child),
          ),
        ),
      ),
    );
  }
}

class _MenuRoute extends PopupRoute<EditDeleteAction> {
  _MenuRoute({
    required this.anchor,
    required this.reduceMotion,
    required this.barrierLabel,
  });

  /// The dots the menu grows from, in the navigator's coordinates.
  final Rect anchor;
  final bool reduceMotion;

  @override
  final String barrierLabel;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  Duration get transitionDuration =>
      reduceMotion ? Duration.zero : Motion.bouncyCurve.duration;

  @override
  Duration get reverseTransitionDuration =>
      reduceMotion ? Duration.zero : Motion.menuClose;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final fadeIn = Interval(
      0,
      Motion.menuFadeIn.inMicroseconds /
          Motion.bouncyCurve.duration.inMicroseconds,
    );

    // Below the dots, unless its two rows wouldn't fit there; it grows from
    // the corner by the dots either way.
    final padding = MediaQuery.paddingOf(context);
    final menuHeight =
        MediaQuery.textScalerOf(context).scale(kMinInteractiveDimension) * 2 +
        Spacing.xs * 2;
    final above =
        anchor.bottom + menuHeight >
        MediaQuery.sizeOf(context).height - padding.bottom - Spacing.xs;

    return CustomSingleChildLayout(
      delegate: _MenuLayout(anchor, padding, above: above),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          // Closing is a plain fade, no bounce.
          final closing = animation.status == AnimationStatus.reverse;
          return Opacity(
            opacity: closing
                ? animation.value
                : fadeIn.transform(animation.value),
            child: Transform.scale(
              scale: closing
                  ? 1
                  : lerpDouble(
                      Motion.menuScaleFrom,
                      1,
                      Motion.bouncyCurve.transform(animation.value),
                    ),
              alignment: above ? Alignment.bottomRight : Alignment.topRight,
              child: child,
            ),
          );
        },
        child: const _Menu(),
      ),
    );
  }
}

/// Puts the menu just below the dots (or [above] them), its right edge on
/// theirs, kept on screen.
class _MenuLayout extends SingleChildLayoutDelegate {
  _MenuLayout(this.anchor, this.padding, {required this.above});

  final Rect anchor;
  final EdgeInsets padding;
  final bool above;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.loose(
        constraints.biggest,
      ).deflate(padding + const EdgeInsets.all(Spacing.xs));

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final left = (anchor.right - childSize.width).clamp(
      padding.left + Spacing.xs,
      size.width - padding.right - Spacing.xs - childSize.width,
    );
    final top = above ? anchor.top - childSize.height : anchor.bottom;
    return Offset(
      left,
      top.clamp(
        padding.top + Spacing.xs,
        size.height - padding.bottom - Spacing.xs - childSize.height,
      ),
    );
  }

  @override
  bool shouldRelayout(_MenuLayout oldDelegate) =>
      anchor != oldDelegate.anchor ||
      padding != oldDelegate.padding ||
      above != oldDelegate.above;
}

class _Menu extends StatelessWidget {
  const _Menu();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final shape = BorderRadius.circular(Rounded.md);

    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: shape, boxShadow: Elevation.high),
      child: Material(
        color: colors.surfaceContainer,
        borderRadius: shape,
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: ComponentSize.menuMinWidth,
            maxWidth: ComponentSize.menuMaxWidth,
          ),
          child: IntrinsicWidth(
            stepWidth: ComponentSize.menuWidthStep,
            // A menu to screen readers, as Material's own popup menu is.
            child: Semantics(
              role: SemanticsRole.menu,
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: MaterialLocalizations.of(context).popupMenuLabel,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
                child: ListBody(children: editDeleteMenuItems(context)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
