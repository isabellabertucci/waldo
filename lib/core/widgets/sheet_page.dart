import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';

/// A tab's page (DESIGN.md "Layout"): the beige [top] with the balance and
/// actions, then the white sheet with the detail, scrolling as one. It runs
/// up under the status bar and on under the floating navbar (AppShell's
/// `extendBody`), and pads for both itself, so the screen has no SafeArea.
///
/// With a [bar], once the top has scrolled away a slim bar stays pinned at
/// the top, so its few actions (hiding amounts) are in reach anywhere in a
/// long list (DESIGN.md "Compact bar").
class SheetPage extends StatefulWidget {
  const SheetPage({
    super.key,
    required this.top,
    required this.sheet,
    this.bar,
  });

  final Widget top;
  final Widget sheet;

  /// The pinned bar's content, usually a [SheetPageBar].
  final Widget? bar;

  @override
  State<SheetPage> createState() => _SheetPageState();
}

class _SheetPageState extends State<SheetPage> {
  final _controller = ScrollController();
  final _topKey = GlobalKey();
  bool _isBarShown = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The top's height when last laid out: scrolled far, the list lets it
  /// go, so it can't be measured then. Also sets the sheet's least height.
  double? _topHeight;

  /// Shown once what's left of the top would sit under the bar (the
  /// status bar and the bar's row), so nothing slides under the clock
  /// unbacked.
  void _onScroll() {
    if (widget.bar == null) return;
    final topHeight = _topKey.currentContext?.size?.height ?? _topHeight;
    if (topHeight == null) return;
    _topHeight = topHeight;
    final barHeight =
        MediaQuery.paddingOf(context).top +
        kMinInteractiveDimension +
        Spacing.xs * 2;
    final shown = _controller.offset >= topHeight - barHeight;
    if (shown != _isBarShown) setState(() => _isBarShown = shown);
  }

  /// Keeps [_topHeight] current, for the sheet's minimum height.
  void _measureTop() {
    final height = _topKey.currentContext?.size?.height;
    if (height != null && height != _topHeight && mounted) {
      setState(() => _topHeight = height);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final padding = MediaQuery.paddingOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureTop());

    final list = LayoutBuilder(
      builder: (context, viewport) => ListView(
        controller: _controller,
        padding: EdgeInsets.zero,
        children: [
          DecoratedBox(
            key: _topKey,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.bgTop, colors.bg],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.pageMargin,
                padding.top + Spacing.md,
                Spacing.pageMargin,
                Spacing.md,
              ),
              child: widget.top,
            ),
          ),
          // The top's last colour sits behind the sheet's rounded corners.
          ColoredBox(
            color: colors.bg,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.sheet,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Rounded.sheet),
                ),
              ),
              // At least down to the screen's bottom, so a short page never
              // shows beige under its sheet.
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: math.max(
                    0,
                    viewport.maxHeight - (_topHeight ?? viewport.maxHeight),
                  ),
                ),
                child: Padding(
                  // Inside the sheet, so its white runs on under the
                  // floating navbar.
                  padding: EdgeInsets.only(
                    top: Spacing.md,
                    bottom: Spacing.xl + padding.bottom,
                  ),
                  child: widget.sheet,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final bar = widget.bar;
    if (bar == null) return list;
    return Stack(
      children: [
        list,
        // A quick fade, no slide: a moving bar distracts from the list.
        // Gone while the top shows, so its buttons are never there twice.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSwitcher(
            duration: context.motion(Motion.toggle),
            child: !_isBarShown
                ? const SizedBox.shrink()
                : DecoratedBox(
                    key: const Key('sheetPageBar'),
                    decoration: BoxDecoration(
                      color: colors.sheet,
                      border: Border(bottom: BorderSide(color: colors.line)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        Spacing.pageMargin,
                        padding.top + Spacing.xs,
                        Spacing.pageMargin,
                        Spacing.xs,
                      ),
                      child: bar,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// A [SheetPage]'s pinned bar: what the page is and its amount in small,
/// between a [leading] button (back) and a [trailing] one (hide amounts).
class SheetPageBar extends StatelessWidget {
  const SheetPageBar({
    super.key,
    required this.title,
    this.amount,
    this.leading,
    this.trailing,
  });

  final String title;

  /// Already formatted, or the hidden mask.
  final Widget? amount;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    // A button on one side only: an equal gap on the other keeps the title
    // centred.
    const balance = SizedBox(width: kMinInteractiveDimension);
    return Row(
      children: [
        leading ?? (trailing == null ? const SizedBox.shrink() : balance),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WholeWordsText.singleLine(
                  title,
                  textAlign: TextAlign.center,
                  style: context.bodyStrong,
                ),
                ?amount,
              ],
            ),
          ),
        ),
        trailing ?? (leading == null ? const SizedBox.shrink() : balance),
      ],
    );
  }
}
