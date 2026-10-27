import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/features/wallets/viewmodels/wallets_summary_view_model.dart';
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
        note: existingTransaction.note ?? '',
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

  void updateNote(String value) {
    state = state.copyWith(note: value);
  }

  /// Puts back a state captured earlier - the edit sheet's Cancel.
  void restore(TransactionFormState snapshot) {
    state = snapshot;
  }

  Future<int?> _othersCategoryId() async {
    final categories = await ref.read(categoryRepositoryProvider.future);
    return (await categories.getOthers()).id;
  }

  /// True while a save is writing, so a double tap can't save twice.
  bool _saving = false;

  Future<bool> save() async {
    if (_saving) return false;
    _saving = true;
    try {
      return await _save();
    } finally {
      _saving = false;
    }
  }

  Future<bool> _save() async {
    // The transaction this form was built for, so save can't target another.
    final existingTransaction = this.existingTransaction;
    final walletId = state.walletId;
    final date = state.date;
    if (walletId == null || date == null) return false;

    final amountInCents = parseToCents(state.amount, allowNegative: false);
    if (amountInCents == null || amountInCents <= 0) return false;

    final repo = await ref.read(transactionRepositoryProvider.future);
    // No category picked lands in "Others", the one home for the uncategorized.
    final categoryId = state.categoryId ?? await _othersCategoryId();
    final description = state.description.trim();
    final note = state.note.trim();

    if (existingTransaction != null) {
      await repo.update(
        existingTransaction.copyWith(
          walletId: walletId,
          categoryId: categoryId,
          amount: amountInCents,
          type: state.type,
          date: date.toIso8601String(),
          description: description.isEmpty ? null : description,
          note: note.isEmpty ? null : note,
        ),
      );
    } else {
      await repo.insert(
        Transaction(
          walletId: walletId,
          categoryId: categoryId,
          amount: amountInCents,
          type: state.type,
          date: date.toIso8601String(),
          description: description.isEmpty ? null : description,
          note: note.isEmpty ? null : note,
          createdAt: ref.read(clockProvider)().toIso8601String(),
        ),
      );
    }

    _log.info(
      'Transaction save succeeded: isEditing=${existingTransaction != null}',
    );

    // The whole family: this wallet's list, the old wallet's list if it
    // moved, and the "all transactions" list (no walletId).
    ref.invalidate(transactionListViewModelProvider);
    ref.invalidate(walletListViewModelProvider);
    ref.invalidate(dashboardViewModelProvider);
    ref.invalidate(walletsSummaryViewModelProvider);

    return true;
  }
}
