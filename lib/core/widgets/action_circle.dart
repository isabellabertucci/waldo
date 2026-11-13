import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/theme/spacing.dart';

/// A round action over the page's beige top, labelled underneath
/// (DESIGN.md "Action circles"). Screens show three, the main one last and
/// [isMain]: the only one in the yellow `action` colour. A toggle is green
/// while [selected], and a yellow dot [marked] says it's changing something
/// (a filter that's on).
class ActionCircle extends StatefulWidget {
  const ActionCircle({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isMain = false,
    this.selected,
    this.marked = false,
    this.value,
  }) : assert(!isMain || selected == null, 'The main action is no toggle');

  final Widget icon;
  final String label;

  /// Null greys it out: there's nothing to do yet (no wallet to log into).
  final VoidCallback? onPressed;
  final bool isMain;

  /// Whether this toggle is on; null for a plain action.
  final bool? selected;
  final bool marked;

  /// What it's set to, for screen readers (the filter's choice).
  final String? value;

  @override
  State<ActionCircle> createState() => _ActionCircleState();
}

class _ActionCircleState extends State<ActionCircle> {
  bool _pressed = false;

  void _setPressed(bool value) => setState(() => _pressed = value);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final selected = widget.selected ?? false;
    final enabled = widget.onPressed != null;
    final foreground = !enabled
        ? colors.inkMuted
        : widget.isMain
        ? colors.onPrimary
        : selected
        ? colors.onAccent
        : colors.ink;
    final outlined = !widget.isMain && !selected;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: widget.label,
      toggled: widget.selected,
      enabled: enabled,
      value: widget.value,
      // On the node itself: excludeSemantics drops the detector's own.
      onTap: widget.onPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: _pressed ? Motion.pressScale : 1,
              duration: context.motion(Motion.press),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: ComponentSize.actionCircle,
                    height: ComponentSize.actionCircle,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: !enabled
                          ? colors.card
                          : widget.isMain
                          ? colors.primary
                          : selected
                          ? colors.accent
                          : colors.chip,
                      // The plain ones are outlined, as nothing has a shadow.
                      shape: CircleBorder(
                        side: outlined
                            ? BorderSide(color: colors.line)
                            : BorderSide.none,
                      ),
                    ),
                    child: IconTheme.merge(
                      data: IconThemeData(color: foreground),
                      child: widget.icon,
                    ),
                  ),
                  if (widget.marked)
                    PositionedDirectional(
                      top: 0,
                      end: 0,
                      child: Container(
                        width: ComponentSize.actionMark,
                        height: ComponentSize.actionMark,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                          // Ringed, so it reads off the circle under it.
                          border: Border.all(
                            color: colors.sheet,
                            width: ComponentSize.actionMarkRing,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              widget.label,
              style: context.label.copyWith(
                color: enabled ? colors.ink : colors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
