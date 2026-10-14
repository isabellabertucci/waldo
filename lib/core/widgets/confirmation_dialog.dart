import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/l10n/app_localizations.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmLabel,
    this.isDestructive = true,
    this.icon = AppIcons.delete,
  });

  final String title;
  final String content;
  final String confirmLabel;
  final bool isDestructive;
  final IconData icon;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    bool isDestructive = true,
    IconData icon = AppIcons.delete,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final accent = isDestructive ? colors.error : colors.primary;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rounded.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DashedCircleBadge(icon: icon, color: accent),
            const SizedBox(height: Spacing.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.headlineSmBold.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              content,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: colors.surfaceContainer,
                      foregroundColor: colors.onSurface,
                      padding: const EdgeInsets.symmetric(
                        vertical: Spacing.component,
                      ),
                      textStyle: context.bodyMdBold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Rounded.pill),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: accent,
                      // `onPrimary` is the ink/cream pair that flips with
                      // brightness - it contrasts correctly against both
                      // `primary` and `error`, so no destructive-specific
                      // override is needed.
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        vertical: Spacing.component,
                      ),
                      textStyle: context.bodyMdBold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Rounded.pill),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A dashed ring around a tinted circle - the same "physical token"
/// treatment used for category badges elsewhere, reused here so a
/// destructive confirmation reads as part of the same visual language
/// instead of a generic system dialog.
class _DashedCircleBadge extends StatelessWidget {
  const _DashedCircleBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: CustomPaint(
        painter: _DashedCirclePainter(color: color),
        child: Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: IconSize.xl, color: color),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});

  final Color color;

  static const _dashLength = 4.0;
  static const _gapLength = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + _dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      color != oldDelegate.color;
}
