import 'package:flutter/material.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

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
      decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
      child: Icon(icon, size: IconSize.md, color: color),
    );
  }
}

/// A field row that opens a picker: icon, label/value and a chevron.
/// With [grouped] it sits inside a shared card instead of its own.
class EditFieldRow extends StatelessWidget {
  const EditFieldRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.hasError = false,
    this.grouped = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool hasError;
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = grouped ? null : BorderRadius.circular(Rounded.lg);

    return Material(
      color: grouped ? colors.transparent : colors.surfaceContainer,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          decoration: hasError && !grouped
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(Rounded.lg),
                  border: Border.all(color: colors.error, width: 1.5),
                )
              : null,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          child: Row(
            children: [
              FieldBadge(icon: icon, color: colors.onSurfaceVariant),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: hasError && grouped
                          ? context.bodyMdBold.copyWith(color: colors.error)
                          : context.bodyMdBold,
                    ),
                  ],
                ),
              ),
              Icon(
                AppIcons.chevronRight,
                size: IconSize.lg,
                color: colors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
