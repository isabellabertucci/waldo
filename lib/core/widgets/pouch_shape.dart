import 'package:flutter/material.dart';
import 'package:waldo/core/theme/rounded.dart';

/// A subtle diagonal lightening, so the pouch fill looks slightly 3D.
LinearGradient pouchGradient(Color base) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    // one-off: white light falling across the leather, which is the same
    // color in both themes on purpose, so the highlight is fixed too.
    colors: [Color.lerp(base, Colors.white, 0.1)!, base],
  );
}

/// The wallet "pouch": a rounded rect whose top edge dips in the middle.
/// Positions are fractions of the width, so it scales.
Path pouchPath(
  Rect rect, {
  required double cornerRadius,
  required double dipDepth,
}) {
  final left = rect.left;
  final top = rect.top;
  final right = rect.right;
  final bottom = rect.bottom;

  final cornerInsetL = left + cornerRadius;
  final cornerInsetR = right - cornerRadius;
  final span = cornerInsetR - cornerInsetL;
  double fx(double t) => cornerInsetL + span * t;

  return Path()
    ..moveTo(cornerInsetL, top)
    ..quadraticBezierTo(fx(0.248), top, fx(0.404), top + dipDepth * 0.64)
    ..quadraticBezierTo(
      fx(0.5),
      top + dipDepth,
      fx(0.596),
      top + dipDepth * 0.64,
    )
    ..quadraticBezierTo(fx(0.752), top, cornerInsetR, top)
    ..quadraticBezierTo(right, top, right, top + cornerRadius)
    ..lineTo(right, bottom - cornerRadius)
    ..quadraticBezierTo(right, bottom, right - cornerRadius, bottom)
    ..lineTo(left + cornerRadius, bottom)
    ..quadraticBezierTo(left, bottom, left, bottom - cornerRadius)
    ..lineTo(left, top + cornerRadius)
    ..quadraticBezierTo(left, top, cornerInsetL, top)
    ..close();
}

/// Fills a [pouchPath] and stitches a dashed line just inside its edge.
class PouchBorder extends ShapeBorder {
  const PouchBorder({
    required this.stitchColor,
    this.cornerRadius = Rounded.lg,
    this.dipDepth = 22.0,
    this.inset = 7.0,
    this.strokeWidth = 1.5,
    this.dashLength = 6.0,
    this.gapLength = 5.0,
  });

  final Color stitchColor;
  final double cornerRadius;
  final double dipDepth;
  final double inset;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      pouchPath(rect, cornerRadius: cornerRadius, dipDepth: dipDepth);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      pouchPath(rect, cornerRadius: cornerRadius, dipDepth: dipDepth);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final stitchRect = rect.deflate(inset);
    final path = pouchPath(
      stitchRect,
      cornerRadius: (cornerRadius - inset).clamp(0, cornerRadius),
      dipDepth: dipDepth,
    );
    final paint = Paint()
      ..color = stitchColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapLength;
      }
    }
  }

  @override
  ShapeBorder scale(double t) => this;
}
