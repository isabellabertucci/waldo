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
    required ({int walletId, SortOrder sortOrder}) super.argument,
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
    r'412e03834cdd4bb0281c0a1ce12e35dbe36070df';

final class TransactionListViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          TransactionListViewModel,
          AsyncValue<List<Transaction>>,
          List<Transaction>,
          FutureOr<List<Transaction>>,
          ({int walletId, SortOrder sortOrder})
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
    required int walletId,
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
  late final _$args = ref.$arg as ({int walletId, SortOrder sortOrder});
  int get walletId => _$args.walletId;
  SortOrder get sortOrder => _$args.sortOrder;

  FutureOr<List<Transaction>> build({
    required int walletId,
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

@ProviderFor(transactionById)
const transactionByIdProvider = TransactionByIdFamily._();

final class TransactionByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<Transaction?>,
          Transaction?,
          FutureOr<Transaction?>
        >
    with $FutureModifier<Transaction?>, $FutureProvider<Transaction?> {
  const TransactionByIdProvider._({
    required TransactionByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'transactionByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionByIdHash();

  @override
  String toString() {
    return r'transactionByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Transaction?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Transaction?> create(Ref ref) {
    final argument = this.argument as int;
    return transactionById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionByIdHash() => r'b4fe7118bb7b16481961fe4f004c0f50fce1079f';

final class TransactionByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Transaction?>, int> {
  const TransactionByIdFamily._()
    : super(
        retry: null,
        name: r'transactionByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionByIdProvider call(int id) =>
      TransactionByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'transactionByIdProvider';
}
