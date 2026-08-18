// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransactionListViewModel)
const transactionListViewModelProvider = TransactionListViewModelFamily._();

final class TransactionListViewModelProvider
    extends
        $AsyncNotifierProvider<TransactionListViewModel, List<Transaction>> {
  const TransactionListViewModelProvider._({
    required TransactionListViewModelFamily super.from,
    required ({int? walletId, SortOrder sortOrder}) super.argument,
  }) : super(
         retry: null,
         name: r'transactionListViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionListViewModelHash();

  @override
  String toString() {
    return r'transactionListViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  TransactionListViewModel create() => TransactionListViewModel();

  @override
  bool operator ==(Object other) {
    return other is TransactionListViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionListViewModelHash() =>
    r'a266e6efd00dc1bd72567271ebff36bc15d4e680';

final class TransactionListViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          TransactionListViewModel,
          AsyncValue<List<Transaction>>,
          List<Transaction>,
          FutureOr<List<Transaction>>,
          ({int? walletId, SortOrder sortOrder})
        > {
  const TransactionListViewModelFamily._()
    : super(
        retry: null,
        name: r'transactionListViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionListViewModelProvider call({
    int? walletId,
    SortOrder sortOrder = SortOrder.desc,
  }) => TransactionListViewModelProvider._(
    argument: (walletId: walletId, sortOrder: sortOrder),
    from: this,
  );

  @override
  String toString() => r'transactionListViewModelProvider';
}

abstract class _$TransactionListViewModel
    extends $AsyncNotifier<List<Transaction>> {
  late final _$args = ref.$arg as ({int? walletId, SortOrder sortOrder});
  int? get walletId => _$args.walletId;
  SortOrder get sortOrder => _$args.sortOrder;

  FutureOr<List<Transaction>> build({
    int? walletId,
    SortOrder sortOrder = SortOrder.desc,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      walletId: _$args.walletId,
      sortOrder: _$args.sortOrder,
    );
    final ref =
        this.ref as $Ref<AsyncValue<List<Transaction>>, List<Transaction>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Transaction>>, List<Transaction>>,
              AsyncValue<List<Transaction>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
