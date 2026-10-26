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
    r'8df98d979dca703af5814d3f3da63ddc777d8bc2';

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

/// The categories by id, for rows that show a transaction's category; empty
/// until they load.

@ProviderFor(categoriesById)
const categoriesByIdProvider = CategoriesByIdProvider._();

/// The categories by id, for rows that show a transaction's category; empty
/// until they load.

final class CategoriesByIdProvider
    extends
        $FunctionalProvider<
          Map<int, Category>,
          Map<int, Category>,
          Map<int, Category>
        >
    with $Provider<Map<int, Category>> {
  /// The categories by id, for rows that show a transaction's category; empty
  /// until they load.
  const CategoriesByIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesByIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesByIdHash();

  @$internal
  @override
  $ProviderElement<Map<int, Category>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<int, Category> create(Ref ref) {
    return categoriesById(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, Category> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, Category>>(value),
    );
  }
}

String _$categoriesByIdHash() => r'aaf60e05751e35ab60e08720519d229c6f60f617';
