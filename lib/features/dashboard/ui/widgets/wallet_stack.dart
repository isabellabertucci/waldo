import 'package:flutter/material.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/widgets/leather_wallet.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/ui/widgets/wallet_face.dart';

/// Home's wallets: the largest in front, up to three more peeking out to its
/// right, each a step further and shorter (DESIGN.md "Wallets"). Tapping the
/// front one opens it.
class WalletStack extends StatelessWidget {
  const WalletStack({
    super.key,
    required this.wallets,
    required this.currency,
    required this.isBalanceHidden,
    required this.onOpen,
  });

  final List<Wallet> wallets;
  final Currency currency;
  final bool isBalanceHidden;
  final ValueChanged<Wallet> onOpen;

  @override
  Widget build(BuildContext context) {
    final ranked = [
      ...wallets,
    ]..sort((a, b) => b.currentBalance.abs().compareTo(a.currentBalance.abs()));
    final shown = ranked.take(ComponentSize.walletStackMax).toList();
    const step = ComponentSize.walletStackStep;
    final behind = shown.length - 1;

    return SizedBox(
      height: ComponentSize.wallet,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth - step.dx * behind;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Painted back to front.
              for (var i = behind; i >= 0; i--)
                Positioned(
                  left: step.dx * i,
                  top: step.dy * i,
                  width: width,
                  child: ExcludeSemantics(
                    excluding: i > 0,
                    child: _StackedWallet(
                      wallet: shown[i],
                      finish: shown[i].finish,
                      height:
                          ComponentSize.wallet -
                          ComponentSize.walletStackShrink * i,
                      isFront: i == 0,
                      currency: currency,
                      isBalanceHidden: isBalanceHidden,
                      onTap: () => onOpen(shown[i]),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StackedWallet extends StatelessWidget {
  const _StackedWallet({
    required this.wallet,
    required this.finish,
    required this.height,
    required this.isFront,
    required this.currency,
    required this.isBalanceHidden,
    required this.onTap,
  });

  final Wallet wallet;
  final LeatherFinish finish;
  final double height;
  final bool isFront;
  final Currency currency;
  final bool isBalanceHidden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: LeatherWallet(
          finish: finish,
          height: height,
          // The ones behind only show their leather and strap.
          child: !isFront
              ? const SizedBox.shrink()
              : WalletFace(
                  wallet: wallet,
                  finish: finish,
                  currency: currency,
                  isBalanceHidden: isBalanceHidden,
                ),
        ),
      ),
    );
  }
}
