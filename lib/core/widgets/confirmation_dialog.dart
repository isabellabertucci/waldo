import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/tinted_circle_badge.dart';
import 'package:waldo/core/widgets/pill_button.dart';
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
    final accent = colors.negative;
    // As Flutter's AlertDialog: Android announces it as an alert; iOS lands
    // on the title.
    // The same buttons as everywhere: no size or type of their own.
    final cancel = PillButton(
      variant: PillButtonVariant.secondary,
      label: l10n.cancel,
      onPressed: () => Navigator.of(context).pop(false),
    );
    final confirm = PillButton(
      variant: PillButtonVariant.destructive,
      label: confirmLabel,
      onPressed: () => Navigator.of(context).pop(true),
    );
    final routeLabel = switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => null,
      _ => MaterialLocalizations.of(context).alertDialogLabel,
    };

    return Dialog(
      backgroundColor: colors.sheet,
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
              TintedCircleBadge(icon: icon, color: accent),
              const SizedBox(height: Spacing.sm),
              Semantics(
                container: true,
                child: WholeWordsText(
                  title,
                  textAlign: TextAlign.center,
                  style: context.titlePage.copyWith(color: colors.ink),
                ),
              ),
              const SizedBox(height: Spacing.xs),
              WholeWordsText(
                content,
                textAlign: TextAlign.center,
                style: context.body.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: Spacing.lg),
              // One button in two variants, so they match in size. At
              // accessibility sizes they stack, confirm first, as iOS
              // alerts do.
              if (DynamicTypeScaler.isAccessibilitySize(context))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.sm,
                  children: [confirm, cancel],
                )
              else
                Row(
                  children: [
                    Expanded(child: cancel),
                    const SizedBox(width: Spacing.sm),
                    Expanded(child: confirm),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
