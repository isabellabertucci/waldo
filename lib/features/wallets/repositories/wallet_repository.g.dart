// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(walletRepository)
const walletRepositoryProvider = WalletRepositoryProvider._();

final class WalletRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<IWalletRepository>,
          IWalletRepository,
          FutureOr<IWalletRepository>
        >
    with
        $FutureModifier<IWalletRepository>,
        $FutureProvider<IWalletRepository> {
  const WalletRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<IWalletRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<IWalletRepository> create(Ref ref) {
    return walletRepository(ref);
  }
}

String _$walletRepositoryHash() => r'1fd90711b75cf273f097d2acd21ba01cd83a1bf8';
