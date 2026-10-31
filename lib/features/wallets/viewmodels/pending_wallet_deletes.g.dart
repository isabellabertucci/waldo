// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_wallet_deletes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wallets deleted but still inside their Undo window. Every screen leaves
/// them and their transactions out, as the delete will.

@ProviderFor(PendingWalletDeletes)
const pendingWalletDeletesProvider = PendingWalletDeletesProvider._();

/// Wallets deleted but still inside their Undo window. Every screen leaves
/// them and their transactions out, as the delete will.
final class PendingWalletDeletesProvider
    extends $NotifierProvider<PendingWalletDeletes, Set<int>> {
  /// Wallets deleted but still inside their Undo window. Every screen leaves
  /// them and their transactions out, as the delete will.
  const PendingWalletDeletesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingWalletDeletesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingWalletDeletesHash();

  @$internal
  @override
  PendingWalletDeletes create() => PendingWalletDeletes();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<int>>(value),
    );
  }
}

String _$pendingWalletDeletesHash() =>
    r'33b1b9d319372b90aa2423fe103d6154ecd1cb97';

/// Wallets deleted but still inside their Undo window. Every screen leaves
/// them and their transactions out, as the delete will.

abstract class _$PendingWalletDeletes extends $Notifier<Set<int>> {
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
