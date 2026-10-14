import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// One choice in a [SettingsOptionSheet] - either [icon] or [symbolText] is
/// given, never both: an [IconData] for most pickers (theme, date format),
/// or a currency symbol ("$", "€"...) where a generic icon wouldn't tell
/// the options apart.
class SettingsOption<T> {
  const SettingsOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.symbolText,
  }) : assert(
         (icon == null) != (symbolText == null),
         'Provide exactly one of icon or symbolText',
       );

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final String? symbolText;
}

/// Floating bottom sheet shared by every settings picker (theme, currency,
/// date format) - a dashed-stitch card in the app's own surface/on-surface
/// tokens, so it reads as a light card in light mode and a dark one in
/// dark mode, same as every other sheet - only the orange accent (used for
/// the selected option and the Done button) stays constant across both. A
/// choice only takes effect when "Done" is pressed, not the instant a row
/// is tapped, so picking the wrong row by accident is still recoverable.
class SettingsOptionSheet<T> extends StatefulWidget {
  const SettingsOptionSheet({
    required this.title,
    required this.initialValue,
    required this.options,
    required this.onConfirm,
    this.notice,
    super.key,
  });

  final String title;
  final T initialValue;
  final List<SettingsOption<T>> options;
  final String? notice;
  final ValueChanged<T> onConfirm;

  @override
  State<SettingsOptionSheet<T>> createState() => _SettingsOptionSheetState<T>();
}

class _SettingsOptionSheetState<T> extends State<SettingsOptionSheet<T>> {
  late T _selected = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    return Material(
      color: colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Rounded.lg),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: colors.surface),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _DashedBorderPainter(
                      color: colors.onSurface,
                      radius: Rounded.lg,
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: Spacing.sm),
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(Rounded.pill),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.lg,
                        Spacing.md,
                        Spacing.lg,
                        Spacing.lg,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: context.headlineSmBold.copyWith(
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                              const SheetCloseButton(),
                            ],
                          ),
                          const SizedBox(height: Spacing.md),
                          for (var i = 0; i < widget.options.length; i++) ...[
                            if (i > 0) const SizedBox(height: Spacing.sm),
                            _OptionRow<T>(
                              option: widget.options[i],
                              selected: widget.options[i].value == _selected,
                              onTap: () => setState(
                                () => _selected = widget.options[i].value,
                              ),
                            ),
                          ],
                          if (widget.notice != null) ...[
                            const SizedBox(height: Spacing.md),
                            _NoticeBox(text: widget.notice!),
                          ],
                          const SizedBox(height: Spacing.lg),
                          // The app's own "main action" pill - solid
                          // `primary` (ink black in light mode, cream in
                          // dark) with the same dashed stitch as the
                          // navbar's active tab and the wallet card's own
                          // border, not a one-off orange fill.
                          SizedBox(
                            width: double.infinity,
                            child: DashedStitchButton(
                              label: l10n.done,
                              onPressed: () {
                                widget.onConfirm(_selected);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionRow<T> extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final SettingsOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final badgeColor = selected ? colors.primary : colors.fieldFill;

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(Rounded.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Rounded.md),
          child: Stack(
            children: [
              if (selected)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _DashedBorderPainter(
                        color: colors.primary,
                        radius: Rounded.md,
                        opaque: true,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(Spacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      // Selected: `onPrimary` on the solid `primary` fill - the
                      // same ink/cream pair as the Done button.
                      // Unselected: the adaptive muted text color, since the
                      // badge itself is a neutral, theme-aware fill
                      // (`fieldFill`).
                      child: option.symbolText != null
                          ? Text(
                              option.symbolText!,
                              style: context.headlineMdStrong.copyWith(
                                color: selected
                                    ? colors.onPrimary
                                    : colors.onSurfaceVariant,
                              ),
                            )
                          : Icon(
                              option.icon,
                              size: IconSize.lg,
                              color: selected
                                  ? colors.onPrimary
                                  : colors.onSurfaceVariant,
                            ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            option.label,
                            style: context.bodyMdBold.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                          if (option.subtitle != null)
                            Text(
                              option.subtitle!,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    if (selected)
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          AppIcons.check,
                          size: IconSize.sm,
                          color: colors.onPrimary,
                        ),
                      )
                    else
                      Icon(
                        AppIcons.radioUnselected,
                        size: 22,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoticeBox extends StatelessWidget {
  const _NoticeBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(Rounded.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            AppIcons.info,
            size: IconSize.md,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashed stitch border, matching the balance card's own [PouchBorder] -
/// the same visual family, just a plain rounded rect instead of the pouch
/// silhouette (a sheet has no dip notch to trace). `opaque` draws a
/// brighter, more solid-reading stitch for a selected option row, where it
/// needs to read as an active highlight rather than decoration.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    this.opaque = false,
  });

  final Color color;
  final double radius;
  final bool opaque;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color.withValues(alpha: opaque ? 0.8 : 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + 6.0;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + 5.0;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      radius != oldDelegate.radius ||
      opaque != oldDelegate.opaque;
}
