// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_hidden_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether amounts are masked app-wide (the eye toggle), as saved in the
/// preferences; rebuilt from them whenever a screen asks again.

@ProviderFor(BalanceHidden)
const balanceHiddenProvider = BalanceHiddenProvider._();

/// Whether amounts are masked app-wide (the eye toggle), as saved in the
/// preferences; rebuilt from them whenever a screen asks again.
final class BalanceHiddenProvider
    extends $NotifierProvider<BalanceHidden, bool> {
  /// Whether amounts are masked app-wide (the eye toggle), as saved in the
  /// preferences; rebuilt from them whenever a screen asks again.
  const BalanceHiddenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'balanceHiddenProvider',
        isAutoDispose: true,
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

String _$balanceHiddenHash() => r'3072bdb191ade55159ef2685b8207ab6a2e52c7b';

/// Whether amounts are masked app-wide (the eye toggle), as saved in the
/// preferences; rebuilt from them whenever a screen asks again.

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
