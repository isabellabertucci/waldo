import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';

/// Text that never breaks a word in two: when its longest word is wider than
/// the line, the text shrinks just enough for that word to fit, as UIKit's
/// `adjustsFontSizeToFitWidth` does. Only very large text ever shrinks; a
/// single-line text keeps its [overflow] instead.
class WholeWordsText extends StatelessWidget {
  const WholeWordsText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : singleLine = false;

  /// One line cut with "…", except at accessibility sizes, where it wraps
  /// so the whole text shows.
  const WholeWordsText.singleLine(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
  }) : singleLine = true,
       maxLines = 1,
       overflow = TextOverflow.ellipsis;

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    final wraps = singleLine
        ? DynamicTypeScaler.isAccessibilitySize(context)
        : maxLines != 1;
    if (!wraps) {
      return Text(
        data,
        style: style,
        maxLines: 1,
        overflow: overflow,
        textAlign: textAlign,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaler = MediaQuery.textScalerOf(context);
        final fit = _fitFor(context, scaler, constraints.maxWidth);
        return Text(
          data,
          style: style,
          maxLines: singleLine ? null : maxLines,
          overflow: singleLine ? null : overflow,
          textAlign: textAlign,
          textScaler: fit < 1 ? _ShrunkTextScaler(scaler, fit) : null,
        );
      },
    );
  }

  /// How much to shrink so the widest word fits [maxWidth]; 1 if it fits.
  double _fitFor(BuildContext context, TextScaler scaler, double maxWidth) {
    if (!maxWidth.isFinite) return 1;
    final resolved = context.effectiveTextStyle(style);
    var widest = 0.0;
    for (final word in data.split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;
      final painter = TextPainter(
        text: TextSpan(text: word, style: resolved),
        textScaler: scaler,
        textDirection: Directionality.of(context),
        maxLines: 1,
      )..layout();
      if (painter.width > widest) widest = painter.width;
      painter.dispose();
    }
    // Rounded down, so rounding never leaves the word a hair too wide.
    return widest <= maxWidth ? 1 : (maxWidth / widest * 1000).floor() / 1000;
  }
}

/// [base] scaled down by [fit].
class _ShrunkTextScaler extends TextScaler {
  const _ShrunkTextScaler(this.base, this.fit);

  final TextScaler base;
  final double fit;

  @override
  double scale(double fontSize) => base.scale(fontSize) * fit;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => base.textScaleFactor * fit;

  @override
  bool operator ==(Object other) =>
      other is _ShrunkTextScaler && other.base == base && other.fit == fit;

  @override
  int get hashCode => Object.hash(base, fit);
}
