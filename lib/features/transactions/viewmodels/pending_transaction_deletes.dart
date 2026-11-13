import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/features/transactions/models/transaction.dart';

part 'pending_transaction_deletes.g.dart';

/// Transactions deleted but still inside their Undo window, by id. Every
/// list leaves them out and every balance and total discounts them, so the
/// numbers agree whichever screen the delete started from.
@Riverpod(keepAlive: true)
class PendingTransactionDeletes extends _$PendingTransactionDeletes {
  @override
  Map<int, Transaction> build() => const {};

  void add(Transaction transaction) =>
      state = {...state, transaction.id!: transaction};

  void remove(int id) => state = {...state}..remove(id);
}

/// What the pending deletes in [walletId] (or in every wallet) add to its
/// balance: subtracting it leaves the balance as if they were gone.
int pendingBalanceChange(Map<int, Transaction> pending, {int? walletId}) =>
    pending.values
        .where((t) => walletId == null || t.walletId == walletId)
        .fold(0, (sum, t) => sum + t.signedAmount);
