import 'package:flutter/material.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/stitch.dart';
import 'package:waldo/core/utils/dash_path.dart';

/// The fine stitch just inside a pill's rounded edge: the primary button's
/// and the navbar's selected tab.
class PillStitchPainter extends CustomPainter {
  const PillStitchPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final inner = (Offset.zero & size).deflate(Stitch.pillInset);
    if (inner.shortestSide <= 0) return;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(inner, Radius.circular(inner.shortestSide / 2)),
      );
    final paint = Paint()
      ..color = color.withValues(alpha: Alpha.stitch)
      ..style = PaintingStyle.stroke
      ..strokeWidth = Stitch.width;

    canvas.drawPath(dashPath(path, Stitch.fine), paint);
  }

  @override
  bool shouldRepaint(covariant PillStitchPainter oldDelegate) =>
      color != oldDelegate.color;
}
