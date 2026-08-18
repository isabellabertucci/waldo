import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'transaction_form_state.dart';
import 'transaction_list_view_model.dart';

part 'transaction_form_view_model.g.dart';

final _log = Logger('waldo.vm.transaction');

@riverpod
class TransactionFormViewModel extends _$TransactionFormViewModel {
  @override
  TransactionFormState build(
    Transaction? existingTransaction, {
    int? initialWalletId,
  }) {
    if (existingTransaction != null) {
      return TransactionFormState(
        amount: formatCentsForInput(existingTransaction.amount),
        type: existingTransaction.type,
        date: DateTime.tryParse(existingTransaction.date),
        walletId: existingTransaction.walletId,
        categoryId: existingTransaction.categoryId,
        description: existingTransaction.description ?? '',
      );
    }
    return TransactionFormState(walletId: initialWalletId);
  }

  void updateAmount(String value) {
    state = state.copyWith(amount: value);
  }

  void updateType(TransactionType value) {
    state = state.copyWith(type: value);
  }

  void updateDate(DateTime value) {
    state = state.copyWith(date: value);
  }

  void updateWalletId(int value) {
    state = state.copyWith(walletId: value);
  }

  void updateCategoryId(int? value) {
    state = state.copyWith(categoryId: value);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  Future<bool> save(Transaction? existingTransaction) async {
    final walletId = state.walletId;
    final date = state.date;
    if (walletId == null || date == null) return false;

    final amountInCents = parseToCents(state.amount, allowNegative: false);
    if (amountInCents == null || amountInCents <= 0) return false;

    final repo = await ref.read(transactionRepositoryProvider.future);
    final description = state.description.trim();

    if (existingTransaction != null) {
      await repo.update(
        existingTransaction.copyWith(
          walletId: walletId,
          categoryId: state.categoryId,
          amount: amountInCents,
          type: state.type,
          date: date.toIso8601String(),
          description: description.isEmpty ? null : description,
        ),
      );
    } else {
      await repo.insert(
        Transaction(
          walletId: walletId,
          categoryId: state.categoryId,
          amount: amountInCents,
          type: state.type,
          date: date.toIso8601String(),
          description: description.isEmpty ? null : description,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
    }

    _log.info(
      'Transaction save succeeded: isEditing=${existingTransaction != null}',
    );
    ref.invalidate(transactionListViewModelProvider());
    return true;
  }
}
