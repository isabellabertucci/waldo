import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/theme/app_colors.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/elevation.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/dashed_border.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// How long a deleted item can still be brought back.
const undoWindow = Duration(seconds: 5);

/// The 48dp Undo button with the bar's padding above and below it.
const _barHeight = kMinInteractiveDimension + Spacing.xs * 2;
const _restoredDuration = Duration(seconds: 2);

/// Shows the undo bar for an item that was just hidden. Completes with true
/// if Undo was tapped, or false once the item should be deleted for good:
/// time ran out, the bar was swiped away, or another delete replaced it.
Future<bool> showUndoSnackBar(
  ScaffoldMessengerState messenger, {
  required String title,
  String? subtitle,
  required String restoredLabel,
}) async {
  // A new delete finalizes the one on screen right away.
  messenger.hideCurrentSnackBar();
  // Read now: the messenger's context isn't safe to use after the wait.
  final transparent = messenger.context.appColors.transparent;

  final reason = await messenger
      .showSnackBar(
        _barSnackBar(
          transparent,
          // The bar times itself, so it can pause while the app is away.
          duration: const Duration(days: 1),
          child: _UndoBar(
            title: title,
            subtitle: subtitle,
            onUndo: () => messenger.hideCurrentSnackBar(
              reason: SnackBarClosedReason.action,
            ),
            onTimeout: () => messenger.hideCurrentSnackBar(
              reason: SnackBarClosedReason.timeout,
            ),
          ),
        ),
      )
      .closed;

  final undone = reason == SnackBarClosedReason.action;
  if (undone) {
    messenger.showSnackBar(
      _barSnackBar(
        transparent,
        duration: _restoredDuration,
        child: _RestoredBar(label: restoredLabel),
      ),
    );
  }
  return undone;
}

/// A transparent snackbar, so the bar draws its own shape and shadow.
SnackBar _barSnackBar(
  Color transparent, {
  required Duration duration,
  required Widget child,
}) {
  return SnackBar(
    content: child,
    duration: duration,
    behavior: SnackBarBehavior.floating,
    backgroundColor: transparent,
    elevation: 0,
    padding: EdgeInsets.zero,
    clipBehavior: Clip.none,
    margin: const EdgeInsets.fromLTRB(
      Spacing.sm,
      0,
      Spacing.sm,
      Spacing.component,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Rounded.md),
    ),
  );
}

/// The ink container both bars share; it slides up as it fades in.
class _BarShell extends StatelessWidget {
  const _BarShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: Motion.enter,
      curve: Motion.enterCurve,
      builder: (context, t, child) => Transform.translate(
        offset: Offset(0, Motion.enterRise * t),
        child: Opacity(opacity: 1 - t, child: child),
      ),
      // At least 64 tall, and taller with large text, so it never clips.
      child: Container(
        constraints: const BoxConstraints(minHeight: _barHeight),
        padding: const EdgeInsets.fromLTRB(
          Spacing.component,
          Spacing.xs,
          Spacing.xs,
          Spacing.xs,
        ),
        decoration: BoxDecoration(
          // Ink in both themes, like the wallet card.
          color: colors.leather,
          borderRadius: BorderRadius.circular(Rounded.md),
          // On the dark page the ink bar needs an edge to show where it ends.
          border: isDark
              ? Border.all(
                  color: colors.onLeather.withValues(alpha: Alpha.soft),
                )
              : null,
          boxShadow: Elevation.high,
        ),
        child: child,
      ),
    );
  }
}

class _UndoBar extends StatefulWidget {
  const _UndoBar({
    required this.title,
    required this.subtitle,
    required this.onUndo,
    required this.onTimeout,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onUndo;
  final VoidCallback onTimeout;

  @override
  State<_UndoBar> createState() => _UndoBarState();
}

class _UndoBarState extends State<_UndoBar>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _countdown = AnimationController(
    vsync: this,
    duration: undoWindow,
  );

  /// True with VoiceOver or TalkBack on: reaching Undo takes longer than the
  /// window, so the bar waits, as Flutter's own SnackBar with an action does.
  bool _waitsForUndo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _countdown.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onTimeout();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _waitsForUndo = MediaQuery.accessibleNavigationOf(context);
    if (_waitsForUndo) {
      _countdown.stop();
    } else if (!_countdown.isCompleted) {
      _countdown.forward();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The clock stops while the app is in the background.
    if (state == AppLifecycleState.resumed) {
      if (!_waitsForUndo && !_countdown.isCompleted) _countdown.forward();
    } else {
      _countdown.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subtitle = widget.subtitle;
    // No clock while it waits; a ring stuck at 5 would read as one.
    final badge = _waitsForUndo
        ? const _IconDisc(icon: AppIcons.delete)
        : _CountdownRing(progress: _countdown);
    const gap = SizedBox(width: Spacing.component);
    final texts = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WholeWordsText.singleLine(
          widget.title,
          style: context.bodyMdStrong.copyWith(color: colors.onLeather),
        ),
        if (subtitle != null && subtitle.isNotEmpty)
          WholeWordsText.singleLine(
            subtitle,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onLeather.withValues(alpha: Alpha.muted),
            ),
          ),
      ],
    );

    return Semantics(
      liveRegion: true,
      container: true,
      child: _BarShell(
        // At accessibility sizes Undo moves under the message, so neither
        // squeezes the other.
        child: DynamicTypeScaler.isAccessibilitySize(context)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      badge,
                      gap,
                      Expanded(child: texts),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs),
                  _UndoButton(onPressed: widget.onUndo),
                ],
              )
            : Row(
                children: [
                  badge,
                  gap,
                  Expanded(child: texts),
                  gap,
                  _UndoButton(onPressed: widget.onUndo),
                ],
              ),
      ),
    );
  }
}

/// Drains from full to empty over [undoWindow], with the seconds left inside.
class _CountdownRing extends StatelessWidget {
  const _CountdownRing({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: ComponentSize.undoRing,
        child: AnimatedBuilder(
          animation: progress,
          builder: (context, _) {
            final secondsLeft = math.max(
              1,
              (undoWindow.inSeconds * (1 - progress.value)).ceil(),
            );
            return CustomPaint(
              painter: _RingPainter(
                remaining: 1 - progress.value,
                track: colors.onLeather.withValues(alpha: Alpha.medium),
                // The bar is ink in both themes, so it takes dark mode's orange.
                fill: AppColors.dark.error,
              ),
              // The number stops growing where bars do, so it stays inside
              // the ring.
              child: MediaQuery.withClampedTextScaling(
                maxScaleFactor: DynamicTypeScaler.barMaxScale,
                child: Center(
                  child: Text(
                    '$secondsLeft',
                    style: context.bodySmBold.copyWith(
                      color: colors.onLeather,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.remaining,
    required this.track,
    required this.fill,
  });

  final double remaining;
  final Color track;
  final Color fill;

  static const _strokeWidth = 2.4;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      // An 11-in-14 radius, leaving room for the round caps.
      radius: size.shortestSide / 2 * 11 / 14,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = track);
    // From 12 o'clock, clockwise, shrinking back toward 12 as time runs out.
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * remaining,
      false,
      paint..color = fill,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      remaining != oldDelegate.remaining ||
      track != oldDelegate.track ||
      fill != oldDelegate.fill;
}

/// A cream pill with an ink stitch: the nav's selected button, inverted.
class _UndoButton extends StatelessWidget {
  const _UndoButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    // A button to screen readers, apart from the bar's text: a bare InkWell
    // is only read as its label.
    return Semantics(
      container: true,
      button: true,
      child: Material(
        color: colors.onLeather,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          // At least 48 tall, and taller with large text.
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.xxs),
              child: DashedBorder(
                radius: Rounded.pill,
                color: colors.leather.withValues(alpha: Alpha.stitch),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm - Spacing.xxs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        AppIcons.undo,
                        size: IconSize.md,
                        color: colors.leather,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        l10n.undo,
                        style: context.bodyMdStrong.copyWith(
                          color: colors.leather,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A cream disc the size of the countdown ring, with an ink icon.
class _IconDisc extends StatelessWidget {
  const _IconDisc({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: ComponentSize.undoRing,
      height: ComponentSize.undoRing,
      decoration: BoxDecoration(
        color: colors.onLeather,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: IconSize.md, color: colors.leather),
    );
  }
}

/// The short "restored" confirmation after Undo.
class _RestoredBar extends StatelessWidget {
  const _RestoredBar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      liveRegion: true,
      container: true,
      child: _BarShell(
        child: Row(
          children: [
            const _IconDisc(icon: AppIcons.check),
            const SizedBox(width: Spacing.component),
            Expanded(
              child: WholeWordsText.singleLine(
                label,
                style: context.bodyMdStrong.copyWith(color: colors.onLeather),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
