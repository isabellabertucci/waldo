import 'package:flutter/material.dart';
import 'package:waldo/core/theme/finish_colors.dart';
import 'package:waldo/core/theme/stitch.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/utils/dash_path.dart';

/// A subtle diagonal lightening, so the pouch fill looks slightly 3D.
LinearGradient pouchGradient(Color base) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.lerp(
        base,
        FinishColors.leatherSheen,
        FinishColors.leatherSheenAmount,
      )!,
      base,
    ],
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
  });

  final Color stitchColor;
  final double cornerRadius;
  final double dipDepth;

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
    const inset = Stitch.pouchInset;
    final stitchRect = rect.deflate(inset);
    final path = pouchPath(
      stitchRect,
      cornerRadius: (cornerRadius - inset).clamp(0, cornerRadius),
      dipDepth: dipDepth,
    );
    final paint = Paint()
      ..color = stitchColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = Stitch.width;

    canvas.drawPath(dashPath(path, Stitch.coarse), paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
