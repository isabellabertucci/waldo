import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_transaction_deletes.g.dart';

/// Transactions deleted but still inside their Undo window. Every list and
/// the dashboard leave them out, so a refetch during the window can't bring
/// them back, whichever screen the delete started from.
@Riverpod(keepAlive: true)
class PendingTransactionDeletes extends _$PendingTransactionDeletes {
  @override
  Set<int> build() => const {};

  void add(int id) => state = {...state, id};

  void remove(int id) => state = {...state}..remove(id);
}
