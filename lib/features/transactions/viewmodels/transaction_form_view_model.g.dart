// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_form_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransactionFormViewModel)
const transactionFormViewModelProvider = TransactionFormViewModelFamily._();

final class TransactionFormViewModelProvider
    extends $NotifierProvider<TransactionFormViewModel, TransactionFormState> {
  const TransactionFormViewModelProvider._({
    required TransactionFormViewModelFamily super.from,
    required (Transaction?, {int? initialWalletId}) super.argument,
  }) : super(
         retry: null,
         name: r'transactionFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionFormViewModelHash();

  @override
  String toString() {
    return r'transactionFormViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  TransactionFormViewModel create() => TransactionFormViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionFormViewModelHash() =>
    r'9c5545de04c27ac6022368a9674ba1bda03672fe';

final class TransactionFormViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          TransactionFormViewModel,
          TransactionFormState,
          TransactionFormState,
          TransactionFormState,
          (Transaction?, {int? initialWalletId})
        > {
  const TransactionFormViewModelFamily._()
    : super(
        retry: null,
        name: r'transactionFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionFormViewModelProvider call(
    Transaction? existingTransaction, {
    int? initialWalletId,
  }) => TransactionFormViewModelProvider._(
    argument: (existingTransaction, initialWalletId: initialWalletId),
    from: this,
  );

  @override
  String toString() => r'transactionFormViewModelProvider';
}

abstract class _$TransactionFormViewModel
    extends $Notifier<TransactionFormState> {
  late final _$args = ref.$arg as (Transaction?, {int? initialWalletId});
  Transaction? get existingTransaction => _$args.$1;
  int? get initialWalletId => _$args.initialWalletId;

  TransactionFormState build(
    Transaction? existingTransaction, {
    int? initialWalletId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args.$1, initialWalletId: _$args.initialWalletId);
    final ref = this.ref as $Ref<TransactionFormState, TransactionFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TransactionFormState, TransactionFormState>,
              TransactionFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
