import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_wallet_deletes.g.dart';

/// Wallets deleted but still inside their Undo window. Every screen leaves
/// them and their transactions out, as the delete will.
@Riverpod(keepAlive: true)
class PendingWalletDeletes extends _$PendingWalletDeletes {
  @override
  Set<int> build() => const {};

  void add(int id) => state = {...state, id};

  void remove(int id) => state = {...state}..remove(id);
}
