// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_hidden_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether balance figures are masked app-wide. The eye toggle on the
/// dashboard, wallets and per-wallet transactions screens all read and
/// flip this same value, so hiding the balance on one screen hides it
/// on all of them.

@ProviderFor(BalanceHidden)
const balanceHiddenProvider = BalanceHiddenProvider._();

/// Whether balance figures are masked app-wide. The eye toggle on the
/// dashboard, wallets and per-wallet transactions screens all read and
/// flip this same value, so hiding the balance on one screen hides it
/// on all of them.
final class BalanceHiddenProvider
    extends $NotifierProvider<BalanceHidden, bool> {
  /// Whether balance figures are masked app-wide. The eye toggle on the
  /// dashboard, wallets and per-wallet transactions screens all read and
  /// flip this same value, so hiding the balance on one screen hides it
  /// on all of them.
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

/// Whether balance figures are masked app-wide. The eye toggle on the
/// dashboard, wallets and per-wallet transactions screens all read and
/// flip this same value, so hiding the balance on one screen hides it
/// on all of them.

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
