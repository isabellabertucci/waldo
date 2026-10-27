import 'package:flutter/material.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/stitch.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/utils/dash_path.dart';

/// A dashed ring around a tinted circle holding an icon: the confirm
/// dialog's badge and the transaction view's category badge.
class DashedCircleBadge extends StatelessWidget {
  const DashedCircleBadge({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // The ring sits a component gap outside the disc.
      width: BadgeSize.xl + Spacing.component,
      height: BadgeSize.xl + Spacing.component,
      child: CustomPaint(
        painter: _DashedCirclePainter(color: color),
        child: Center(
          child: Container(
            width: BadgeSize.xl,
            height: BadgeSize.xl,
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

  @override
  void paint(Canvas canvas, Size size) {
    // Inset by half the thread, so the whole ring sits inside the badge, as
    // DashedBorder's does.
    final path = Path()
      ..addOval((Offset.zero & size).deflate(Stitch.width / 2));
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = Stitch.width;

    canvas.drawPath(dashPath(path, Stitch.regular), paint);
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      color != oldDelegate.color;
}
