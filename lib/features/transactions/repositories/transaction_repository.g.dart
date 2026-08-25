// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transactionRepository)
const transactionRepositoryProvider = TransactionRepositoryProvider._();

final class TransactionRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ITransactionRepository>,
          ITransactionRepository,
          FutureOr<ITransactionRepository>
        >
    with
        $FutureModifier<ITransactionRepository>,
        $FutureProvider<ITransactionRepository> {
  const TransactionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ITransactionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ITransactionRepository> create(Ref ref) {
    return transactionRepository(ref);
  }
}

String _$transactionRepositoryHash() =>
    r'8e1f6d05ecc31880c6da1d8086988bed9a7dc199';
