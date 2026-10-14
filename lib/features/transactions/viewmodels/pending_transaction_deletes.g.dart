// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_transaction_deletes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Transactions deleted but still inside their Undo window. Every list and
/// the dashboard leave them out, so a refetch during the window can't bring
/// them back, whichever screen the delete started from.

@ProviderFor(PendingTransactionDeletes)
const pendingTransactionDeletesProvider = PendingTransactionDeletesProvider._();

/// Transactions deleted but still inside their Undo window. Every list and
/// the dashboard leave them out, so a refetch during the window can't bring
/// them back, whichever screen the delete started from.
final class PendingTransactionDeletesProvider
    extends $NotifierProvider<PendingTransactionDeletes, Set<int>> {
  /// Transactions deleted but still inside their Undo window. Every list and
  /// the dashboard leave them out, so a refetch during the window can't bring
  /// them back, whichever screen the delete started from.
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
  Override overrideWithValue(Set<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<int>>(value),
    );
  }
}

String _$pendingTransactionDeletesHash() =>
    r'299eb87829976323b28d9c1d29bf915ab6f1ced3';

/// Transactions deleted but still inside their Undo window. Every list and
/// the dashboard leave them out, so a refetch during the window can't bring
/// them back, whichever screen the delete started from.

abstract class _$PendingTransactionDeletes extends $Notifier<Set<int>> {
  Set<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<int>, Set<int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<int>, Set<int>>,
              Set<int>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
