import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/widgets/circle_icon_button.dart';
import 'package:waldo/core/widgets/eye_icon.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// The small eye that hides and shows amounts, for bars (the big one is an
/// action circle). Light green while amounts are hidden, as the circle is,
/// so it reads as switched on.
class HideAmountsButton extends StatelessWidget {
  const HideAmountsButton({
    super.key,
    required this.hidden,
    required this.onPressed,
  });

  final bool hidden;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    return Semantics(
      toggled: hidden,
      child: CircleIconButton(
        flat: true,
        // On the white bars it sits on, a card-grey disc shows it's a button.
        tint: hidden ? colors.accent : colors.card,
        tooltip: hidden ? l10n.showBalance : l10n.hideBalance,
        onPressed: onPressed,
        child: EyeIcon(
          color: hidden ? colors.onAccent : colors.ink,
          hidden: hidden,
          size: IconSize.lg,
        ),
      ),
    );
  }
}
