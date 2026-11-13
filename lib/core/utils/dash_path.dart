import 'dart:ui';

import 'package:waldo/core/theme/stitch.dart';

/// [source] cut into [pattern]'s dashes and gaps, ready to stroke - the
/// stitch every dashed border in the app draws.
Path dashPath(Path source, StitchPattern pattern) {
  final (:dash, :gap) = pattern;
  final dashed = Path();
  for (final metric in source.computeMetrics()) {
    var distance = 0.0;
    while (distance < metric.length) {
      final end = (distance + dash).clamp(0.0, metric.length);
      dashed.addPath(metric.extractPath(distance, end), Offset.zero);
      distance = end + gap;
    }
  }
  return dashed;
}
