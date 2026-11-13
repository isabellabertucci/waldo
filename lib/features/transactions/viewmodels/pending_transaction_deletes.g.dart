// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_transaction_deletes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Transactions deleted but still inside their Undo window, by id. Every
/// list leaves them out and every balance and total discounts them, so the
/// numbers agree whichever screen the delete started from.

@ProviderFor(PendingTransactionDeletes)
const pendingTransactionDeletesProvider = PendingTransactionDeletesProvider._();

/// Transactions deleted but still inside their Undo window, by id. Every
/// list leaves them out and every balance and total discounts them, so the
/// numbers agree whichever screen the delete started from.
final class PendingTransactionDeletesProvider
    extends
        $NotifierProvider<PendingTransactionDeletes, Map<int, Transaction>> {
  /// Transactions deleted but still inside their Undo window, by id. Every
  /// list leaves them out and every balance and total discounts them, so the
  /// numbers agree whichever screen the delete started from.
  const PendingTransactionDeletesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingTransactionDeletesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingTransactionDeletesHash();

  @$internal
  @override
  PendingTransactionDeletes create() => PendingTransactionDeletes();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, Transaction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, Transaction>>(value),
    );
  }
}

String _$pendingTransactionDeletesHash() =>
    r'e99e5acc48fdef6dd037ea985c8ba243037a2610';

/// Transactions deleted but still inside their Undo window, by id. Every
/// list leaves them out and every balance and total discounts them, so the
/// numbers agree whichever screen the delete started from.

abstract class _$PendingTransactionDeletes
    extends $Notifier<Map<int, Transaction>> {
  Map<int, Transaction> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Map<int, Transaction>, Map<int, Transaction>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<int, Transaction>, Map<int, Transaction>>,
              Map<int, Transaction>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
