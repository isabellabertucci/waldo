import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/wallet_card_finish.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/widgets/min_tap_target.dart';

import '../../models/wallet.dart';
import '../../wallets_x.dart';

const _cardHeight = 187.0;

const _overlapHeightFactor = 124 / 170;

enum _CardAction { edit, delete }

class WalletsCardStack extends StatelessWidget {
  const WalletsCardStack({
    super.key,
    required this.wallets,
    required this.currency,
    required this.isBalanceHidden,
    required this.keptPercent,
    required this.onTapWallet,
    required this.onEditWallet,
    required this.onDeleteWallet,
  });

  final List<Wallet> wallets;
  final Currency currency;
  final bool isBalanceHidden;
  final double? keptPercent;
  final ValueChanged<Wallet> onTapWallet;
  final ValueChanged<Wallet> onEditWallet;
  final ValueChanged<Wallet> onDeleteWallet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final n = wallets.length;
    final totalBalance = wallets.fold<int>(
      0,
      (sum, w) => sum + w.currentBalance,
    );
    final totalText = isBalanceHidden
        ? hiddenAmount
        : formatCents(
            totalBalance,
            locale: moneyLocale(context),
            currencyCode: currency.code,
          );
    final roundedPercent = keptPercent?.round();
    final isOverspent = roundedPercent != null && roundedPercent < 0;
    final captionText = switch (roundedPercent) {
      null => l10n.walletsCountLabel(n),
      final p when p < 0 => l10n.overspentPercentThisMonth('${-p}%'),
      final p => l10n.keptPercentThisMonth('$p%'),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.pageMargin,
        Spacing.lg,
        Spacing.pageMargin,
        Spacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // One stop for screen readers, in reading order: "Total balance,
          // Kept 98% …, $3,458.00".
          MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wrap, not Row: with large text the caption drops under the label.
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: Spacing.sm,
                    children: [
                      Text(
                        l10n.totalBalance,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        captionText,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: isOverspent
                              ? colors.error
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  totalText,
                  style: context.headlineSmBold.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Column(
            children: List.generate(n, (index) {
              final wallet = wallets[index];
              final isLastCard = index == n - 1;
              return Align(
                alignment: Alignment.topCenter,
                heightFactor: isLastCard ? 1.0 : _overlapHeightFactor,
                child: SizedBox(
                  height: _cardHeight,
                  width: double.infinity,
                  child: _WalletCard(
                    key: Key('walletCard_${wallet.id}'),
                    wallet: wallet,
                    currency: currency,
                    isBalanceHidden: isBalanceHidden,
                    finish: WalletCardFinish.fromIndex(index),
                    showSeamTab: !isLastCard,
                    onTap: () => onTapWallet(wallet),
                    onEdit: () => onEditWallet(wallet),
                    onDelete: () => onDeleteWallet(wallet),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    super.key,
    required this.wallet,
    required this.currency,
    required this.isBalanceHidden,
    required this.finish,
    required this.showSeamTab,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Wallet wallet;
  final Currency currency;
  final bool isBalanceHidden;
  final WalletCardFinish finish;
  final bool showSeamTab;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isNegative = wallet.currentBalance < 0;
    final balanceText = isBalanceHidden
        ? hiddenAmount
        : formatCents(
            wallet.currentBalance,
            locale: moneyLocale(context),
            currencyCode: currency.code,
          );

    return Material(
      borderRadius: BorderRadius.circular(Rounded.lg),
      clipBehavior: Clip.antiAlias,
      elevation: 3,

      child: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: 'walletCardBg_${wallet.id}',
              child: WalletCardBackground(finish: finish),
            ),
          ),

          // A soft shadow along the top edge, for depth where the cards overlap.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 28,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    // one-off: a shadow cast over the card stack - shadows
                    // stay black in both themes, like Elevation's.
                    colors: [
                      Colors.black.withValues(alpha: 0.16),
                      Colors.black.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (showSeamTab)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 36,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: Spacing.xs),
                  decoration: BoxDecoration(
                    color: walletCardInkColor(context, alpha: 0.3),
                    borderRadius: BorderRadius.circular(Rounded.pill),
                  ),
                ),
              ),
            ),
          // Fill the card, so a tap anywhere on it opens the wallet, not just on the text.
          Positioned.fill(
            child: Semantics(
              button: true,
              child: InkWell(
                onTap: onTap,
                splashColor: walletCardInkColor(context, alpha: 0.12),
                highlightColor: walletCardInkColor(context, alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.sm,
                    Spacing.md,
                    Spacing.sm,
                    Spacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        // Leaves room for the menu button, so long names ellipsize before it.
                        padding: const EdgeInsets.only(right: 36),
                        child: Text(
                          wallet.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.headlineLgStrong.copyWith(
                            color: walletCardInkColor(context, alpha: 1),
                            shadows: walletCardTextShadow,
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Row(
                        children: [
                          Icon(
                            wallet.type.icon,
                            size: IconSize.sm,
                            color: walletCardInkColor(context, alpha: 0.6),
                          ),
                          const SizedBox(width: Spacing.xs),
                          Expanded(
                            child: Text(
                              wallet.type.label(l10n),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: walletCardInkColor(context, alpha: 0.6),
                                shadows: walletCardTextShadow,
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          Text(
                            balanceText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            // one-off: titleMedium + w800 for the card's balance figure.
                            style: context.textTheme.titleMedium?.copyWith(
                              color: isNegative && !isBalanceHidden
                                  ? walletCardNegativeColor(context)
                                  : walletCardInkColor(context, alpha: 1),
                              fontWeight: FontWeight.w800,
                              shadows: walletCardTextShadow,
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
          Positioned(
            // The disc keeps its place; its larger touch area hangs around it.
            top: Spacing.xs - _CardMenuButton.touchOverhang,
            right: Spacing.xs - _CardMenuButton.touchOverhang,
            child: _CardMenuButton(
              name: wallet.name,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

/// The card's edit/delete menu.
class _CardMenuButton extends StatefulWidget {
  const _CardMenuButton({
    required this.name,
    required this.onEdit,
    required this.onDelete,
  });

  final String name;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const _discSize = IconSize.lg + Spacing.xs * 2;

  /// How far the 48px touch area reaches past the disc on each side.
  static const touchOverhang = (kMinInteractiveDimension - _discSize) / 2;

  @override
  State<_CardMenuButton> createState() => _CardMenuButtonState();
}

class _CardMenuButtonState extends State<_CardMenuButton> {
  final _menuKey = GlobalKey<PopupMenuButtonState<_CardAction>>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    // With a child (not an icon) PopupMenuButton is a bare InkWell to screen
    // readers; outside its tooltip, as Flutter's IconButton does.
    return Semantics(
      button: true,
      child: MinTapTarget(
        onTap: () => _menuKey.currentState?.showButtonMenu(),
        child: PopupMenuButton<_CardAction>(
          key: _menuKey,
          tooltip: l10n.optionsFor(widget.name),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Rounded.md),
          ),
          onSelected: (action) => switch (action) {
            _CardAction.edit => widget.onEdit(),
            _CardAction.delete => widget.onDelete(),
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _CardAction.edit,
              child: Row(
                children: [
                  const Icon(AppIcons.edit, size: IconSize.lg),
                  const SizedBox(width: Spacing.xs),
                  Text(l10n.edit),
                ],
              ),
            ),
            PopupMenuItem(
              value: _CardAction.delete,
              child: Row(
                children: [
                  Icon(AppIcons.delete, size: IconSize.lg, color: colors.error),
                  const SizedBox(width: Spacing.xs),
                  Text(l10n.delete, style: TextStyle(color: colors.error)),
                ],
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: walletCardInkColor(context, alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.more,
              size: IconSize.lg,
              color: walletCardInkColor(context, alpha: 0.85),
            ),
          ),
        ),
      ),
    );
  }
}
