import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/secondary_button.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// What couldn't load, and a button to try again, so a failed screen is
/// never a dead end (DESIGN.md "Errors").
class LoadError extends StatelessWidget {
  const LoadError({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.pageMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.body.copyWith(color: context.appColors.inkMuted),
            ),
            const SizedBox(height: Spacing.sm),
            SecondaryButton(label: l10n.tryAgain, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
