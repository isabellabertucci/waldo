import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/pouch_shape.dart';
import 'package:waldo/core/widgets/wallet_card_finish.dart';
import 'package:waldo/l10n/app_localizations.dart';

import 'package:waldo/core/widgets/dashed_border.dart';
import 'package:waldo/core/widgets/eye_icon.dart';
import 'package:waldo/core/widgets/min_tap_target.dart';

/// How far the card behind peeks above the balance card; reserved here.
const _cardPeek = 44.0;

class BalanceOverviewCard extends StatelessWidget {
  const BalanceOverviewCard({
    super.key,
    required this.totalBalance,
    required this.currency,
    required this.isBalanceHidden,
    required this.cardMonthLabel,
    required this.walletCount,
    this.peekWalletName,
    this.onCreateWallet,
    required this.onAddPressed,
    required this.onToggleBalanceHidden,
  });

  final int totalBalance;
  final Currency currency;
  final bool isBalanceHidden;
  final String cardMonthLabel;
  final int walletCount;

  /// The wallet name on the card peeking out behind. Unused with no wallets.
  final String? peekWalletName;

  /// Opens wallet creation; only used when [walletCount] is zero.
  final VoidCallback? onCreateWallet;
  final VoidCallback onAddPressed;
  final VoidCallback onToggleBalanceHidden;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final currencyCode = currency.code;
    final isEmpty = walletCount == 0;

    final balanceText = isBalanceHidden
        ? hiddenAmount
        : formatCents(
            totalBalance,
            locale: moneyLocale(context),
            currencyCode: currencyCode,
          );

    return Stack(
      children: [
        // The card peeking out behind: another wallet, or a "create a wallet"
        // placeholder. Taller than the peek so its corners hide behind the front card.
        // Kept inside the Stack's bounds, or taps on it are never delivered.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              widthFactor: 0.88,
              child: isEmpty
                  ? _EmptyPeekCard(onTap: onCreateWallet)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(Rounded.lg),
                      child: SizedBox(
                        height: _cardPeek + 24,
                        child: Stack(
                          children: [
                            // The first wallet, which always gets the platinum finish.
                            const Positioned.fill(
                              child: WalletCardBackground(
                                finish: WalletCardFinish.platinum,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.md,
                                vertical: Spacing.sm,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      peekWalletName ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      // The wallet card's engraved ink style, not a type-scale step.
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                            color: walletCardInkColor(
                                              context,
                                              alpha: 0.6,
                                            ),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                            shadows: walletCardTextShadow,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: Spacing.sm),
                                  Text(
                                    cardMonthLabel.toUpperCase(),
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(
                                          color: walletCardInkColor(
                                            context,
                                            alpha: 0.6,
                                          ),
                                          letterSpacing: 0.6,
                                          shadows: walletCardTextShadow,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: _cardPeek),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.lg,
              Spacing.md,
              Spacing.md,
            ),
            decoration: ShapeDecoration(
              gradient: pouchGradient(colors.leather),
              // Leather grain over the gradient, clipped to the pouch shape.
              image: const DecorationImage(
                image: AssetImage('assets/textures/leather.png'),
                fit: BoxFit.cover,
                opacity: 0.85,
              ),
              shape: PouchBorder(stitchColor: colors.onLeather),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.totalBalance,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onLeather.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  balanceText,
                  style: context.headlineDisplayStrong.copyWith(
                    color: colors.onLeather,
                  ),
                ),
                if (isEmpty) ...[
                  const SizedBox(height: Spacing.lg),
                  Text(
                    l10n.zeroWalletsLabel,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onLeather.withValues(alpha: 0.6),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: Spacing.md),
                  // One at each end; with large text the eye wraps below
                  // instead of overflowing.
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: Spacing.xs,
                      children: [
                        TextButton.icon(
                          onPressed: onAddPressed,
                          style: TextButton.styleFrom(
                            backgroundColor: colors.onLeather.withValues(
                              alpha: 0.15,
                            ),
                            foregroundColor: colors.onLeather,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.md,
                              vertical: Spacing.xs,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Rounded.pill),
                            ),
                          ),
                          icon: const Icon(AppIcons.add, size: IconSize.lg),
                          label: Text(l10n.add),
                        ),
                        // Its own node (container, outside the tooltip): name,
                        // role and tap together, apart from the card's text.
                        Semantics(
                          container: true,
                          button: true,
                          child: MinTapTarget(
                            onTap: onToggleBalanceHidden,
                            child: Tooltip(
                              message: isBalanceHidden
                                  ? l10n.showBalance
                                  : l10n.hideBalance,
                              child: _RoundIconButton(
                                onPressed: onToggleBalanceHidden,
                                child: EyeIcon(
                                  color: colors.onLeather,
                                  hidden: isBalanceHidden,
                                  size: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A subtle tinted circle around the eye toggle, so it reads as a tappable
/// control sitting on the card rather than a bare icon floating on it.
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.onPressed, required this.child});

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.onLeather.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(padding: const EdgeInsets.all(Spacing.xs), child: child),
      ),
    );
  }
}

/// The empty state's call to action, in place of the peeking card.
class _EmptyPeekCard extends StatelessWidget {
  const _EmptyPeekCard({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    // Its own button to screen readers (a bare InkWell is only read as its
    // text), apart from the balance card in front.
    return Semantics(
      container: true,
      button: true,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Rounded.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Rounded.lg),
          child: SizedBox(
            height: _cardPeek + 24,
            child: DashedBorder(
              radius: Rounded.lg,
              color: colors.onSurface.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.sm,
                  Spacing.md,
                  0,
                ),
                // A Column, so the content sits at the top of the visible part of the card.
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: colors.leather,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            AppIcons.add,
                            size: IconSize.sm,
                            color: colors.onLeather,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Flexible(
                          child: Text(
                            l10n.firstRunPeekCta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.bodySmBold.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
