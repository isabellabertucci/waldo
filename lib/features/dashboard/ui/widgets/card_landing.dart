import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/features/wallets/viewmodels/just_added_wallet.dart';

/// Decides once whether the card peeking out of the pouch is a wallet just
/// made, and so drops in, never twice. Home only sees the new wallet once it
/// is on screen (Riverpod pauses a hidden tab), so the drop is never missed.
class CardLanding extends ConsumerStatefulWidget {
  const CardLanding({super.key, required this.walletId, required this.builder});

  /// The wallet whose card peeks out of the pouch; null with no wallets.
  final int? walletId;

  /// The pouch; `landing` says whether its card drops in.
  final Widget Function(bool landing) builder;

  @override
  ConsumerState<CardLanding> createState() => _CardLandingState();
}

class _CardLandingState extends ConsumerState<CardLanding> {
  bool _landing = false;

  @override
  void initState() {
    super.initState();
    _claimLanding();
  }

  @override
  void didUpdateWidget(CardLanding oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.walletId != widget.walletId) {
      _landing = false;
      _claimLanding();
    }
  }

  /// Lands the card when it's the wallet just made.
  void _claimLanding() {
    final id = widget.walletId;
    final justAdded = justAddedWalletProvider(WalletLanding.pouch);
    if (id == null || ref.read(justAdded) != id) return;
    _landing = true;
    // After this frame: a provider can't change while widgets build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(justAdded.notifier).clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // A different card on top starts over.
    return KeyedSubtree(
      key: ValueKey(widget.walletId),
      child: widget.builder(_landing),
    );
  }
}
