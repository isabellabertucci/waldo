import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/dashed_circle_badge.dart';
import 'package:waldo/l10n/app_localizations.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmLabel,
    this.icon = AppIcons.delete,
  });

  final String title;
  final String content;
  final String confirmLabel;

  /// The badge's icon: what the confirm button loses.
  final IconData icon;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    IconData icon = AppIcons.delete,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        icon: icon,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    // Every confirmation here loses something (a delete, unsaved changes),
    // so it's always the error orange.
    final accent = colors.error;
    // As Flutter's AlertDialog: Android announces it as an alert; iOS lands
    // on the title.
    final routeLabel = switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => null,
      _ => MaterialLocalizations.of(context).alertDialogLabel,
    };

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Rounded.lg),
      ),
      // Scrolls when large text on a small phone outgrows the screen, so the
      // buttons stay reachable.
      child: Semantics(
        scopesRoute: routeLabel != null,
        explicitChildNodes: routeLabel != null,
        namesRoute: routeLabel != null,
        label: routeLabel,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DashedCircleBadge(icon: icon, color: accent),
              const SizedBox(height: Spacing.sm),
              Semantics(
                container: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.headlineSmBold.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                content,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: colors.surfaceContainer,
                        foregroundColor: colors.onSurface,
                        padding: const EdgeInsets.symmetric(
                          vertical: Spacing.component,
                        ),
                        textStyle: context.bodyMdBold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Rounded.pill),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: accent,
                        // No `onError` token yet; buttons use `onPrimary` on a filled background.
                        foregroundColor: colors.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: Spacing.component,
                        ),
                        textStyle: context.bodyMdBold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Rounded.pill),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
