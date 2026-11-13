// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_categories_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The categories used last for [type], newest first, for one-tap picking:
/// an income offers Salary, not Groceries. "Others" is left out: it's what
/// no pick already means.

@ProviderFor(recentCategories)
const recentCategoriesProvider = RecentCategoriesFamily._();

/// The categories used last for [type], newest first, for one-tap picking:
/// an income offers Salary, not Groceries. "Others" is left out: it's what
/// no pick already means.

final class RecentCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          FutureOr<List<Category>>
        >
    with $FutureModifier<List<Category>>, $FutureProvider<List<Category>> {
  /// The categories used last for [type], newest first, for one-tap picking:
  /// an income offers Salary, not Groceries. "Others" is left out: it's what
  /// no pick already means.
  const RecentCategoriesProvider._({
    required RecentCategoriesFamily super.from,
    required TransactionType super.argument,
  }) : super(
         retry: null,
         name: r'recentCategoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentCategoriesHash();

  @override
  String toString() {
    return r'recentCategoriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Category>> create(Ref ref) {
    final argument = this.argument as TransactionType;
    return recentCategories(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentCategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentCategoriesHash() => r'e4bf5c1fa8049decbc50b842b497a681e00786f9';

/// The categories used last for [type], newest first, for one-tap picking:
/// an income offers Salary, not Groceries. "Others" is left out: it's what
/// no pick already means.

final class RecentCategoriesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Category>>, TransactionType> {
  const RecentCategoriesFamily._()
    : super(
        retry: null,
        name: r'recentCategoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The categories used last for [type], newest first, for one-tap picking:
  /// an income offers Salary, not Groceries. "Others" is left out: it's what
  /// no pick already means.

  RecentCategoriesProvider call(TransactionType type) =>
      RecentCategoriesProvider._(argument: type, from: this);

  @override
  String toString() => r'recentCategoriesProvider';
}
