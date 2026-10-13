// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_hidden_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether amounts are masked app-wide (the eye toggle).

@ProviderFor(BalanceHidden)
const balanceHiddenProvider = BalanceHiddenProvider._();

/// Whether amounts are masked app-wide (the eye toggle).
final class BalanceHiddenProvider
    extends $NotifierProvider<BalanceHidden, bool> {
  /// Whether amounts are masked app-wide (the eye toggle).
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

String _$balanceHiddenHash() => r'8e6999447b921190807ba6236001004fbbcc427e';

/// Whether amounts are masked app-wide (the eye toggle).

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
