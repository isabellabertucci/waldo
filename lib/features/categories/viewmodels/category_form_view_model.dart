import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'category_form_state.dart';
import 'category_list_view_model.dart';

part 'category_form_view_model.g.dart';

final _log = Logger('waldo.vm.category');

@riverpod
class CategoryFormViewModel extends _$CategoryFormViewModel {
  @override
  CategoryFormState build(Category? existingCategory) {
    return CategoryFormState(
      name: existingCategory?.name ?? '',
      type: existingCategory?.type ?? CategoryType.groceries,
    );
  }

  void updateName(String value) {
    state = state.copyWith(name: value);
  }

  void updateType(CategoryType value) {
    state = state.copyWith(type: value);
  }

  Future<bool> save(Category? existingCategory) async {
    if (state.name.trim().isEmpty) return false;

    final repo = await ref.read(categoryRepositoryProvider.future);

    if (existingCategory != null) {
      await repo.update(
        existingCategory.copyWith(name: state.name.trim(), type: state.type),
      );
    } else {
      await repo.insert(
        Category(
          name: state.name.trim(),
          type: state.type,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
    }

    _log.info('Category save succeeded: isEditing=${existingCategory != null}');
    ref.invalidate(categoryListViewModelProvider);
    return true;
  }
}
