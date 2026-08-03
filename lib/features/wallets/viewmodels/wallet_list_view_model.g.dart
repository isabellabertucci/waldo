// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WalletListViewModel)
const walletListViewModelProvider = WalletListViewModelProvider._();

final class WalletListViewModelProvider
    extends $AsyncNotifierProvider<WalletListViewModel, List<Wallet>> {
  const WalletListViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletListViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletListViewModelHash();

  @$internal
  @override
  WalletListViewModel create() => WalletListViewModel();
}

String _$walletListViewModelHash() =>
    r'67f11a4ec49db915d2cefa6c43aacb48db0506a8';

abstract class _$WalletListViewModel extends $AsyncNotifier<List<Wallet>> {
  FutureOr<List<Wallet>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Wallet>>, List<Wallet>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Wallet>>, List<Wallet>>,
              AsyncValue<List<Wallet>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
