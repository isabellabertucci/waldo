import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_list_view_model.dart';

import 'pending_category_deletes.dart';

part 'category_list_view_model.g.dart';

final _log = Logger('waldo.vm.category');

@riverpod
class CategoryListViewModel extends _$CategoryListViewModel {
  @override
  Future<List<Category>> build() async {
    final repo = await ref.watch(categoryRepositoryProvider.future);
    final pending = ref.watch(pendingCategoryDeletesProvider);
    final categories = await repo.getAll();
    return categories.where((c) => !pending.contains(c.id)).toList();
  }

  /// True while a save is writing, so the button and the keyboard's done
  /// key fired together save it once.
  bool _saving = false;

  /// Adds a custom category and returns its id, or null when a save was
  /// already running; throws [DuplicateCategoryNameException].
  Future<int?> add(String name) => _guarded(() async {
    final repo = await ref.read(categoryRepositoryProvider.future);
    final id = await repo.insert(
      Category(
        name: name.trim(),
        createdAt: ref.read(clockProvider)().toIso8601String(),
      ),
    );
    _log.info('Category added: id=$id');
    ref.invalidateSelf();
    return id;
  });

  /// Renames custom category [id]; does nothing while a save is running;
  /// throws [DuplicateCategoryNameException].
  Future<void> rename(int id, String name) => _guarded(() async {
    final repo = await ref.read(categoryRepositoryProvider.future);
    await repo.rename(id, name.trim());
    _log.info('Category renamed: id=$id');
    ref.invalidateSelf();
    // The receipt lists categories by name.
    ref.invalidate(dashboardViewModelProvider);
  });

  /// Runs [save] unless one is already running, then returns null.
  Future<T?> _guarded<T>(Future<T> Function() save) async {
    if (_saving) return null;
    _saving = true;
    try {
      return await save();
    } finally {
      _saving = false;
    }
  }

  /// How many transactions would move to "Others" if [id] were deleted.
  Future<int> transactionCount(int id) async {
    final repo = await ref.read(categoryRepositoryProvider.future);
    return repo.countTransactions(id);
  }

  bool hideCategory(int id) {
    final current = state.value;
    if (current == null || !current.any((c) => c.id == id)) return false;
    // Hidden here at once, and everywhere else through the pending set.
    state = AsyncData(current.where((c) => c.id != id).toList());
    ref.read(pendingCategoryDeletesProvider.notifier).add(id);
    return true;
  }

  Future<void> confirmDelete(int id) async {
    final repo = await ref.read(categoryRepositoryProvider.future);
    await repo.delete(id);
    ref.read(pendingCategoryDeletesProvider.notifier).remove(id);
    ref.invalidate(transactionListViewModelProvider);
    ref.invalidate(dashboardViewModelProvider);
  }

  void restoreCategory(int id) {
    ref.read(pendingCategoryDeletesProvider.notifier).remove(id);
  }
}

/// The categories by id, for rows that show a transaction's category; empty
/// until they load. A category inside its Undo window maps to "Others".
@riverpod
Map<int, Category> categoriesById(Ref ref) {
  final pending = ref.watch(pendingCategoryDeletesProvider);
  return switch (ref.watch(categoryListViewModelProvider)) {
    AsyncValue(:final value?) => {
      for (final c in value)
        if (c.id != null) c.id!: c,
      if (value.where((c) => c.isOthers).firstOrNull case final others?)
        for (final id in pending) id: others,
    },
    _ => const {},
  };
}
