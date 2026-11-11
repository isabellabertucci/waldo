import 'dart:math' as math;

import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/core/theme/elevation.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/wallet_card_finish.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/widgets/balance_amount.dart';
import 'package:waldo/core/widgets/edit_delete_menu.dart';

import '../../models/wallet.dart';
import '../../viewmodels/just_added_wallet.dart';
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
    final totalBalance = wallets.fold<int>(
      0,
      (sum, w) => sum + w.currentBalance,
    );
    final totalText = formatCents(
      totalBalance,
      locale: moneyLocale(context),
      currencyCode: currency.code,
    );
    final roundedPercent = keptPercent?.round();
    final isOverspent = roundedPercent != null && roundedPercent < 0;
    final caption = switch (roundedPercent) {
      null => l10n.walletsCountLabel(n),
      final p when p < 0 => l10n.overspentPercentThisMonth('${-p}%'),
      final p => l10n.keptPercentThisMonth('$p%'),
    };
    final captionStyle = context.textTheme.bodySmall?.copyWith(
      color: isOverspent ? colors.error : colors.onSurfaceVariant,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        Spacing.pageMargin,
        Spacing.lg,
        Spacing.pageMargin,
        // Clear of the floating navbar.
        Spacing.lg + MediaQuery.paddingOf(context).bottom,
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
                      Text(caption, style: captionStyle),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                // A whole total shrinks rather than breaking or being cut.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: BalanceAmount(
                    amount: totalText,
                    hidden: isBalanceHidden,
                    style: context.headlineSmExtraBold.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          _CardStack(
            wallets: wallets,
            currency: currency,
            isBalanceHidden: isBalanceHidden,
            onTapWallet: onTapWallet,
            onEditWallet: onEditWallet,
            onDeleteWallet: onDeleteWallet,
          ),
        ],
      ),
    );
  }
}

/// The cards, each tucked under the next. A deleted card slides out while
/// the cards below close the gap; Undo brings it back; a
/// new wallet's card lands in its place while the others make room.
class _CardStack extends ConsumerStatefulWidget {
  const _CardStack({
    required this.wallets,
    required this.currency,
    required this.isBalanceHidden,
    required this.onTapWallet,
    required this.onEditWallet,
    required this.onDeleteWallet,
  });

  final List<Wallet> wallets;
  final Currency currency;
  final bool isBalanceHidden;
  final ValueChanged<Wallet> onTapWallet;
  final ValueChanged<Wallet> onEditWallet;
  final ValueChanged<Wallet> onDeleteWallet;

  @override
  ConsumerState<_CardStack> createState() => _CardStackState();
}

class _CardStackState extends ConsumerState<_CardStack>
    with TickerProviderStateMixin {
  /// Each card's place in the stack, to measure it.
  final _slotKeys = <int, GlobalKey>{};

  /// A deleted card still on screen while it leaves, at its old [_leftAt].
  Wallet? _leaving;
  var _leftAt = 0;

  /// How far the cards below rise to close the leaving card's gap.
  var _gapHeight = 0.0;
  late final AnimationController _leave;

  /// Starts the cards below rising [Motion.cardGapDelay] into the leave.
  void _closeGapInTime() {
    final elapsed = _leave.duration! * _leave.value;
    if (elapsed < Motion.cardGapDelay || _gap.isAnimating || _gap.value != 0) {
      return;
    }
    _gap
        .animateWith(SpringSimulation(Motion.snappy, 0, 1, 0))
        .then((_) => _endLeave());
  }

  /// 0 → 1 as the cards below rise into the gap.
  late final AnimationController _gap;

  /// A card arriving: back from Undo, or a new wallet landing.
  int? _arrivingId;
  var _landing = false;

  /// 0 → 1 as it arrives and the cards below make room for it.
  late final AnimationController _arrive;

  /// Whether the landing card has clicked as it touched down.
  var _touchedDown = true;

  void _clickOnLanding() {
    if (!_landing || _touchedDown || _arrive.value < 0.95) return;
    _touchedDown = true;
    HapticFeedback.lightImpact();
  }

  late final AnimationController _landFade;

  /// Times the sheet sliding away on the animation clock, so the wait stays
  /// in step with it.
  late final AnimationController _sheetExit;

  @override
  void initState() {
    super.initState();
    _leave = AnimationController(vsync: this, duration: Motion.cardLeave)
      ..addListener(_closeGapInTime);
    _gap = AnimationController.unbounded(vsync: this);
    _arrive = AnimationController.unbounded(vsync: this, value: 1)
      ..addListener(_clickOnLanding);
    _landFade = AnimationController(
      vsync: this,
      duration: Motion.cardLandFade,
      value: 1,
    );
    _sheetExit = AnimationController(vsync: this, duration: Motion.sheetExit);
    // A wallet made from Home lands the first time this stack shows.
    final justAdded = ref.read(_justAdded);
    if (widget.wallets.any((w) => w.id == justAdded)) {
      _land(justAdded!, madeHere: false);
    }
  }

  static final _justAdded = justAddedWalletProvider(WalletLanding.stack);

  @override
  void didUpdateWidget(_CardStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (context.reduceMotion) return _settle();
    final ids = {for (final w in widget.wallets) w.id};
    final oldIds = {for (final w in oldWidget.wallets) w.id};
    final removed = oldWidget.wallets.where((w) => !ids.contains(w.id));
    final added = widget.wallets.where((w) => !oldIds.contains(w.id));
    if (removed.length == 1 && added.isEmpty) {
      _startLeave(removed.single, oldWidget.wallets.indexOf(removed.single));
    } else if (added.length == 1 && removed.isEmpty) {
      final id = added.single.id!;
      if (ref.read(_justAdded) == id) {
        _land(id, madeHere: true);
      } else {
        _return(id);
      }
    }
  }

  void _startLeave(Wallet wallet, int index) {
    _settle();
    final slot = _slotKeys[wallet.id]?.currentContext?.findRenderObject();
    if (slot is! RenderBox) return;
    _leaving = wallet;
    _leftAt = index;
    _gapHeight = slot.size.height;
    HapticFeedback.mediumImpact();
    _leave.forward(from: 0);
  }

  /// The leaving card is gone and the gap closed: lay the stack out without
  /// it, exactly where the cards already are.
  void _endLeave() {
    if (!mounted || _leaving == null) return;
    setState(() {
      _leaving = null;
      _gap.value = 0;
    });
  }

  void _return(int id) {
    // Undo while it's still leaving: come back from where the gap is.
    final from = _leaving?.id == id ? 1 - _gap.value : 0.0;
    _settle();
    _arrivingId = id;
    _landing = false;
    _arrive
      ..value = from
      ..animateTo(
        1,
        duration: Motion.cardReturn,
        curve: Motion.emphasizedCurve,
      );
  }

  /// [madeHere]: made in the sheet over this screen, so it waits for the
  /// sheet to slide away.
  void _land(int id, {required bool madeHere}) {
    _settle();
    _arrivingId = id;
    _landing = true;
    _arrive.value = 0;
    _landFade.value = 0;
    // After this frame: a provider can't change while widgets build, and the
    // card has to be laid out to be scrolled to.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      ref.read(_justAdded.notifier).clear();
      if (madeHere) {
        await _sheetExit.forward(from: 0);
        if (!mounted) return;
      }
      final slot = _slotKeys[id]?.currentContext;
      if (slot != null && slot.mounted) {
        await Scrollable.ensureVisible(
          slot,
          duration: Motion.scroll,
          curve: Motion.scrollCurve,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        );
      }
      if (!mounted || _arrivingId != id) return;
      _touchedDown = false;
      _landFade.forward(from: 0);
      _arrive
          .animateWith(SpringSimulation(Motion.snappy, 0, 1, 0))
          // A spring stops within a hair of rest; end exactly in place.
          .then((_) => _arrive.value = 1);
    });
  }

  /// Stops whatever is moving and puts every card in its place.
  void _settle() {
    _sheetExit.stop();
    _leave.stop();
    _gap.stop();
    _arrive
      ..stop()
      ..value = 1;
    _landFade.value = 1;
    _leaving = null;
    _gap.value = 0;
    _arrivingId = null;
  }

  @override
  void dispose() {
    _leave.dispose();
    _gap.dispose();
    _arrive.dispose();
    _landFade.dispose();
    _sheetExit.dispose();
    super.dispose();
  }

  /// The height [id]'s card takes in the stack, measured as it's painted.
  double _heightOf(int? id) {
    final slot = _slotKeys[id]?.currentContext?.findRenderObject();
    return slot is RenderBox && slot.hasSize ? slot.size.height : 0;
  }

  @override
  Widget build(BuildContext context) {
    final accessibilitySize = DynamicTypeScaler.isAccessibilitySize(context);
    final leaving = _leaving;
    final cards = [...widget.wallets]
      ..insertAll(leaving == null ? 0 : _leftAt, [?leaving]);
    final arrivingAt = cards.indexWhere((w) => w.id == _arrivingId);
    _slotKeys.removeWhere((id, _) => !cards.any((w) => w.id == id));

    return Column(
      children: [
        for (final (index, wallet) in cards.indexed)
          _shifted(
            index: index,
            arrivingAt: arrivingAt,
            child: _moving(
              wallet,
              _TuckedUnder(
                key: _slotKeys.putIfAbsent(wallet.id!, GlobalKey.new),
                hidden: index == cards.length - 1
                    ? 0
                    : ComponentSize.walletCardTuck,
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
                    currency: widget.currency,
                    isBalanceHidden: widget.isBalanceHidden,
                    // The finish of its place once the stack settles, so the
                    // metals change as the move starts, not as it ends.
                    finish: WalletCardFinish.fromIndex(
                      wallet == leaving
                          ? _leftAt
                          : widget.wallets.indexOf(wallet),
                    ),
                    showSeamTab: index != cards.length - 1,
                    accessibilitySize: accessibilitySize,
                    onTap: () => widget.onTapWallet(wallet),
                    onEdit: () => widget.onEditWallet(wallet),
                    onDelete: () => widget.onDeleteWallet(wallet),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// A card below one that's leaving or arriving moves up into its gap, or
  /// starts there and moves down to make room.
  Widget _shifted({
    required int index,
    required int arrivingAt,
    required Widget child,
  }) {
    if (_leaving != null && index > _leftAt) {
      return _Shift(
        repaint: _gap,
        dy: () => -_gapHeight * _gap.value,
        child: child,
      );
    }
    if (arrivingAt >= 0 && index > arrivingAt) {
      return _Shift(
        repaint: _arrive,
        dy: () => -_heightOf(_arrivingId) * (1 - _arrive.value),
        child: child,
      );
    }
    return child;
  }

  /// The leaving card slides out; an arriving card fades and grows back, or
  /// drops in from above.
  Widget _moving(Wallet wallet, Widget card) {
    if (wallet == _leaving) {
      return AnimatedBuilder(
        animation: _leave,
        builder: (context, child) {
          final slide = Motion.cardLeaveCurve.transform(_leave.value);
          return FractionalTranslation(
            translation: Offset(-Motion.cardLeaveDistance * slide, 0),
            child: child,
          );
        },
        child: IgnorePointer(child: card),
      );
    }
    if (wallet.id != _arrivingId) return card;
    return AnimatedBuilder(
      animation: Listenable.merge([_arrive, _landFade]),
      builder: (context, child) {
        final p = _arrive.value;
        if (_landing) {
          return Opacity(
            opacity: _landFade.value,
            child: Transform.translate(
              offset: Offset(0, -Motion.cardLandHeight * (1 - p)),
              child: Transform.scale(
                scale: lerpDouble(Motion.cardLandScale, 1, p),
                child: child,
              ),
            ),
          );
        }
        return Opacity(
          opacity: p.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: lerpDouble(Motion.cardReturnScale, 1, p),
            child: child,
          ),
        );
      },
      child: card,
    );
  }
}

/// Moves [child] down by [dy] (read as it's painted, so it can depend on
/// another card's size) without laying anything out again.
class _Shift extends SingleChildRenderObjectWidget {
  const _Shift({required this.repaint, required this.dy, required super.child});

  final Listenable repaint;
  final double Function() dy;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderShift(repaint, dy);

  @override
  void updateRenderObject(BuildContext context, _RenderShift renderObject) =>
      renderObject
        ..repaint = repaint
        ..dy = dy;
}

class _RenderShift extends RenderProxyBox {
  _RenderShift(this._repaint, this.dy);

  Listenable _repaint;
  set repaint(Listenable value) {
    if (value == _repaint) return;
    if (attached) {
      _repaint.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _repaint = value;
  }

  double Function() dy;

  Offset get _offset => Offset(0, dy());

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _repaint.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _repaint.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      super.paint(context, offset + _offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      result.addWithPaintOffset(
        offset: _offset,
        position: position,
        hitTest: (result, position) =>
            super.hitTestChildren(result, position: position),
      );

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) =>
      transform.translateByDouble(_offset.dx, _offset.dy, 0, 1);
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
    final balanceText = formatCents(
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
    final balance = BalanceAmount(
      amount: balanceText,
      hidden: isBalanceHidden,
      style: context.walletCardBalance.copyWith(
        color: isNegative && !isBalanceHidden
            ? walletCardNegativeColor(context)
            : walletCardInkColor(context, alpha: 1),
        shadows: walletCardTextShadow,
      ),
      // At the end of the type's line; on a line of its own with large text.
      alignment: accessibilitySize
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
    );

    return Material(
      borderRadius: BorderRadius.circular(Rounded.lg),
      clipBehavior: Clip.antiAlias,
      elevation: 3,

      child: Stack(
        // The text decides the card's height when it isn't fixed.
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(child: WalletCardBackground(finish: finish)),

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
class _CardMenuButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return EditDeleteMenuButton(
      tooltip: AppLocalizations.of(context).optionsFor(name),
      onSelected: (action) => switch (action) {
        EditDeleteAction.edit => onEdit(),
        EditDeleteAction.delete => onDelete(),
      },
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
    );
  }
}

/// Lays its child out at full height but takes [hidden] less, so the next
/// card in the stack covers the child's bottom.
class _TuckedUnder extends SingleChildRenderObjectWidget {
  const _TuckedUnder({super.key, required this.hidden, required super.child});

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
