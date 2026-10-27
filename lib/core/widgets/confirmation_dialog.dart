import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/dashed_circle_badge.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// Room for "Cancelar" and "Descartar" side by side, at a 48px height.
const _buttonPadding = EdgeInsets.symmetric(
  horizontal: Spacing.xs,
  vertical: Spacing.sm,
);

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
                  style: context.headlineSmExtraBold.copyWith(
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
              // One button in two variants, so they match in size.
              Row(
                children: [
                  Expanded(
                    child: DashedStitchButton(
                      variant: StitchVariant.secondary,
                      label: l10n.cancel,
                      labelStyle: context.bodyMdBold,
                      padding: _buttonPadding,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: DashedStitchButton(
                      variant: StitchVariant.destructive,
                      label: confirmLabel,
                      labelStyle: context.bodyMdBold,
                      padding: _buttonPadding,
                      onPressed: () => Navigator.of(context).pop(true),
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
