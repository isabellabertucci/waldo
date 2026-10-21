import 'package:waldo/core/utils/dash_path.dart';
import 'package:flutter/material.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

/// A `primary` pill with a dashed stitch just inside its edge - the app's
/// primary-action button.
class DashedStitchButton extends StatelessWidget {
  const DashedStitchButton({
    super.key,
    this.label,
    this.icon,
    this.onPressed,
    this.compact = false,
    this.padding,
    this.labelStyle,
    this.tooltip,
  }) : assert(
         label != null || icon != null,
         'DashedStitchButton needs a label or an icon',
       );

  final String? label;
  final Widget? icon;
  final VoidCallback? onPressed;

  /// Tighter padding for small contexts (e.g. a month grid cell).
  final bool compact;

  /// Overrides the compact/non-compact padding for a one-off size (e.g. a
  /// primary CTA that needs to stand out more than either preset allows).
  final EdgeInsetsGeometry? padding;

  /// Overrides the compact/non-compact label text style.
  final TextStyle? labelStyle;

  /// What the button does, for screen readers and long-press - required in
  /// practice when the button has an [icon] but no [label].
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isIconOnly = label == null;

    // A button to screen readers, like Flutter's own buttons: a bare InkWell
    // is only read as its label.
    final button = Semantics(
      container: true,
      button: true,
      enabled: onPressed != null,
      child: Material(
        color: colors.primary,
        borderRadius: BorderRadius.circular(Rounded.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(Rounded.pill),
          onTap: onPressed,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _DashedPillPainter(color: colors.onPrimary),
                ),
              ),
              Padding(
                padding:
                    padding ??
                    (isIconOnly
                        ? const EdgeInsets.all(Spacing.component)
                        : EdgeInsets.symmetric(
                            horizontal: compact ? Spacing.sm : Spacing.md,
                            vertical: compact ? Spacing.xs : Spacing.sm,
                          )),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null)
                      IconTheme(
                        data: IconThemeData(
                          color: colors.onPrimary,
                          size: IconSize.md,
                        ),
                        child: icon!,
                      ),
                    if (icon != null && label != null)
                      const SizedBox(width: Spacing.xs),
                    // Flexible so a narrow button (or large text) ellipsizes instead of overflowing.
                    if (label != null)
                      Flexible(
                        child: Text(
                          label!,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              (labelStyle ??
                                      (compact
                                          ? context.bodySmBold
                                          : context.labelLgStrong))
                                  .copyWith(color: colors.onPrimary),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final tooltip = this.tooltip;
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}

class _DashedPillPainter extends CustomPainter {
  const _DashedPillPainter({required this.color});

  final Color color;

  static const _inset = 5.0;
  static const _dashLength = 3.0;
  static const _gapLength = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final deflated = rect.deflate(_inset);
    if (deflated.shortestSide <= 0) return;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          deflated,
          Radius.circular(deflated.shortestSide / 2),
        ),
      );
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(
      dashPath(path, dashLength: _dashLength, gapLength: _gapLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedPillPainter oldDelegate) =>
      color != oldDelegate.color;
}
