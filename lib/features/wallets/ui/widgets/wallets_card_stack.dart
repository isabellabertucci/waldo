import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/core/theme/elevation.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/wallet_card_finish.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/widgets/edit_delete_menu.dart';
import 'package:waldo/core/widgets/min_tap_target.dart';

import '../../models/wallet.dart';
import '../../wallets_x.dart';

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
    final accessibilitySize = DynamicTypeScaler.isAccessibilitySize(context);
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
                // A whole total shrinks rather than breaking or being cut.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    totalText,
                    style: context.headlineSmExtraBold.copyWith(
                      color: colors.onSurface,
                    ),
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
              return _TuckedUnder(
                hidden: isLastCard ? 0 : ComponentSize.walletCardTuck,
                // At accessibility sizes the card grows with its text.
                child: ConstrainedBox(
                  constraints: accessibilitySize
                      ? const BoxConstraints(
                          minHeight: ComponentSize.walletCard,
                          minWidth: double.infinity,
                        )
                      : const BoxConstraints.tightFor(
                          height: ComponentSize.walletCard,
                          width: double.infinity,
                        ),
                  child: _WalletCard(
                    key: Key('walletCard_${wallet.id}'),
                    wallet: wallet,
                    currency: currency,
                    isBalanceHidden: isBalanceHidden,
                    finish: WalletCardFinish.fromIndex(index),
                    showSeamTab: !isLastCard,
                    accessibilitySize: accessibilitySize,
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
    required this.accessibilitySize,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Wallet wallet;
  final Currency currency;
  final bool isBalanceHidden;
  final WalletCardFinish finish;
  final bool showSeamTab;

  /// Grows with its text and puts type and balance on their own lines.
  final bool accessibilitySize;
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

    final inkMuted = walletCardInkColor(context, alpha: Alpha.muted);
    final typeRow = Row(
      children: [
        Icon(wallet.type.icon, size: IconSize.sm, color: inkMuted),
        const SizedBox(width: Spacing.xs),
        Expanded(
          child: WholeWordsText.singleLine(
            wallet.type.label(l10n),
            style: context.textTheme.bodySmall?.copyWith(
              color: inkMuted,
              shadows: walletCardTextShadow,
            ),
          ),
        ),
      ],
    );
    final balance = Text(
      balanceText,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.walletCardBalance.copyWith(
        color: isNegative && !isBalanceHidden
            ? walletCardNegativeColor(context)
            : walletCardInkColor(context, alpha: 1),
        shadows: walletCardTextShadow,
      ),
    );

    return Material(
      borderRadius: BorderRadius.circular(Rounded.lg),
      clipBehavior: Clip.antiAlias,
      elevation: 3,

      child: Stack(
        // The text decides the card's height when it isn't fixed.
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: Hero(
              tag: 'walletCardBg_${wallet.id}',
              child: WalletCardBackground(finish: finish),
            ),
          ),

          // A soft shadow along the top edge, for depth where the cards overlap.
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: ComponentSize.walletCardTopShade,
            child: IgnorePointer(
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
          ),

          if (showSeamTab)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: ComponentSize.walletCardSeam.width,
                  height: ComponentSize.walletCardSeam.height,
                  margin: const EdgeInsets.only(bottom: Spacing.xs),
                  decoration: BoxDecoration(
                    color: walletCardInkColor(context, alpha: Alpha.stitch),
                    borderRadius: BorderRadius.circular(Rounded.pill),
                  ),
                ),
              ),
            ),
          // Fills the card, so a tap anywhere on it opens the wallet, not just on the text.
          Semantics(
            button: true,
            child: InkWell(
              onTap: onTap,
              splashColor: walletCardInkColor(context, alpha: Alpha.soft),
              highlightColor: walletCardInkColor(context, alpha: Alpha.tint),
              child: Padding(
                // A growing card keeps its text above the part the next
                // card covers.
                padding: EdgeInsets.fromLTRB(
                  Spacing.sm,
                  Spacing.md,
                  Spacing.sm,
                  Spacing.sm +
                      (accessibilitySize && showSeamTab
                          ? ComponentSize.walletCardTuck
                          : 0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      // Leaves room for the menu button, so long names ellipsize before it.
                      padding: const EdgeInsets.only(
                        right: ComponentSize.walletCardMenuRoom,
                      ),
                      child: WholeWordsText.singleLine(
                        wallet.name,
                        style: context.headlineLgExtraBold.copyWith(
                          color: walletCardInkColor(context, alpha: 1),
                          shadows: walletCardTextShadow,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    if (accessibilitySize) ...[
                      typeRow,
                      // A whole balance shrinks rather than being cut.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: balance,
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(child: typeRow),
                          const SizedBox(width: Spacing.sm),
                          balance,
                        ],
                      ),
                  ],
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
  final _menuKey = GlobalKey<PopupMenuButtonState<EditDeleteAction>>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // With a child (not an icon) PopupMenuButton is a bare InkWell to screen
    // readers; outside its tooltip, as Flutter's IconButton does.
    return Semantics(
      button: true,
      child: MinTapTarget(
        onTap: () => _menuKey.currentState?.showButtonMenu(),
        child: PopupMenuButton<EditDeleteAction>(
          key: _menuKey,
          tooltip: l10n.optionsFor(widget.name),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Rounded.md),
          ),
          onSelected: (action) => switch (action) {
            EditDeleteAction.edit => widget.onEdit(),
            EditDeleteAction.delete => widget.onDelete(),
          },
          itemBuilder: editDeleteMenuItems,
          child: Container(
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: walletCardInkColor(context, alpha: Alpha.tint),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.more,
              size: IconSize.lg,
              color: walletCardInkColor(context, alpha: Alpha.strong),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lays its child out at full height but takes [hidden] less, so the next
/// card in the stack covers the child's bottom.
class _TuckedUnder extends SingleChildRenderObjectWidget {
  const _TuckedUnder({required this.hidden, required super.child});

  final double hidden;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTuckedUnder(hidden);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderTuckedUnder renderObject,
  ) => renderObject.hidden = hidden;
}

class _RenderTuckedUnder extends RenderProxyBox {
  _RenderTuckedUnder(this._hidden);

  double _hidden;
  set hidden(double value) {
    if (value == _hidden) return;
    _hidden = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final child = this.child!;
    child.layout(
      constraints.copyWith(minHeight: 0, maxHeight: double.infinity),
      parentUsesSize: true,
    );
    size = constraints.constrain(
      Size(child.size.width, math.max(0, child.size.height - _hidden)),
    );
  }
}
