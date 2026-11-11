import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/stitch.dart';
import 'package:waldo/core/utils/dash_path.dart';

/// The fine stitch just inside a pill's rounded edge: the primary button's
/// and the navbar's selected tab.
class PillStitchPainter extends CustomPainter {
  const PillStitchPainter({required this.color, this.radius = Rounded.pill});

  final Color color;

  /// The shape's corner radius; the stitch follows it, [Stitch.pillInset] in.
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    paintPillStitch(canvas, Offset.zero & size, color: color, radius: radius);
  }

  @override
  bool shouldRepaint(covariant PillStitchPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}

/// Paints [PillStitchPainter]'s stitch inside [rect], for painters that draw
/// the pill themselves.
void paintPillStitch(
  Canvas canvas,
  Rect rect, {
  required Color color,
  double radius = Rounded.pill,
}) {
  final inner = rect.deflate(Stitch.pillInset);
  if (inner.shortestSide <= 0) return;
  final path = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        inner,
        Radius.circular(
          math.min(radius - Stitch.pillInset, inner.shortestSide / 2),
        ),
      ),
    );
  final paint = Paint()
    ..color = color.withValues(alpha: Alpha.stitch)
    ..style = PaintingStyle.stroke
    ..strokeWidth = Stitch.width;

  canvas.drawPath(dashPath(path, Stitch.fine), paint);
}
