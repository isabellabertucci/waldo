import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/core/widgets/badge_row.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/sheet_grabber.dart';
import 'package:waldo/core/widgets/dashed_border.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/widgets/heading.dart';

/// One choice in an [OptionSheet]: either an [icon] or a [symbolText].
class SheetOption<T> {
  const SheetOption({
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

/// A first row in an [OptionSheet] that does something instead of picking
/// (e.g. "New category").
typedef SheetAction = ({IconData icon, String label, VoidCallback onTap});

/// Opens an [OptionSheet], as every picker in the app does.
Future<void> showOptionSheet<T>(
  BuildContext context, {
  required String title,
  required T initialValue,
  required List<SheetOption<T>> options,
  required ValueChanged<T> onConfirm,
  bool pickOnTap = false,
  SheetAction? action,
  String? notice,
}) {
  return showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: context.appColors.transparent,
    // Grows with the options, then scrolls; never under the status bar.
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => OptionSheet<T>(
      title: title,
      initialValue: initialValue,
      options: options,
      onConfirm: onConfirm,
      pickOnTap: pickOnTap,
      action: action,
      notice: notice,
    ),
  );
}

/// The bottom sheet for every picker: one tile per option, the chosen one
/// stitched. In Settings a choice applies on "Done"; with [pickOnTap] (a
/// form's field) a tap picks it and closes the sheet.
class OptionSheet<T> extends StatefulWidget {
  const OptionSheet({
    required this.title,
    required this.initialValue,
    required this.options,
    required this.onConfirm,
    this.pickOnTap = false,
    this.action,
    this.notice,
    super.key,
  });

  final String title;
  final T initialValue;
  final List<SheetOption<T>> options;
  final String? notice;
  final ValueChanged<T> onConfirm;
  final bool pickOnTap;

  /// A first tile, always in sight, that closes the sheet and runs.
  final SheetAction? action;

  @override
  State<OptionSheet<T>> createState() => _OptionSheetState<T>();
}

class _OptionSheetState<T> extends State<OptionSheet<T>> {
  late T _selected = widget.initialValue;

  void _pick(T value) {
    if (!widget.pickOnTap) {
      setState(() => _selected = value);
      return;
    }
    Navigator.of(context).pop();
    widget.onConfirm(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SheetShell(
      title: widget.title,
      children: [
        if (widget.action case final action?) ...[
          _ActionRow(action: action),
          const SizedBox(height: Spacing.sm),
        ],
        for (var i = 0; i < widget.options.length; i++) ...[
          if (i > 0) const SizedBox(height: Spacing.sm),
          _OptionRow(
            label: widget.options[i].label,
            subtitle: widget.options[i].subtitle,
            icon: widget.options[i].icon,
            symbolText: widget.options[i].symbolText,
            selected: widget.options[i].value == _selected,
            onTap: () => _pick(widget.options[i].value),
          ),
        ],
        if (widget.notice != null) ...[
          const SizedBox(height: Spacing.md),
          _NoticeBox(text: widget.notice!),
        ],
        if (!widget.pickOnTap) ...[
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
      ],
    );
  }
}

/// Opens a sheet of things to do, in the same tiles as every picker (the
/// dashboard's "Add").
Future<void> showActionSheet(
  BuildContext context, {
  required String title,
  required List<SheetAction> actions,
}) {
  return showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: context.appColors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ActionSheet(title: title, actions: actions),
  );
}

/// A picker's sheet with only actions: a tap closes it and runs one.
class _ActionSheet extends StatelessWidget {
  const _ActionSheet({required this.title, required this.actions});

  final String title;
  final List<SheetAction> actions;

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: title,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(height: Spacing.sm),
          _ActionRow(action: actions[i]),
        ],
      ],
    );
  }
}

/// The grabber, title, close button and scrolling body every sheet here has.
class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
                                child: Heading(
                                  child: Text(
                                    title,
                                    style: context.headlineSmExtraBold.copyWith(
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                              const SheetCloseButton(),
                            ],
                          ),
                          const SizedBox(height: Spacing.md),
                          ...children,
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

/// An action's tile: closes the sheet, then runs it.
class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.action});

  final SheetAction action;

  @override
  Widget build(BuildContext context) {
    return _OptionRow(
      label: action.label,
      icon: action.icon,
      isChoice: false,
      onTap: () {
        Navigator.of(context).pop();
        action.onTap();
      },
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.symbolText,
    this.selected = false,
    this.isChoice = true,
  });

  final String label;
  final String? subtitle;
  final IconData? icon;
  final String? symbolText;
  final bool selected;
  final VoidCallback onTap;

  /// False for the sheet's action tile: no ring, not one of a group.
  final bool isChoice;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Unpicked, the sheet behind the row shows through, as if cut out.
    final badgeColor = selected ? colors.primary : colors.surface;

    return Semantics(
      button: true,
      selected: isChoice ? selected : null,
      inMutuallyExclusiveGroup: isChoice,
      child: Material(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(Rounded.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Rounded.md),
          // The app's stitch, as on every selected tile.
          child: DashedBorder(
            radius: Rounded.md,
            color: selected ? colors.primary : colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: BadgeRow(
                badge: Container(
                  width: BadgeSize.lg,
                  height: BadgeSize.lg,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  // Selected: `onPrimary` on `primary`; unselected: muted on a neutral fill.
                  // A symbol shrinks to stay inside the disc with large text.
                  child: symbolText != null
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            symbolText!,
                            style: context.headlineMdStrong.copyWith(
                              color: selected
                                  ? colors.onPrimary
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Icon(
                          icon,
                          size: IconSize.lg,
                          color: selected
                              ? colors.onPrimary
                              : colors.onSurfaceVariant,
                        ),
                ),
                trailing: !isChoice
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(left: Spacing.sm),
                        child: selected
                            ? Container(
                                width: BadgeSize.xs,
                                height: BadgeSize.xs,
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
                            : Icon(
                                AppIcons.radioUnselected,
                                size: BadgeSize.xs,
                                // An unpicked option's ring: 3:1 for a state (WCAG 1.4.11).
                                color: colors.onSurfaceVariant,
                              ),
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WholeWordsText(
                      label,
                      style: context.bodyMdBold.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
