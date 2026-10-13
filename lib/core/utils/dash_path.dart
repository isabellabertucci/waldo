import 'dart:ui';

/// [source] cut into dashes of [dashLength] with [gapLength] between them,
/// ready to stroke - the stitch every dashed border in the app draws.
Path dashPath(
  Path source, {
  required double dashLength,
  required double gapLength,
}) {
  final dashed = Path();
  for (final metric in source.computeMetrics()) {
    var distance = 0.0;
    while (distance < metric.length) {
      final end = (distance + dashLength).clamp(0.0, metric.length);
      dashed.addPath(metric.extractPath(distance, end), Offset.zero);
      distance = end + gapLength;
    }
  }
  return dashed;
}
