import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

/// A horizontal row of month pills; the selected month is a filled pill.
class MonthSelector extends StatefulWidget {
  const MonthSelector({
    super.key,
    required this.months,
    required this.selectedMonth,
    required this.currentMonth,
    required this.locale,
    required this.onSelect,
  });

  /// Oldest first, so the row reads left-to-right like a calendar.
  final List<DateTime> months;
  final DateTime selectedMonth;

  /// The real current month - months after it are shown but disabled.
  final DateTime currentMonth;
  final String locale;
  final ValueChanged<DateTime> onSelect;

  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  final _scrollController = ScrollController();
  late Map<DateTime, GlobalKey> _itemKeys;
  bool _canScrollBack = false;
  bool _canScrollForward = false;

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
    // Chevrons only light up when there's a pickable month that way.
    final offsets = _pickableOffsets();
    final canScrollBack = !fits && offsets.any((o) => o < position.pixels - 1);
    final canScrollForward =
        !fits && offsets.any((o) => o > position.pixels + 1);
    if (fits == _fits &&
        canScrollBack == _canScrollBack &&
        canScrollForward == _canScrollForward) {
      return;
    }
    setState(() {
      _fits = fits;
      _canScrollBack = canScrollBack;
      _canScrollForward = canScrollForward;
    });
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
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

  /// Chevron tap: centre the next pickable month that way.
  void _step({required bool forward}) {
    if (!_scrollController.hasClients) return;
    final pixels = _scrollController.position.pixels;
    final candidates = _pickableOffsets().where(
      (o) => forward ? o > pixels + 1 : o < pixels - 1,
    );
    if (candidates.isEmpty) return;
    _animateTo(forward ? candidates.first : candidates.last);
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
        const SizedBox(width: Spacing.lg),
        _ScrollHintChevron(
          enabled: _canScrollBack,
          onTap: () => _step(forward: false),
        ),
        const SizedBox(width: Spacing.xs),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Half the viewport as padding, so the first and last months can scroll
              // to the center.
              final edgePadding = constraints.maxWidth / 2;

              // one-off: an alpha mask (dstIn only reads opacity), never painted.
              return ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [0, 0.04, 0.92, 1],
                ).createShader(bounds),
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
                                : () => widget.onSelect(month),
                          ),
                          if (month != widget.months.last)
                            const SizedBox(width: Spacing.md),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: Spacing.xs),
        _ChevronButton(
          direction: _ChevronDirection.right,
          enabled: _canScrollForward,
          onTap: () => _step(forward: true),
        ),
        const SizedBox(width: Spacing.lg),
      ],
    );
  }
}

enum _ChevronDirection { left, right }

/// The left chevron: nudges once on first show to hint the row scrolls, then
/// steps the row back on tap, dimming when there's nothing earlier.
class _ScrollHintChevron extends StatefulWidget {
  const _ScrollHintChevron({required this.enabled, required this.onTap});

  final bool enabled;
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _offset = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -4.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -4.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 30),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -4.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -4.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
    ]).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_depsInitialized) return;
    _depsInitialized = true;
    if (!MediaQuery.of(context).disableAnimations) {
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
    final colors = context.appColors;

    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _offset,
        builder: (context, child) =>
            Transform.translate(offset: Offset(_offset.value, 0), child: child),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: colors.onSurface.withValues(alpha: 0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.chevron_left_rounded,
            size: IconSize.md,
            color: widget.enabled ? colors.onSurface : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// The right chevron: steps the row forward on tap, dimming at the end.
class _ChevronButton extends StatelessWidget {
  const _ChevronButton({
    required this.direction,
    required this.enabled,
    required this.onTap,
  });

  final _ChevronDirection direction;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: colors.onSurface.withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(
          direction == _ChevronDirection.left
              ? Icons.chevron_left_rounded
              : AppIcons.chevronRight,
          size: IconSize.md,
          color: enabled ? colors.onSurface : colors.onSurfaceVariant,
        ),
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

    return Material(
      color: colors.transparent,
      borderRadius: BorderRadius.circular(Rounded.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(Rounded.pill),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: EdgeInsets.symmetric(
            horizontal: selected ? Spacing.sm - 2 : Spacing.sm,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.transparent,
            borderRadius: BorderRadius.circular(Rounded.pill),
          ),
          child: Text(
            label,
            // The selected chip's own size/weight bump - a dedicated
            // selected-state treatment, not a named type-scale step.
            style: context.textTheme.bodyMedium?.copyWith(
              fontSize: selected ? 14 : 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? colors.onPrimary
                  : colors.onSurfaceVariant.withValues(
                      alpha: disabled ? 0.4 : 1,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
