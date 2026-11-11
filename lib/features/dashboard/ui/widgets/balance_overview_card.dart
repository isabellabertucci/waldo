import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/elevation.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/motion.dart';
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

import 'package:waldo/core/widgets/balance_amount.dart';

class BalanceOverviewCard extends StatelessWidget {
  const BalanceOverviewCard({
    super.key,
    required this.totalBalance,
    required this.currency,
    required this.isBalanceHidden,
    required this.cardMonthLabel,
    required this.walletCount,
    this.peekWalletNames = const [],
    this.onCreateWallet,
    required this.onAddPressed,
    required this.onToggleBalanceHidden,
    this.landing = false,
  });

  final int totalBalance;
  final Currency currency;
  final bool isBalanceHidden;
  final String cardMonthLabel;
  final int walletCount;

  /// The names of the wallets whose cards peek out of the pouch, newest
  /// first: the newest in front with its name, each older one only an edge
  /// a step higher behind it. Up to [maxPeekCards]; empty with no wallets.
  final List<String> peekWalletNames;

  /// As many cards as the pouch shows.
  static const maxPeekCards = 3;

  /// Opens wallet creation; only used when [walletCount] is zero.
  final VoidCallback? onCreateWallet;
  final VoidCallback onAddPressed;
  final VoidCallback onToggleBalanceHidden;

  /// The front card is a wallet just made: it drops into the pouch.
  final bool landing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final currencyCode = currency.code;
    final isEmpty = walletCount == 0;

    final balanceText = formatCents(
      totalBalance,
      locale: moneyLocale(context),
      currencyCode: currencyCode,
    );

    // With reduce motion on, the card is simply there.
    final landing = this.landing && !context.reduceMotion;
    final names = peekWalletNames.take(maxPeekCards).toList();
    // The front card's peek, plus a step for each older card behind it.
    final peek =
        ComponentSize.balancePeek +
        ComponentSize.balancePeekStep * math.max(0, names.length - 1);
    const step = ComponentSize.balancePeekStep;
    final fall = context.motion(Motion.cardFall);
    // As a new card drops in front, the ones already there make room: with
    // the pouch full they rise a step and the oldest goes behind them;
    // otherwise they stay and the pouch slides down a step under them.
    final rise = landing && walletCount > maxPeekCards;
    final grow = landing && !rise && names.length > 1;

    // Not clipped: a landing card falls in from above.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // The first wallet's card replaces the "create a wallet" slot, which
        // fades away under it.
        if (landing && walletCount == 1)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                widthFactor: 0.88,
                child: const IgnorePointer(
                  child: _EmptyPeekCard(onTap: null),
                ).animate().fadeOut(duration: context.motion(Motion.cardFall)),
              ),
            ),
          ),
        // With no wallets, a "create a wallet" placeholder peeks out instead.
        // Kept inside the Stack's bounds, or taps on it are never delivered.
        if (isEmpty)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                widthFactor: 0.88,
                child: _EmptyPeekCard(onTap: onCreateWallet),
              ),
            ),
          ),
        // The card that was oldest, going behind the ones rising over it.
        if (rise)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                widthFactor: 0.88,
                child: _PeekCard(
                  finish: WalletCardFinish.fromIndex(maxPeekCards),
                  height: peek + ComponentSize.balancePeekTuck,
                  label: null,
                  shaded: false,
                ).animate().fadeOut(duration: fall),
              ),
            ),
          ),
        // The newest wallets' cards, oldest at the back and highest, the
        // newest in front; each reaches down behind the pouch so its corners
        // hide there. Only the front one is named: the others are just edges.
        for (var i = names.length - 1; i >= 0; i--)
          Positioned(
            top: ComponentSize.balancePeekStep * (names.length - 1 - i),
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                widthFactor: 0.88,
                child: _CardDrop(
                  // Only the newest, in front, is ever the one just made.
                  landing: landing && i == 0,
                  child: _Rise(
                    rising: rise && i > 0,
                    child: _PeekCard(
                      // Each wallet's finish, as on the Wallets screen.
                      finish: WalletCardFinish.fromIndex(i),
                      height:
                          peek -
                          step * (names.length - 1 - i) +
                          ComponentSize.balancePeekTuck,
                      // The card that was in front keeps its name only while
                      // it fades, as the new one covers it.
                      label: i == 0 || (landing && i == 1)
                          ? (names[i], cardMonthLabel)
                          : null,
                      labelLeaving: landing && i == 1,
                      shaded: i != names.length - 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        // With no wallets the placeholder takes the front card's place.
        TweenAnimationBuilder<double>(
          tween: Tween(
            begin: grow ? peek - step : null,
            end: isEmpty ? ComponentSize.balancePeek : peek,
          ),
          duration: fall,
          curve: Motion.emphasizedCurve,
          builder: (context, top, child) => Padding(
            padding: EdgeInsets.only(top: top),
            child: child,
          ),
          child: _PouchSquash(
            landing: landing,
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
                      color: colors.onLeather.withValues(alpha: Alpha.strong),
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  // A whole balance shrinks rather than breaking or being cut.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: BalanceAmount(
                      amount: balanceText,
                      hidden: isBalanceHidden,
                      style: context.headlineDisplayBlack.copyWith(
                        color: colors.onLeather,
                      ),
                    ),
                  ),
                  if (isEmpty) ...[
                    const SizedBox(height: Spacing.lg),
                    Text(
                      l10n.zeroWalletsLabel,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onLeather.withValues(alpha: Alpha.muted),
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
                                alpha: Alpha.soft,
                              ),
                              foregroundColor: colors.onLeather,
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.md,
                                vertical: Spacing.xs,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  Rounded.pill,
                                ),
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
                                  // The eye closes as the balance tucks away.
                                  child: AnimatedSwitcher(
                                    duration: context.motion(Motion.toggle),
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                    child: EyeIcon(
                                      key: ValueKey(isBalanceHidden),
                                      color: colors.onLeather,
                                      hidden: isBalanceHidden,
                                      size: IconSize.lg,
                                    ),
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
        ),
      ],
    );
  }
}

/// One wallet's card peeking out of the pouch. Only the front card has a
/// [label]; behind it, a card is just its edge.
class _PeekCard extends StatelessWidget {
  const _PeekCard({
    required this.finish,
    required this.height,
    required this.label,
    this.labelLeaving = false,
    required this.shaded,
  });

  final WalletCardFinish finish;
  final double height;

  /// The wallet's name and the month, on the front card.
  final (String name, String month)? label;

  /// The card has just stepped back from the front: its label fades out.
  final bool labelLeaving;

  /// Darkened along its top edge, where it overlaps the card behind.
  final bool shaded;

  @override
  Widget build(BuildContext context) {
    final ink = walletCardInkColor(context, alpha: Alpha.muted);

    return ClipRRect(
      borderRadius: BorderRadius.circular(Rounded.lg),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: WalletCardBackground(finish: finish)),
            if (shaded)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: ComponentSize.walletCardTopShade,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: Elevation.stackShade,
                    ),
                  ),
                ),
              ),
            if (label case (final name, final month))
              _LabelFade(
                leaving: labelLeaving,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          // The wallet card's engraved ink style, not a type-scale step.
                          style: context.bodySmStrong.copyWith(
                            color: ink,
                            letterSpacing: 0.2,
                            shadows: walletCardTextShadow,
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        month.toUpperCase(),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: ink,
                          letterSpacing: 0.6,
                          shadows: walletCardTextShadow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A card behind the front one rising a step into its new place, as a new
/// card drops in front of a full pouch.
class _Rise extends StatelessWidget {
  const _Rise({required this.rising, required this.child});

  final bool rising;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!rising) return child;
    return child.animate().moveY(
      begin: ComponentSize.balancePeekStep,
      end: 0,
      duration: context.motion(Motion.cardFall),
      curve: Motion.emphasizedCurve,
    );
  }
}

/// A card's label fading out as the card steps back from the front; gone
/// for screen readers at once, as the card it names is now behind.
class _LabelFade extends StatelessWidget {
  const _LabelFade({required this.leaving, required this.child});

  final bool leaving;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!leaving) return child;
    return ExcludeSemantics(
      child: child.animate().fadeOut(duration: context.motion(Motion.cardFall)),
    );
  }
}

/// The front card of a wallet just made, dropping into the pouch: it falls
/// in tilted, sinks a little too deep, then pops back up to rest.
class _CardDrop extends StatelessWidget {
  const _CardDrop({required this.landing, required this.child});

  final bool landing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!landing) return child;
    final fall = context.motion(Motion.cardFall);
    return child
        .animate()
        .fadeIn(duration: context.motion(Motion.cardDropFade))
        .moveY(
          begin: -Motion.cardDropHeight,
          end: Motion.cardSink,
          duration: fall,
          curve: Motion.cardFallCurve,
        )
        .rotate(begin: Motion.cardTilt, end: 0, duration: fall)
        .then()
        .moveY(
          begin: 0,
          end: -Motion.cardSink,
          duration: context.motion(Motion.cardSettle),
          curve: Motion.settleCurve,
        );
  }
}

/// The pouch giving a little as a landing card hits it, then springing back.
class _PouchSquash extends StatelessWidget {
  const _PouchSquash({required this.landing, required this.child});

  final bool landing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!landing) return child;
    return child
        .animate(delay: context.motion(Motion.cardFall))
        .scaleY(
          begin: 1,
          end: Motion.pouchSquashScale,
          duration: context.motion(Motion.pouchSquash),
          alignment: Alignment.bottomCenter,
        )
        .then()
        .scaleY(
          begin: 1,
          end: 1 / Motion.pouchSquashScale,
          duration: context.motion(Motion.pouchRebound),
          curve: Motion.settleCurve,
          alignment: Alignment.bottomCenter,
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
      color: colors.onLeather.withValues(alpha: Alpha.soft),
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
            height: ComponentSize.balancePeek + ComponentSize.balancePeekTuck,
            child: DashedBorder(
              radius: Rounded.lg,
              color: colors.onSurface.withValues(alpha: Alpha.stitch),
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
                          width: BadgeSize.xs,
                          height: BadgeSize.xs,
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
