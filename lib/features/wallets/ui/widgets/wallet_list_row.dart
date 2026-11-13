import 'package:flutter/material.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/badge_row.dart';
import 'package:waldo/core/widgets/balance_amount.dart';
import 'package:waldo/core/widgets/leather_wallet.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../models/wallet.dart';
import '../../wallets_x.dart';

/// One wallet in the list, on a card of its own: its leather, name and how
/// it stands, then its balance. A tap opens it; a long press edits or
/// deletes it.
class WalletListRow extends StatelessWidget {
  const WalletListRow({
    super.key,
    required this.wallet,
    required this.finish,
    required this.positiveTotal,
    required this.currency,
    required this.isBalanceHidden,
    required this.onTap,
    required this.onLongPress,
  });

  final Wallet wallet;
  final LeatherFinish finish;

  /// Every wallet in the black, summed: what a wallet's share is of.
  final int positiveTotal;
  final Currency currency;
  final bool isBalanceHidden;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final balance = wallet.currentBalance;
    final amountColor = switch (balance) {
      > 0 => colors.positive,
      < 0 => colors.negative,
      // Nothing in it: quiet, so the wallets with money stand out.
      _ => colors.inkMuted,
    };
    final amount = BalanceAmount(
      amount: formatSignedCents(
        balance,
        locale: moneyLocale(context),
        currencyCode: currency.code,
      ),
      hidden: isBalanceHidden,
      style: context.amountRow.copyWith(color: amountColor),
    );
    final stacked = DynamicTypeScaler.isAccessibilitySize(context);
    final muted = colors.inkMuted;

    return Semantics(
      button: true,
      onLongPressHint: l10n.walletActionsHint,
      child: Material(
        color: colors.card,
        borderRadius: BorderRadius.circular(Rounded.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.sm),
            child: BadgeRow(
              badge: LeatherWalletThumb(finish: finish),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WholeWordsText.singleLine(
                          wallet.name,
                          style: context.bodyStrong,
                        ),
                        // No type: the group's heading above says it.
                        Text(
                          _standing(l10n, balance),
                          style: context.label.copyWith(color: muted),
                        ),
                        // With large text the balance moves under the name.
                        if (stacked)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: amount,
                          ),
                      ],
                    ),
                  ),
                  if (!stacked) ...[const SizedBox(width: Spacing.sm), amount],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// In the red, empty, or its share of what's in the black.
  String _standing(AppLocalizations l10n, int balance) {
    if (balance < 0) return l10n.walletStatusNegative;
    return switch (positiveShareLabel(balance, positiveTotal)) {
      final share? => l10n.walletStatusShare(share),
      null => l10n.walletStatusEmpty,
    };
  }
}
