// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(walletById)
const walletByIdProvider = WalletByIdFamily._();

final class WalletByIdProvider
    extends $FunctionalProvider<AsyncValue<Wallet?>, Wallet?, FutureOr<Wallet?>>
    with $FutureModifier<Wallet?>, $FutureProvider<Wallet?> {
  const WalletByIdProvider._({
    required WalletByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'walletByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$walletByIdHash();

  @override
  String toString() {
    return r'walletByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Wallet?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Wallet?> create(Ref ref) {
    final argument = this.argument as int;
    return walletById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$walletByIdHash() => r'cc05770a3515d1e40862684e0d20e4f9334ab608';

final class WalletByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Wallet?>, int> {
  const WalletByIdFamily._()
    : super(
        retry: null,
        name: r'walletByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WalletByIdProvider call(int id) =>
      WalletByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'walletByIdProvider';
}
