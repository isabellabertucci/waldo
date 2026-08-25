import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_list_view_model.dart';

part 'category_list_view_model.g.dart';

@riverpod
class CategoryListViewModel extends _$CategoryListViewModel {
  @override
  Future<List<Category>> build() async {
    final repo = await ref.watch(categoryRepositoryProvider.future);
    return repo.getAll();
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
    ref.invalidate(transactionByIdProvider);
  }

  void restoreCategory() {
    ref.invalidateSelf();
  }
}
