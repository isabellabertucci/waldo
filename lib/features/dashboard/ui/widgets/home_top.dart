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

/// Home's beige top: the total balance, its change this month, and the three
/// actions (DESIGN.md "Layout": the balance and actions live on top, the
/// detail on the sheet below).
class HomeTop extends StatelessWidget {
  const HomeTop({
    super.key,
    required this.totalBalance,
    required this.monthChange,
    required this.monthLabel,
    required this.currency,
    required this.isBalanceHidden,
    required this.onToggleBalanceHidden,
    required this.onNewWallet,
    required this.onNewTransaction,
    this.hasWallets = true,
  });

  final int totalBalance;

  /// The month's income minus expense; null hides the pill (nothing yet).
  final int? monthChange;

  /// The month the change is for, or null for this month.
  final String? monthLabel;
  final Currency currency;
  final bool isBalanceHidden;
  final VoidCallback onToggleBalanceHidden;
  final VoidCallback onNewWallet;
  final VoidCallback onNewTransaction;

  /// Before the first wallet, creating one is the main action and the
  /// others wait, greyed out, in their places.
  final bool hasWallets;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    return Column(
      children: [
        HeroBalance(
          cents: totalBalance,
          currency: currency,
          hidden: isBalanceHidden,
        ),
        const SizedBox(height: Spacing.component),
        if (monthChange case final change?)
          _ChangePill(
            change: change,
            monthLabel: monthLabel,
            currency: currency,
            hidden: isBalanceHidden,
          )
        else
          // Nothing moved yet: a quiet pill, so the top keeps its shape.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.component,
              vertical: Spacing.xxs,
            ),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(Rounded.pill),
            ),
            child: Text(
              l10n.noActivityYet,
              textAlign: TextAlign.center,
              style: context.label.copyWith(color: colors.inkMuted),
            ),
          ),
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
              onPressed: hasWallets ? onToggleBalanceHidden : null,
            ),
            ActionCircle(
              icon: const Icon(AppIcons.wallets, size: IconSize.xl),
              label: l10n.newWallet,
              onPressed: onNewWallet,
              isMain: !hasWallets,
            ),
            ActionCircle(
              icon: const Icon(AppIcons.add, size: IconSize.xl),
              label: l10n.actionTransaction,
              onPressed: hasWallets ? onNewTransaction : null,
              isMain: hasWallets,
            ),
          ],
        ),
      ],
    );
  }
}

/// The month's change: green on a gain, a quiet card with red text on a loss
/// - never a red background.
class _ChangePill extends StatelessWidget {
  const _ChangePill({
    required this.change,
    required this.monthLabel,
    required this.currency,
    required this.hidden,
  });

  final int change;
  final String? monthLabel;
  final Currency currency;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final isLoss = change < 0;
    final amount = hidden
        ? hiddenAmount
        : formatSignedCents(
            change,
            locale: moneyLocale(context),
            currencyCode: currency.code,
          );
    final signed = '${isLoss ? '▼' : '▲'} $amount';
    final text = switch (monthLabel) {
      final month? => l10n.monthChangeInMonth(signed, month),
      null => l10n.monthChangeThisMonth(signed),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.component,
        vertical: Spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isLoss ? colors.card : colors.accent,
        borderRadius: BorderRadius.circular(Rounded.pill),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.label.copyWith(
          color: isLoss ? colors.negative : colors.onAccent,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
