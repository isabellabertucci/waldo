// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_form_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoryFormViewModel)
const categoryFormViewModelProvider = CategoryFormViewModelFamily._();

final class CategoryFormViewModelProvider
    extends $NotifierProvider<CategoryFormViewModel, CategoryFormState> {
  const CategoryFormViewModelProvider._({
    required CategoryFormViewModelFamily super.from,
    required Category? super.argument,
  }) : super(
         retry: null,
         name: r'categoryFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryFormViewModelHash();

  @override
  String toString() {
    return r'categoryFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CategoryFormViewModel create() => CategoryFormViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryFormViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryFormViewModelHash() =>
    r'0b3e00b56012cf965b36a90be7b3139b375a4593';

final class CategoryFormViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          CategoryFormViewModel,
          CategoryFormState,
          CategoryFormState,
          CategoryFormState,
          Category?
        > {
  const CategoryFormViewModelFamily._()
    : super(
        retry: null,
        name: r'categoryFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryFormViewModelProvider call(Category? existingCategory) =>
      CategoryFormViewModelProvider._(argument: existingCategory, from: this);

  @override
  String toString() => r'categoryFormViewModelProvider';
}

abstract class _$CategoryFormViewModel extends $Notifier<CategoryFormState> {
  late final _$args = ref.$arg as Category?;
  Category? get existingCategory => _$args;

  CategoryFormState build(Category? existingCategory);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<CategoryFormState, CategoryFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CategoryFormState, CategoryFormState>,
              CategoryFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
