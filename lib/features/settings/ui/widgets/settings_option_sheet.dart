import 'package:waldo/core/utils/dash_path.dart';
import 'package:flutter/material.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/sheet_grabber.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// One choice in a [SettingsOptionSheet]: either an [icon] or a [symbolText].
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

/// The bottom sheet for every settings picker. A choice only applies on "Done".
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
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: Spacing.sm),
                const SheetGrabber(),
                // Scrolls when large text makes it taller than the screen.
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.md,
                        Spacing.md,
                        Spacing.md,
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
                  ),
                ),
              ],
            ),
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
                      width: BadgeSize.lg,
                      height: BadgeSize.lg,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      // Selected: `onPrimary` on `primary`; unselected: muted on a neutral fill.
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

/// A dashed stitch around a rounded rect; [opaque] makes it stronger, for the
/// selected row.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    this.opaque = false,
  });

  static const _dashLength = 6.0;
  static const _gapLength = 5.0;

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

    canvas.drawPath(
      dashPath(
        Path()..addRRect(rrect),
        dashLength: _dashLength,
        gapLength: _gapLength,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      radius != oldDelegate.radius ||
      opaque != oldDelegate.opaque;
}
