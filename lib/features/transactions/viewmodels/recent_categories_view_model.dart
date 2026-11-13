import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/viewmodels/category_list_view_model.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';

part 'recent_categories_view_model.g.dart';

/// How many recent categories the new-transaction sheet offers as chips.
const recentCategoryCount = 4;

/// The categories used last for [type], newest first, for one-tap picking:
/// an income offers Salary, not Groceries. "Others" is left out: it's what
/// no pick already means.
@riverpod
Future<List<Category>> recentCategories(Ref ref, TransactionType type) async {
  final repo = await ref.watch(transactionRepositoryProvider.future);
  final categories = await ref.watch(categoryListViewModelProvider.future);
  final byId = {for (final c in categories) c.id: c};
  final ids = await repo.recentCategoryIds(
    type,
    limit: recentCategoryCount + 1,
  );
  return [
    for (final id in ids)
      if (byId[id] case final category? when !category.isOthers) category,
  ].take(recentCategoryCount).toList();
}
