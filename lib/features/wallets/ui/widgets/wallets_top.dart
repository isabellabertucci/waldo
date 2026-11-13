import 'package:flutter/material.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/action_circle.dart';
import 'package:waldo/core/widgets/eye_icon.dart';
import 'package:waldo/core/widgets/hero_balance.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../models/wallet.dart';

/// The wallets' beige top: their total, what's in the black and in the
/// red, and the three actions.
class WalletsTop extends StatelessWidget {
  const WalletsTop({
    super.key,
    required this.wallets,
    required this.currency,
    required this.isBalanceHidden,
    required this.isFilterOpen,
    required this.filterValue,
    required this.onToggleBalanceHidden,
    required this.onToggleFilter,
    required this.onNewWallet,
  });

  final List<Wallet> wallets;
  final Currency currency;
  final bool isBalanceHidden;
  final bool isFilterOpen;

  /// The type the list is filtered by, or null for all.
  final String? filterValue;
  final VoidCallback onToggleBalanceHidden;
  final VoidCallback onToggleFilter;
  final VoidCallback onNewWallet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final total = wallets.fold(0, (sum, w) => sum + w.currentBalance);
    final inBlack = wallets
        .where((w) => w.currentBalance > 0)
        .fold(0, (sum, w) => sum + w.currentBalance);
    final inRed = wallets
        .where((w) => w.currentBalance < 0)
        .fold(0, (sum, w) => sum + w.currentBalance);

    return Column(
      children: [
        HeroBalance(cents: total, currency: currency, hidden: isBalanceHidden),
        if (inBlack != 0 || inRed != 0) ...[
          const SizedBox(height: Spacing.component),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: [
              if (inBlack != 0)
                _TotalPill(
                  cents: inBlack,
                  currency: currency,
                  hidden: isBalanceHidden,
                  label: l10n.walletsInPositive,
                ),
              if (inRed != 0)
                _TotalPill(
                  cents: inRed,
                  currency: currency,
                  hidden: isBalanceHidden,
                  label: l10n.walletsInNegative,
                ),
            ],
          ),
        ],
        const SizedBox(height: Spacing.md),
        // The main action last, on the right (DESIGN.md "Action circles").
        Wrap(
          alignment: WrapAlignment.center,
          spacing: Spacing.component * 2 + Spacing.xxs,
          runSpacing: Spacing.sm,
          children: [
            ActionCircle(
              icon: EyeIcon(
                color: isBalanceHidden ? colors.onAccent : colors.ink,
                hidden: isBalanceHidden,
                size: IconSize.xl,
              ),
              label: l10n.actionHide,
              // On while amounts are hidden, like the Filter action.
              selected: isBalanceHidden,
              // Nothing to hide or filter before the first wallet.
              onPressed: wallets.isEmpty ? null : onToggleBalanceHidden,
            ),
            ActionCircle(
              key: const Key('walletsFilterAction'),
              icon: const Icon(AppIcons.filter, size: IconSize.xl),
              label: l10n.actionFilter,
              onPressed: wallets.isEmpty ? null : onToggleFilter,
              selected: isFilterOpen,
              marked: filterValue != null,
              value: filterValue,
            ),
            ActionCircle(
              key: const Key('newWalletAction'),
              icon: const Icon(AppIcons.add, size: IconSize.xl),
              label: l10n.newWallet,
              onPressed: onNewWallet,
              isMain: true,
            ),
          ],
        ),
      ],
    );
  }
}

/// The sum in the black (green) or in the red (red text on white) - never a
/// red background, as on Home.
class _TotalPill extends StatelessWidget {
  const _TotalPill({
    required this.cents,
    required this.currency,
    required this.hidden,
    required this.label,
  });

  final int cents;
  final Currency currency;
  final bool hidden;

  /// Says what the amount is ("In the black: +€8,280.56"), on screen and
  /// to screen readers alike.
  final String Function(String amount) label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isRed = cents < 0;
    final amount = hidden
        ? hiddenAmount
        : formatSignedCents(
            cents,
            locale: moneyLocale(context),
            currencyCode: currency.code,
          );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.component,
        vertical: Spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isRed ? colors.chip : colors.accent,
        borderRadius: BorderRadius.circular(Rounded.pill),
      ),
      child: Text(
        label(amount),
        style: context.label.copyWith(
          color: isRed ? colors.negative : colors.onAccent,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
