import 'package:flutter/material.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/balance_amount.dart';
import 'package:waldo/core/widgets/heading.dart';
import 'package:waldo/core/widgets/leather_wallet.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../models/wallet.dart';
import '../../wallets_x.dart';

/// What a wallet's leather shows on its face (DESIGN.md "Wallets"): its
/// name and type hot-stamped at the top, its balance at the bottom. Home's stack and the
/// wallet's own screen both use it, inside a [LeatherWallet].
class WalletFace extends StatelessWidget {
  const WalletFace({
    super.key,
    required this.wallet,
    required this.finish,
    required this.currency,
    required this.isBalanceHidden,
    this.isTitle = false,
  });

  final Wallet wallet;
  final LeatherFinish finish;
  final Currency currency;
  final bool isBalanceHidden;

  /// The name is the screen's title, for screen readers (the wallet's own
  /// screen).
  final bool isTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Any enlarged text: the leather keeps its size, so its words shrink to
    // fit it, as amounts do.
    final large = MediaQuery.textScalerOf(context).scale(1) > 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: large ? MainAxisSize.min : MainAxisSize.max,
          children: [
            // Name and type, hot-stamped into the leather.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Heading(
                  enabled: isTitle,
                  child: WholeWordsText.singleLine(
                    wallet.name,
                    style: context.titleSection.copyWith(
                      color: finish.debossInk(),
                      shadows: finish.deboss,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.xxs),
                WholeWordsText.singleLine(
                  wallet.type.label(l10n).toUpperCase(),
                  style: context.overline.copyWith(
                    color: finish.debossInk(small: true),
                    shadows: finish.deboss,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.walletBalanceLabel,
                  style: context.label.copyWith(
                    color: finish.ink.withValues(alpha: Alpha.strong),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: BalanceAmount(
                    amount: formatSignedCents(
                      wallet.currentBalance,
                      locale: moneyLocale(context),
                      currencyCode: currency.code,
                    ),
                    hidden: isBalanceHidden,
                    style: context.amountWallet.copyWith(
                      color: finish.amountColor(wallet.currentBalance),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
        if (!large) return content;
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(width: constraints.maxWidth, child: content),
        );
      },
    );
  }
}
