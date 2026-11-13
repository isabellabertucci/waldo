import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

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

  /// The balance tucking into the pocket, or coming back out (300ms).
  static const balanceTuck = Durations.medium2;
  static const balanceTuckCurve = Curves.easeOutCubic;

  /// Lands, overshoots a touch, and settles - the dots dropping into place.
  static const settleCurve = Curves.easeOutBack;

  /// Something moving from A to B while staying on screen: slow at both ends.
  static const emphasizedCurve = Curves.easeInOutCubic;

  /// A selected pill stretching to its new item like a drop of ink (450ms):
  /// the front edge gets there in the first [pillStretchLead] of the time,
  /// then the back edge catches up.
  static const pillStretch = Durations.long1;
  static const pillStretchLead = 0.45;

  /// A label's colour changing as the pill arrives under it or leaves (250ms).
  static const pillLabel = Durations.medium1;

  /// The cash-flow line drawing itself in, left to right (800ms).
  static const chartDraw = Durations.extralong2;

  /// The line reshaping into the other series, colour and all (600ms).
  static const chartMorph = Durations.long4;

  /// The month's total rising in over the line's end point, a beat after the
  /// point pops.
  static const chartLabelDelay = Durations.short2;
  static const chartLabel = Durations.medium1;
  static const chartLabelRise = 4.0;

  /// Springs, named by feel: the design playground's own values.
  /// A clear overshoot, one bounce (settles in about 0.9s).
  static const bouncy = SpringDescription(mass: 1, stiffness: 220, damping: 14);
  static final bouncyCurve = SpringCurve(bouncy);

  /// Playful, two small bounces (settles in about 1.1s).
  static const wobbly = SpringDescription(mass: 1, stiffness: 260, damping: 11);

  /// A ⋮ menu growing out of its dots from [menuScaleFrom] on [bouncyCurve],
  /// fading in over [menuFadeIn]; it closes with a plain [menuClose] fade.
  static const menuFadeIn = Durations.short2;
  static const menuScaleFrom = 0.4;
  static const menuClose = Durations.short4;

  /// The ⋮ button dipping to [menuDipScale] and back as it's tapped.
  static const menuDip = Durations.short4;
  static const menuDipScale = 0.86;

  /// A sheet sliding away (200ms, Flutter's own), which a card made in it
  /// waits out before it lands.
  static const sheetExit = Durations.short4;

  /// A gentle two-tap nudge hinting that a row scrolls; long, so it reads
  /// as a hint rather than a reaction.
  static const hint = Duration(milliseconds: 1400);
  static const hintOut = Curves.easeOut;
  static const hintBack = Curves.easeIn;
}

/// An under-damped spring as a [Curve], for APIs that take a duration and a
/// curve (routes, sheets, flutter_animate), plus the time it needs to settle.
class SpringCurve extends Curve {
  SpringCurve(SpringDescription spring)
    : _simulation = SpringSimulation(spring, 0, 1, 0),
      duration = _settleTime(spring);

  final SpringSimulation _simulation;

  /// How long the spring takes to come within 0.2% of rest.
  final Duration duration;

  static Duration _settleTime(SpringDescription spring) {
    final zeta =
        spring.damping / (2 * math.sqrt(spring.stiffness * spring.mass));
    final omega = math.sqrt(spring.stiffness / spring.mass);
    final seconds = math.min(2.2, -math.log(0.002) / (zeta * omega));
    return Duration(
      microseconds: (seconds * Duration.microsecondsPerSecond).round(),
    );
  }

  @override
  double transformInternal(double t) => _simulation.x(
    t * duration.inMicroseconds / Duration.microsecondsPerSecond,
  );
}

/// The phone's "Reduce motion" (iOS) or "Remove animations" (Android).
extension MotionContext on BuildContext {
  /// True when the phone asks for no movement: every animation jumps to
  /// its end.
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);

  /// [duration], or zero when the phone asks for reduced motion.
  Duration motion(Duration duration) => reduceMotion ? Duration.zero : duration;
}
