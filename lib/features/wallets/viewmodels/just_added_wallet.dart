import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'just_added_wallet.g.dart';

/// Where a new wallet's card lands: in Home's pouch, and in the Wallets
/// stack. Each plays once, whichever the person sees first.
enum WalletLanding { pouch, stack }

/// The wallet just created, until [landing] shows its card landing; then
/// cleared, so it never lands there twice.
@Riverpod(keepAlive: true)
class JustAddedWallet extends _$JustAddedWallet {
  @override
  int? build(WalletLanding landing) => null;

  void set(int id) => state = id;

  void clear() => state = null;
}
