import 'package:flutter/material.dart';

/// How things move. Durations are Material 3's own steps ([Durations]),
/// named here for what they animate, so a new animation picks one of these
/// rather than a number of its own.
class Motion {
  Motion._();

  /// A segment or toggle filling in (150ms).
  static const toggle = Durations.short3;

  /// The navbar's selected pill sliding to a tab (200ms).
  static const navigation = Durations.short4;

  /// A row scrolling to a picked item (300ms).
  static const scroll = Durations.medium2;
  static const scrollCurve = Curves.easeOut;

  /// Something arriving on screen, like the undo bar (350ms): fast at first,
  /// then settling.
  static const enter = Durations.medium3;
  static const enterCurve = Cubic(0.2, 0.8, 0.2, 1);

  /// A gentle two-tap nudge hinting that a row scrolls; long, so it reads
  /// as a hint rather than a reaction.
  static const hint = Duration(milliseconds: 1400);
  static const hintOut = Curves.easeOut;
  static const hintBack = Curves.easeIn;
}
