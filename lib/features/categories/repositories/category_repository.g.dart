// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categoryRepository)
const categoryRepositoryProvider = CategoryRepositoryProvider._();

final class CategoryRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ICategoryRepository>,
          ICategoryRepository,
          FutureOr<ICategoryRepository>
        >
    with
        $FutureModifier<ICategoryRepository>,
        $FutureProvider<ICategoryRepository> {
  const CategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ICategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ICategoryRepository> create(Ref ref) {
    return categoryRepository(ref);
  }
}

String _$categoryRepositoryHash() =>
    r'e649b7cd06def719be1e3015741b760687906f05';
