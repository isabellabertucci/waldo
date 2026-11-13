import 'package:flutter/material.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/balance_amount.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// "Total balance" over the page's hero amount, its cents muted: the whole
/// units are what's read first (DESIGN.md "Layout").
class HeroBalance extends StatelessWidget {
  const HeroBalance({
    super.key,
    required this.cents,
    required this.currency,
    required this.hidden,
  });

  final int cents;
  final Currency currency;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final locale = moneyLocale(context);
    final amount = formatCents(
      cents,
      locale: locale,
      currencyCode: currency.code,
    );
    final separator = amount.lastIndexOf(decimalSeparator(locale));
    final richAmount = separator < 0
        ? null
        : TextSpan(
            children: [
              TextSpan(text: amount.substring(0, separator)),
              TextSpan(
                text: amount.substring(separator, separator + 3),
                style: TextStyle(color: colors.inkMuted),
              ),
              TextSpan(text: amount.substring(separator + 3)),
            ],
          );

    // One stop for screen readers: "Total balance, 3 458,00 €".
    return MergeSemantics(
      child: Column(
        children: [
          Text(
            l10n.totalBalance,
            style: context.bodyStrong.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: Spacing.xxs),
          // A long balance shrinks rather than being cut.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: BalanceAmount(
              amount: amount,
              richAmount: richAmount,
              hidden: hidden,
              style: context.amountHero.copyWith(color: colors.ink),
              alignment: AlignmentDirectional.center,
            ),
          ),
        ],
      ),
    );
  }
}
