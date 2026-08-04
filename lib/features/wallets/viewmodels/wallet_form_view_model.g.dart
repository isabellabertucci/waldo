// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_form_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WalletFormViewModel)
const walletFormViewModelProvider = WalletFormViewModelFamily._();

final class WalletFormViewModelProvider
    extends $NotifierProvider<WalletFormViewModel, WalletFormState> {
  const WalletFormViewModelProvider._({
    required WalletFormViewModelFamily super.from,
    required Wallet? super.argument,
  }) : super(
         retry: null,
         name: r'walletFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$walletFormViewModelHash();

  @override
  String toString() {
    return r'walletFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WalletFormViewModel create() => WalletFormViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WalletFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WalletFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WalletFormViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$walletFormViewModelHash() =>
    r'2200ea9a8e11dafe7490175a4087c4acf5d630a9';

final class WalletFormViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          WalletFormViewModel,
          WalletFormState,
          WalletFormState,
          WalletFormState,
          Wallet?
        > {
  const WalletFormViewModelFamily._()
    : super(
        retry: null,
        name: r'walletFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WalletFormViewModelProvider call(Wallet? existingWallet) =>
      WalletFormViewModelProvider._(argument: existingWallet, from: this);

  @override
  String toString() => r'walletFormViewModelProvider';
}

abstract class _$WalletFormViewModel extends $Notifier<WalletFormState> {
  late final _$args = ref.$arg as Wallet?;
  Wallet? get existingWallet => _$args;

  WalletFormState build(Wallet? existingWallet);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<WalletFormState, WalletFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WalletFormState, WalletFormState>,
              WalletFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
