import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/min_tap_target.dart';

/// How much a [PillButton] stands out. Every variant has the same
/// size, so buttons side by side always match.
enum PillButtonVariant {
  /// Solid yellow (`action`): the main action.
  primary,

  /// A neutral tinted pill: the action beside the main one (Cancel).
  secondary,

  /// Solid red (`error`): an action that loses something.
  destructive,
}

/// A solid pill - the app's button.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    this.label,
    this.icon,
    this.onPressed,
    this.padding,
    this.tooltip,
    this.variant = PillButtonVariant.primary,
  }) : assert(
         (label == null) != (icon == null),
         'A PillButton has a centred label, or an icon alone - never both',
       );

  final String? label;
  final Widget? icon;
  final VoidCallback? onPressed;

  /// Overrides the standard padding, e.g. for buttons side by side that
  /// share a row's width.
  final EdgeInsetsGeometry? padding;

  /// What the button does, for screen readers and long-press - required in
  /// practice when the button has an [icon] but no [label].
  final String? tooltip;

  final PillButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isIconOnly = label == null;
    // A label that wraps at accessibility sizes would run into a pill's
    // round ends, so the button becomes a rounded rectangle.
    final radius = !isIconOnly && DynamicTypeScaler.isAccessibilitySize(context)
        ? Rounded.lg
        : Rounded.pill;
    // No `onError` token yet; a filled button's ink is `onPrimary`.
    // Yellow for the main action, like the main action circle (DESIGN.md
    // "Buttons").
    final (fill, ink) = switch (variant) {
      PillButtonVariant.primary => (colors.primary, colors.onPrimary),
      PillButtonVariant.secondary => (colors.card, colors.ink),
      PillButtonVariant.destructive => (colors.negative, colors.onInk),
    };

    final button = Material(
      color: fill,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onPressed,
        child: Padding(
          padding:
              padding ??
              (isIconOnly
                  ? const EdgeInsets.all(Spacing.component)
                  : const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.sm,
                    )),
          // Centred however wide the button is; as tall as its content.
          child: Center(
            heightFactor: 1,
            child: switch (label) {
              // A narrow button ellipsizes the label; at
              // accessibility sizes it wraps.
              final label? => WholeWordsText.singleLine(
                label,
                textAlign: TextAlign.center,
                style: context.bodyStrong.copyWith(color: ink),
              ),
              null => IconTheme(
                data: IconThemeData(color: ink, size: IconSize.md),
                child: icon!,
              ),
            },
          ),
        ),
      ),
    );

    final tooltip = this.tooltip;
    final named = tooltip == null
        ? button
        : Tooltip(message: tooltip, child: button);
    // A button to screen readers (a bare InkWell is only read as its label),
    // outside the tooltip as Flutter's IconButton does, so name, role and tap
    // share one node; its own node, as Flutter's buttons are, so text beside
    // it never joins its name.
    return Semantics(
      container: true,
      button: true,
      enabled: onPressed != null,
      // The icon-only disc is smaller than a comfortable touch.
      child: isIconOnly ? MinTapTarget(onTap: onPressed, child: named) : named,
    );
  }
}
