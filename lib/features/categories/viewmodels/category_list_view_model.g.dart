// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoryListViewModel)
const categoryListViewModelProvider = CategoryListViewModelProvider._();

final class CategoryListViewModelProvider
    extends $AsyncNotifierProvider<CategoryListViewModel, List<Category>> {
  const CategoryListViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryListViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryListViewModelHash();

  @$internal
  @override
  CategoryListViewModel create() => CategoryListViewModel();
}

String _$categoryListViewModelHash() =>
    r'dc8fbd508bbff1910275d78bf91413939d710435';

abstract class _$CategoryListViewModel extends $AsyncNotifier<List<Category>> {
  FutureOr<List<Category>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Category>>, List<Category>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Category>>, List<Category>>,
              AsyncValue<List<Category>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
