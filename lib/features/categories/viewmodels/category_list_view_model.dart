import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_list_view_model.dart';

part 'category_list_view_model.g.dart';

final _log = Logger('waldo.vm.category');

@riverpod
class CategoryListViewModel extends _$CategoryListViewModel {
  @override
  Future<List<Category>> build() async {
    final repo = await ref.watch(categoryRepositoryProvider.future);
    return repo.getAll();
  }

  /// Adds a custom category; throws [DuplicateCategoryNameException].
  Future<void> add(String name) async {
    final repo = await ref.read(categoryRepositoryProvider.future);
    await repo.insert(
      Category(name: name.trim(), createdAt: DateTime.now().toIso8601String()),
    );
    _log.info('Category added');
    ref.invalidateSelf();
  }

  /// How many transactions would move to "Others" if [id] were deleted.
  Future<int> transactionCount(int id) async {
    final repo = await ref.read(categoryRepositoryProvider.future);
    return repo.countTransactions(id);
  }

  bool hideCategory(int id) {
    final current = state.value;
    if (current == null) return false;
    state = AsyncData(current.where((c) => c.id != id).toList());
    return true;
  }

  Future<void> confirmDelete(int id) async {
    final repo = await ref.read(categoryRepositoryProvider.future);
    await repo.delete(id);
    ref.invalidate(transactionListViewModelProvider);
    ref.invalidate(dashboardViewModelProvider);
  }

  void restoreCategory() {
    ref.invalidateSelf();
  }
}
