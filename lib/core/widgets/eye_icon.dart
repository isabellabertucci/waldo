import 'package:flutter/material.dart';

/// A hand-drawn eye icon (almond outline + pupil, optionally crossed out),
/// matching the reference design rather than Flutter's built-in glyph.
class EyeIcon extends StatelessWidget {
  const EyeIcon({
    super.key,
    required this.color,
    required this.hidden,
    this.size = 22,
  });

  final Color color;
  final bool hidden;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _EyePainter(color: color, hidden: hidden),
    );
  }
}

class _EyePainter extends CustomPainter {
  const _EyePainter({required this.color, required this.hidden});

  final Color color;
  final bool hidden;

  // Coordinates are in a 24x24 box, scaled to the painter's actual size.
  static const _boxSize = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _boxSize, size.height / _boxSize);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final eyePath = Path()
      ..moveTo(1, 12)
      ..quadraticBezierTo(4, 5, 12, 5)
      ..quadraticBezierTo(20, 5, 23, 12)
      ..quadraticBezierTo(20, 19, 12, 19)
      ..quadraticBezierTo(4, 19, 1, 12)
      ..close();
    canvas.drawPath(eyePath, paint);
    canvas.drawCircle(const Offset(12, 12), 3, paint);

    if (hidden) {
      canvas.drawLine(const Offset(3, 4), const Offset(21, 20), paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EyePainter oldDelegate) =>
      color != oldDelegate.color || hidden != oldDelegate.hidden;
}
