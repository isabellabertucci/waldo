import 'package:flutter/material.dart';
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
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
      child: Icon(icon, size: IconSize.md, color: color),
    );
  }
}

/// A field row that opens its own picker (Category, Date, Wallet) - icon
/// badge plus label/value in its own card, with a trailing chevron.
/// [hasError] outlines the card in the error color when the field is
/// required but still empty.
class EditFieldRow extends StatelessWidget {
  const EditFieldRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.hasError = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.surfaceContainer,
      borderRadius: BorderRadius.circular(Rounded.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(Rounded.lg),
        onTap: onTap,
        child: Container(
          decoration: hasError
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
                      style: context.bodyMdBold,
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
