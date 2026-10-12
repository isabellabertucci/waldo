import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

/// Horizontal strip of month pills - the selected month sits in a filled
/// pill, the rest read as plain text that fades out toward the edges to
/// hint that more months are a swipe away. Replaces the old "October ▾"
/// header button + bottom sheet list with direct, one-tap selection.
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

  @override
  void initState() {
    super.initState();
    _itemKeys = {for (final month in widget.months) month: GlobalKey()};
    _scrollController.addListener(_updateScrollAffordances);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
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
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _scrollToSelected() {
    if (!mounted) return;
    final itemContext = _itemKeys[widget.selectedMonth]?.currentContext;
    if (itemContext == null) return;
    Scrollable.ensureVisible(
      itemContext,
      alignment: 0.5,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _updateScrollAffordances() {
    if (!mounted || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    final canScrollBack = position.pixels > position.minScrollExtent + 1;
    final canScrollForward = position.pixels < position.maxScrollExtent - 1;
    if (canScrollBack == _canScrollBack &&
        canScrollForward == _canScrollForward) {
      return;
    }
    setState(() {
      _canScrollBack = canScrollBack;
      _canScrollForward = canScrollForward;
    });
  }

  /// The selected month is spelled out; the others are short so the
  /// neighbours on either side fit whole instead of being cut mid-word. A
  /// month from another year always carries its year, so e.g. last November
  /// and next November never read as the same pill.
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

  void _scrollBy(double delta) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final target = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
          onTap: () => _scrollBy(-160),
        ),
        const SizedBox(width: Spacing.xs),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Half the viewport as leading/trailing padding - without
              // this, the first or last month (often the selected one,
              // since "today" is always the last entry) can't actually
              // reach the center: there's no scroll extent left to push it
              // there, so it stays pinned to the edge instead.
              final edgePadding = constraints.maxWidth / 2;

              // one-off: Colors.transparent/black below are an alpha mask
              // (BlendMode.dstIn only reads opacity) that fades the month
              // row out at both edges - never painted, so no theme color.
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
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: edgePadding),
                  child: Row(
                    children: [
                      for (final month in widget.months) ...[
                        _MonthPill(
                          key: _itemKeys[month],
                          label: _labelFor(month),
                          selected: month == widget.selectedMonth,
                          // Defensive, not just decorative - nothing past
                          // the real current month is a month that could
                          // have any transactions yet.
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
              );
            },
          ),
        ),
        const SizedBox(width: Spacing.xs),
        _ChevronButton(
          direction: _ChevronDirection.right,
          enabled: _canScrollForward,
          onTap: () => _scrollBy(160),
        ),
        const SizedBox(width: Spacing.lg),
      ],
    );
  }
}

enum _ChevronDirection { left, right }

/// A small chevron that nudges left twice, once, right after the dashboard
/// first appears - a one-time hint that the month row scrolls, instead of
/// a gradient or clipped edge alone (neither read as "scrollable" on their
/// own in testing). Settles back to a static resting chevron afterward. Also
/// a real scroll-back control - tapping it steps the row backward, and it
/// dims (without disappearing, to avoid shifting the layout) once there is
/// nothing earlier left to scroll to.
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

/// The right-side mirror of [_ScrollHintChevron], without the one-time nudge
/// animation (that hint only needs to play once, pointing the direction the
/// row scrolls by default) but with the same tap-to-scroll and dim-when-idle
/// behavior - so going far back in time doesn't strand the user without an
/// easy way to scroll forward again.
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
