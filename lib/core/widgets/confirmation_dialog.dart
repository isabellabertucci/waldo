import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/l10n/app_localizations.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmLabel,
    this.isDestructive = true,
  });

  final String title;
  final String content;
  final String confirmLabel;
  final bool isDestructive;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    bool isDestructive = true,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        isDestructive: isDestructive,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actionsPadding: const EdgeInsets.fromLTRB(
        Spacing.xl,
        0,
        Spacing.xl,
        Spacing.lg,
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: colors.surfaceContainer,
            foregroundColor: colors.onSurface,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Rounded.lg),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        const SizedBox(width: Spacing.sm),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: isDestructive ? colors.error : colors.primary,
            foregroundColor: isDestructive ? Colors.white : colors.onPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Rounded.lg),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
