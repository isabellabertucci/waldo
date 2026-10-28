import 'package:flutter/widgets.dart';

/// Scales text the way iOS Dynamic Type does: body text grows with the
/// user's setting, while titles grow less, so at the largest sizes a title
/// is only a little bigger than the text under it.
///
/// iOS hands Flutter one factor (body size / 17) and Flutter applies it to
/// every size; this applies Apple's own per-style table instead.
class DynamicTypeScaler extends TextScaler {
  const DynamicTypeScaler(this.bodyScale);

  /// Reads the factor out of the system's linear scaler.
  DynamicTypeScaler.from(TextScaler system)
    : bodyScale = system.scale(_appBody) / _appBody;

  /// The system's factor for body text.
  final double bodyScale;

  /// Bars stop growing at the largest size before the accessibility ones
  /// (xxxLarge, body 23), as iOS's own bars do.
  static const barMaxScale = 23 / 17;

  /// Where iOS's accessibility sizes begin (AX1, body 28): from here on,
  /// side-by-side layouts stack so text keeps the full width.
  static const accessibilityScale = 28 / 17;

  /// Whether [context]'s text is at one of the accessibility sizes.
  static bool isAccessibilitySize(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(_appBody) / _appBody >=
      accessibilityScale;

  /// Waldo's body text is 14, Apple's is 17: sizes are compared by role.
  static const _appleBody = 17.0;
  static const _appBody = 14.0;

  /// Apple's Body, Title 3, Title 2, Title 1 and Large Title at each text
  /// size, from the HIG typography tables (xSmall to AX5).
  static const _styles = [17.0, 20.0, 22.0, 28.0, 34.0];
  static const _levels = [
    [14.0, 17.0, 19.0, 25.0, 31.0],
    [15.0, 18.0, 20.0, 26.0, 32.0],
    [16.0, 19.0, 21.0, 27.0, 33.0],
    [17.0, 20.0, 22.0, 28.0, 34.0],
    [19.0, 22.0, 24.0, 30.0, 36.0],
    [21.0, 24.0, 26.0, 32.0, 38.0],
    [23.0, 26.0, 28.0, 34.0, 40.0],
    [28.0, 31.0, 34.0, 38.0, 44.0],
    [33.0, 37.0, 39.0, 43.0, 48.0],
    [40.0, 43.0, 44.0, 48.0, 52.0],
    [47.0, 49.0, 50.0, 53.0, 56.0],
    [53.0, 55.0, 56.0, 58.0, 60.0],
  ];

  @override
  double scale(double fontSize) {
    if (bodyScale == 1) return fontSize;
    final role = fontSize * _appleBody / _appBody;
    // Text at or under body size grows with body text, as it does today.
    if (role <= _appleBody) return fontSize * bodyScale;
    return _appleSize(role) * _appBody / _appleBody;
  }

  /// The size Apple gives a style of [role] points at the current setting,
  /// between the two table rows around this body size.
  double _appleSize(double role) {
    final body = _appleBody * bodyScale;
    final rows = _levels;
    if (body <= rows.first.first) return _sizeIn(rows.first, role);
    if (body >= rows.last.first) {
      return _sizeIn(rows.last, role) * body / rows.last.first;
    }
    for (var i = 1; i < rows.length; i++) {
      final upper = rows[i];
      if (body <= upper.first) {
        final lower = rows[i - 1];
        final t = (body - lower.first) / (upper.first - lower.first);
        final a = _sizeIn(lower, role);
        return a + (_sizeIn(upper, role) - a) * t;
      }
    }
    return role * bodyScale;
  }

  /// [role] read along one table row: between two styles it interpolates;
  /// past Large Title it adds what Large Title gains.
  static double _sizeIn(List<double> row, double role) {
    for (var i = 1; i < _styles.length; i++) {
      if (role <= _styles[i]) {
        final t = (role - _styles[i - 1]) / (_styles[i] - _styles[i - 1]);
        return row[i - 1] + (row[i] - row[i - 1]) * t;
      }
    }
    return role + row.last - _styles.last;
  }

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => bodyScale;

  @override
  TextScaler clamp({
    double minScaleFactor = 0,
    double maxScaleFactor = double.infinity,
  }) {
    final clamped = bodyScale.clamp(minScaleFactor, maxScaleFactor);
    return clamped == bodyScale ? this : DynamicTypeScaler(clamped);
  }

  @override
  bool operator ==(Object other) =>
      other is DynamicTypeScaler && other.bodyScale == bodyScale;

  @override
  int get hashCode => bodyScale.hashCode;

  @override
  String toString() => 'DynamicTypeScaler(${bodyScale}x)';
}
