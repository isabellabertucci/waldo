import 'package:flutter/material.dart';

/// How things move. Durations are Material 3's own steps ([Durations]),
/// named here for what they animate, so a new animation picks one of these
/// rather than a number of its own.
class Motion {
  Motion._();

  /// A segment or toggle filling in (150ms).
  static const toggle = Durations.short3;

  /// A round action button shrinking under the finger, and back.
  static const press = Durations.short4;
  static const pressScale = 0.95;

  /// A segmented control's content sliding to the picked view, and how far
  /// (a share of its width) it slides.
  static const segmentSwap = Duration(milliseconds: 320);
  static const segmentSwapCurve = Curves.easeOutCubic;

  /// A row scrolling to a picked item (300ms).
  static const scroll = Durations.medium2;
  static const scrollCurve = Curves.easeOut;

  /// Something arriving on screen, like the undo bar (350ms): fast at first,
  /// then settling.
  static const enter = Durations.medium3;
  static const enterCurve = Cubic(0.2, 0.8, 0.2, 1);

  /// How far below its place an arriving bar starts.
  static const enterRise = 18.0;

  /// Something moving from A to B while staying on screen: slow at both ends.
  static const emphasizedCurve = Curves.easeInOutCubic;

  /// A selected pill stretching to its new item like a drop of ink (450ms):
  /// the front edge gets there in the first [pillStretchLead] of the time,
  /// then the back edge catches up.
  static const pillStretch = Durations.long1;
  static const pillStretchLead = 0.45;

  /// The line reshaping into the other series, colour and all (600ms).
  static const chartMorph = Durations.long4;

  /// The month's total fading in over the line's end point (250ms).
  static const chartLabel = Durations.medium1;
  static const chartLabelRise = 4.0;

  /// A sheet sliding away (200ms, Flutter's own), which a card made in it
  /// waits out before it lands.
  static const sheetExit = Durations.short4;

  /// A gentle two-tap nudge hinting that a row scrolls; long, so it reads
  /// as a hint rather than a reaction.
  static const hint = Duration(milliseconds: 1400);
  static const hintOut = Curves.easeOut;
  static const hintBack = Curves.easeIn;
}

/// The phone's "Reduce motion" (iOS) or "Remove animations" (Android).
extension MotionContext on BuildContext {
  /// True when the phone asks for no movement: every animation jumps to
  /// its end.
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);

  /// [duration], or zero when the phone asks for reduced motion.
  Duration motion(Duration duration) => reduceMotion ? Duration.zero : duration;
}
