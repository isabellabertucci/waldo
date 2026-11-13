import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/badge_row.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/field_label.dart';

/// The small icon circle leading a field row in the transaction sheets.
class FieldBadge extends StatelessWidget {
  const FieldBadge({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: BadgeSize.md,
      height: BadgeSize.md,
      decoration: BoxDecoration(color: colors.sheet, shape: BoxShape.circle),
      child: Icon(icon, size: IconSize.md, color: color),
    );
  }
}

/// A row that opens a picker: icon, its name, the value at the end and a
/// chevron. Rows sit together in [EditFieldRow.group]'s card.
class EditFieldRow extends StatelessWidget {
  const EditFieldRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.hasError = false,
    this.required = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  /// Shows the value in `error`: a required field left empty.
  final bool hasError;

  /// Marks the label with " *".
  final bool required;

  /// [rows] in one `surfaceContainer` card, like the pills around it, with
  /// hairlines that start under the names, not the icons.
  static Widget group(BuildContext context, List<Widget> rows) {
    final colors = context.appColors;

    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(Rounded.lg),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                indent: DynamicTypeScaler.isAccessibilitySize(context)
                    ? Spacing.md
                    : Spacing.md + BadgeSize.md + Spacing.sm,
              ),
            rows[i],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final name = FieldLabel(
      label,
      required: required,
      style: context.body.copyWith(color: colors.inkMuted),
    );
    final valueText = WholeWordsText.singleLine(
      value,
      style: context.bodyStrong.copyWith(
        color: hasError ? colors.negative : colors.ink,
      ),
    );

    // A button to screen readers: it opens a picker.
    return Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            // As far in as the pills' discs, so the icons line up.
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.component,
            ),
            child: BadgeRow(
              badge: FieldBadge(icon: icon, color: colors.inkMuted),
              trailing: Padding(
                padding: const EdgeInsets.only(left: Spacing.xs),
                child: Icon(
                  AppIcons.chevronRight,
                  size: IconSize.lg,
                  // Says the row opens a picker: 3:1 at least (WCAG 1.4.11).
                  color: colors.inkMuted,
                ),
              ),
              // With large text the value moves under the name, so neither
              // is squeezed.
              child: DynamicTypeScaler.isAccessibilitySize(context)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [name, valueText],
                    )
                  : Row(
                      children: [
                        name,
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: valueText,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
