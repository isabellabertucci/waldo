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

import 'package:waldo/core/widgets/eye_icon.dart';

/// How far the credit-card layer peeks above the main balance card's own
/// top edge. The widget has to reserve this space itself (the peek uses a
/// negative `Positioned` offset + `Clip.none`), rather than relying on the
/// caller to guess the right gap above it in the page.
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

  /// The name shown on the card peeking out behind the main one - a real
  /// wallet, not a generic "Credit Card" label, so it reads as "there's
  /// more behind this" rather than a decorative prop. Unused (and may be
  /// null) when [walletCount] is zero, since the peek becomes a "create a
  /// wallet" placeholder instead.
  final String? peekWalletName;

  /// Opens wallet creation - only wired up (and only ever tapped) when
  /// [walletCount] is zero, where the peek card itself is the empty-state
  /// call to action instead of a separate dedicated welcome screen.
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
        : formatCents(totalBalance, currencyCode: currencyCode);

    return Padding(
      padding: const EdgeInsets.only(top: _cardPeek),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // A real second card peeking out behind the main one - either
          // another wallet's name + month/year, or (with no wallets yet) a
          // dashed placeholder that doubles as the empty state's call to
          // action. Fixed height (taller than the peek itself) so rounded
          // bottom corners tuck out of sight behind the front card instead
          // of collapsing to content size and vanishing entirely.
          Positioned(
            top: -_cardPeek,
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
                              // Always the first wallet's card, which
                              // always gets the platinum finish (index 0
                              // in the wallet stack's own cycle).
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
                                        // Part of the wallet card's debossed
                                        // "ink" treatment (walletCardInkColor
                                        // + walletCardTextShadow below) - its
                                        // own letterSpacing/shadow pairing,
                                        // not a named type-scale step.
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.lg,
              Spacing.md,
              Spacing.md,
            ),
            decoration: ShapeDecoration(
              gradient: pouchGradient(colors.leather),
              // Leather grain, layered on top of the gradient and clipped to
              // the pouch's own silhouette automatically (that's what
              // `ShapeDecoration.image` + a custom `shape` already does -
              // no manual ClipPath/extra Stack needed, which is what broke
              // the card's sizing last time).
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
                  Row(
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
                      const Spacer(),
                      Tooltip(
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
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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

/// The empty-state's call to action, doubling as the "peek" card - dashed
/// outline (nothing filled yet) rather than a solid tinted card, since
/// there's no second wallet behind the main one to represent.
class _EmptyPeekCard extends StatelessWidget {
  const _EmptyPeekCard({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(Rounded.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Rounded.lg),
        child: Container(
          height: _cardPeek + 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Rounded.lg),
          ),
          child: CustomPaint(
            painter: _DashedRRectPainter(
              color: colors.onSurface.withValues(alpha: 0.3),
              radius: Rounded.lg,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.sm,
                Spacing.md,
                0,
              ),
              // A plain Row here would get stretched (and so vertically
              // centered) across this card's full height, including the
              // lower portion that's hidden behind the front card - a
              // Column with `start` alignment is what actually pins it to
              // the top of the visible sliver instead.
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
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const _dashLength = 4.0;
  static const _gapLength = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + _dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}
