// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_hidden_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether amounts are masked app-wide (the eye toggle). Kept alive, so it
/// can't reset while no screen happens to be watching it.

@ProviderFor(BalanceHidden)
const balanceHiddenProvider = BalanceHiddenProvider._();

/// Whether amounts are masked app-wide (the eye toggle). Kept alive, so it
/// can't reset while no screen happens to be watching it.
final class BalanceHiddenProvider
    extends $NotifierProvider<BalanceHidden, bool> {
  /// Whether amounts are masked app-wide (the eye toggle). Kept alive, so it
  /// can't reset while no screen happens to be watching it.
  const BalanceHiddenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'balanceHiddenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$balanceHiddenHash();

  @$internal
  @override
  BalanceHidden create() => BalanceHidden();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$balanceHiddenHash() => r'dcb990b7a8b6af95a2e36a26f4bbcb2b710acbba';

/// Whether amounts are masked app-wide (the eye toggle). Kept alive, so it
/// can't reset while no screen happens to be watching it.

abstract class _$BalanceHidden extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
