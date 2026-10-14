import 'package:flutter/material.dart';
import 'package:waldo/core/theme/rounded.dart';

/// A subtle diagonal lift from [base] to a slightly lighter tone, so the
/// pouch's solid fill reads as gently 3D instead of perfectly flat - never
/// a loud color wash, just enough to suggest light falling across it.
LinearGradient pouchGradient(Color base) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    // one-off: white light falling across the leather, which is the same
    // color in both themes on purpose, so the highlight is fixed too.
    colors: [Color.lerp(base, Colors.white, 0.1)!, base],
  );
}

/// The "pouch" shape: a rounded rect whose top edge has raised shoulders
/// and a shallow dip in the middle, where a card would emerge. Corner
/// positions are expressed as fractions between the two rounded corners so
/// the curve scales with the shape's actual width. This is Waldo's
/// signature wallet silhouette, reused anywhere the app needs to evoke "a
/// wallet" - the balance card, the first-run hero illustration, etc.
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

/// Fills as a [pouchPath] and stitches a dashed line just inside its own
/// edge - the pouch is the real content container, so the stitch traces the
/// shape the user actually sees, not a hidden layer behind it. Defaults
/// match the dashboard's balance card; pass smaller values for a scaled-down
/// illustration (e.g. the first-run hero).
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
