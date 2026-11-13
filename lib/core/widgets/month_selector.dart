import 'package:flutter/foundation.dart';
import 'package:waldo/core/theme/fades.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:flutter/material.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/stretch_pill.dart';

const _chevronHitSize = kMinInteractiveDimension;
const _chevronOverhang = (_chevronHitSize - BadgeSize.xs) / 2;

/// The months a [MonthSelector] offers: the [count] months up to [now]'s,
/// oldest first, plus next month (shown disabled) so the row doesn't end at
/// the selected pill.
List<DateTime> selectorMonths(DateTime now, {int count = 12}) => [
  for (var i = count - 1; i >= 0; i--) DateTime(now.year, now.month - i),
  DateTime(now.year, now.month + 1),
];

/// A horizontal row of month pills; the selected month is a filled pill.
class MonthSelector extends StatefulWidget {
  const MonthSelector({
    super.key,
    required this.months,
    required this.selectedMonth,
    required this.currentMonth,
    required this.locale,
    required this.onSelect,
    this.hintsScroll = true,
  });

  /// Oldest first, so the row reads left-to-right like a calendar.
  final List<DateTime> months;
  final DateTime selectedMonth;

  /// The real current month - months after it are shown but disabled.
  final DateTime currentMonth;
  final String locale;
  final ValueChanged<DateTime> onSelect;

  /// Nudges the left chevron on first show, to hint that the row scrolls.
  final bool hintsScroll;

  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  final _scrollController = ScrollController();
  late Map<DateTime, GlobalKey> _itemKeys;

  /// True when every month fits on screen, so there's nothing to drag to.
  bool _fits = false;

  @override
  void initState() {
    super.initState();
    _itemKeys = {for (final month in widget.months) month: GlobalKey()};
    _scrollController.addListener(_updateScrollAffordances);
    // Jump, not animate: the selected month is known up front, so the row
    // opens already on it instead of sliding there while a sheet rises.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(animate: false);
      _updateScrollAffordances();
    });
  }

  TextScaler? _textScaler;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A new text size in the phone's settings resizes every pill, so the
    // selected month drifts off-centre; put it back.
    final textScaler = MediaQuery.textScalerOf(context);
    if (_textScaler != null && textScaler != _textScaler) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected(animate: false);
        _updateScrollAffordances();
      });
    }
    _textScaler = textScaler;
  }

  @override
  void didUpdateWidget(covariant MonthSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    final monthsChanged = !listEquals(oldWidget.months, widget.months);
    if (monthsChanged) {
      _itemKeys = {
        for (final month in widget.months)
          month: _itemKeys[month] ?? GlobalKey(),
      };
    }
    if (monthsChanged || oldWidget.selectedMonth != widget.selectedMonth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected();
        _updateScrollAffordances();
      });
    }
  }

  void _scrollToSelected({bool animate = true}) {
    if (!mounted || !_scrollController.hasClients) return;
    final box = _itemKeys[widget.selectedMonth]?.currentContext
        ?.findRenderObject();
    if (box == null) return;
    final position = _scrollController.position;
    final target = RenderAbstractViewport.of(box)
        .getOffsetToReveal(box, 0.5)
        .offset
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if (animate) {
      _animateTo(target);
    } else {
      _scrollController.jumpTo(target);
    }
  }

  void _updateScrollAffordances() {
    if (!mounted || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    // The scroll extent equals the months' width, since each edge pads half the viewport.
    final fits = position.maxScrollExtent <= position.viewportDimension;
    if (fits != _fits) setState(() => _fits = fits);
  }

  /// The selected month is spelled out and the rest are short, so neighbours
  /// fit whole. Months from another year show the year.
  String _labelFor(DateTime month) {
    final locale = widget.locale;
    final isSelected = month == widget.selectedMonth;
    final isThisYear = month.year == widget.currentMonth.year;
    return switch ((isSelected, isThisYear)) {
      (true, true) => DateFormat.MMMM(locale).format(month),
      (true, false) => DateFormat.yMMMM(locale).format(month),
      (false, true) => DateFormat.MMM(locale).format(month),
      (false, false) => DateFormat.yMMM(locale).format(month),
    };
  }

  /// The scroll offsets that centre each month you can pick (not future ones).
  List<double> _pickableOffsets() {
    return [
      for (final month in widget.months)
        if (!month.isAfter(widget.currentMonth))
          if (_itemKeys[month]?.currentContext?.findRenderObject()
              case final RenderObject box)
            RenderAbstractViewport.of(box).getOffsetToReveal(box, 0.5).offset,
    ];
  }

  void _animateTo(double offset) {
    _scrollController.animateTo(
      offset,
      duration: Motion.scroll,
      curve: Motion.scrollCurve,
    );
  }

  /// After a drag, settle on the nearest pickable month so none sits half-cut.
  void _snapToNearest() {
    if (!mounted || !_scrollController.hasClients) return;
    final offsets = _pickableOffsets();
    if (offsets.isEmpty) return;
    final pixels = _scrollController.position.pixels;
    final nearest = offsets.reduce(
      (a, b) => (a - pixels).abs() <= (b - pixels).abs() ? a : b,
    );
    if ((nearest - pixels).abs() > 1) _animateTo(nearest);
  }

  void _select(DateTime month) {
    if (month != widget.selectedMonth) HapticFeedback.selectionClick();
    widget.onSelect(month);
  }

  /// The month beside the selected one that way, if it can be picked: not
  /// past either end, and not in the future.
  DateTime? _neighbour({required bool forward}) {
    final index = widget.months.indexOf(widget.selectedMonth);
    if (index < 0) return null;
    final next = index + (forward ? 1 : -1);
    if (next < 0 || next >= widget.months.length) return null;
    final month = widget.months[next];
    return month.isAfter(widget.currentMonth) ? null : month;
  }

  /// Chevron tap: pick the month beside the selected one; the row then
  /// scrolls it to the centre.
  void _step({required bool forward}) {
    if (_neighbour(forward: forward) case final month?) _select(month);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollAffordances);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // The 48dp hit box overhangs the disc, so the disc stays where it was.
        const SizedBox(width: Spacing.lg - _chevronOverhang),
        _ScrollHintChevron(
          enabled: _neighbour(forward: false) != null,
          nudges: widget.hintsScroll,
          onTap: () => _step(forward: false),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Half the viewport as padding, so the first and last months can scroll
              // to the center.
              final edgePadding = constraints.maxWidth / 2;

              return ShaderMask(
                shaderCallback: Fades.rowEdges.createShader,
                blendMode: BlendMode.dstIn,
                child: NotificationListener<ScrollEndNotification>(
                  onNotification: (_) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _snapToNearest(),
                    );
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    // The selected month still scrolls to the centre; only dragging stops.
                    physics: _fits
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    padding: EdgeInsets.symmetric(horizontal: edgePadding),
                    // Inside the scroll view, so the pill moves with the months.
                    child: StretchPill(
                      selectedKey: _itemKeys[widget.selectedMonth],
                      color: context.appColors.ink,
                      // A new month is simply filled, with no stretch.
                      stretches: false,
                      child: Row(
                        children: [
                          for (final month in widget.months) ...[
                            _MonthPill(
                              key: _itemKeys[month],
                              label: _labelFor(month),
                              selected: month == widget.selectedMonth,
                              // Months after the current one can't have transactions yet.
                              onTap: month.isAfter(widget.currentMonth)
                                  ? null
                                  : () => _select(month),
                            ),
                            if (month != widget.months.last)
                              const SizedBox(width: Spacing.md),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _ChevronButton(
          enabled: _neighbour(forward: true) != null,
          onTap: () => _step(forward: true),
        ),
        const SizedBox(width: Spacing.lg - _chevronOverhang),
      ],
    );
  }
}

/// The left chevron: with [nudges], nudges once on first show to hint the
/// row scrolls; picks the month before on tap, dimming when there's none.
class _ScrollHintChevron extends StatefulWidget {
  const _ScrollHintChevron({
    required this.enabled,
    required this.nudges,
    required this.onTap,
  });

  final bool enabled;
  final bool nudges;
  final VoidCallback onTap;

  @override
  State<_ScrollHintChevron> createState() => _ScrollHintChevronState();
}

class _ScrollHintChevronState extends State<_ScrollHintChevron>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;
  bool _depsInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Motion.hint);
    _offset = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -4.0,
        ).chain(CurveTween(curve: Motion.hintOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -4.0,
          end: 0.0,
        ).chain(CurveTween(curve: Motion.hintBack)),
        weight: 15,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 30),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -4.0,
        ).chain(CurveTween(curve: Motion.hintOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -4.0,
          end: 0.0,
        ).chain(CurveTween(curve: Motion.hintBack)),
        weight: 15,
      ),
    ]).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_depsInitialized) return;
    _depsInitialized = true;
    if (widget.nudges && !context.reduceMotion) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ChevronTarget(
      tooltip: AppLocalizations.of(context).previousMonth,
      enabled: widget.enabled,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _offset,
        builder: (context, child) =>
            Transform.translate(offset: Offset(_offset.value, 0), child: child),
        child: _ChevronDisc(icon: AppIcons.back, enabled: widget.enabled),
      ),
    );
  }
}

/// The right chevron: picks the month after on tap, dimming when there's
/// none to pick.
class _ChevronButton extends StatelessWidget {
  const _ChevronButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ChevronTarget(
      tooltip: AppLocalizations.of(context).nextMonth,
      enabled: enabled,
      onTap: onTap,
      child: _ChevronDisc(icon: AppIcons.chevronRight, enabled: enabled),
    );
  }
}

/// A named 48dp button around a small chevron disc, so it's easy to hit and
/// a screen reader can say what it does.
class _ChevronTarget extends StatelessWidget {
  const _ChevronTarget({
    required this.tooltip,
    required this.enabled,
    required this.onTap,
    required this.child,
  });

  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: SizedBox.square(
            dimension: _chevronHitSize,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _ChevronDisc extends StatelessWidget {
  const _ChevronDisc({required this.icon, required this.enabled});

  final IconData icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: BadgeSize.xs,
      height: BadgeSize.xs,
      decoration: BoxDecoration(color: colors.card, shape: BoxShape.circle),
      child: Icon(
        icon,
        size: IconSize.md,
        color: enabled ? colors.ink : colors.inkMuted,
      ),
    );
  }
}

class _MonthPill extends StatelessWidget {
  const _MonthPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final disabled = onTap == null;

    // Says which month is picked, like the wallet type tiles do.
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      enabled: !disabled,
      // The selector's StretchPill paints the fill behind it.
      child: Material(
        color: colors.transparent,
        borderRadius: BorderRadius.circular(Rounded.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(Rounded.pill),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: selected
                  ? ComponentSize.monthSelectedPadding
                  : Spacing.sm,
            ),
            alignment: Alignment.center,
            // The colour follows the pill as it passes; the size changes
            // at once, so nothing reflows while it moves.
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                end: selected
                    ? colors.onInk
                    : colors.inkMuted.withValues(alpha: disabled ? 0.4 : 1),
              ),
              // Changes with the pill, at once.
              duration: Duration.zero,
              builder: (context, color, _) => Text(
                label,
                // The selected month is a step larger and bold.
                style: (selected ? context.bodyStrong : context.label).copyWith(
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
