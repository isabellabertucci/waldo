// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'just_added_wallet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The wallet just created, until [landing] shows its card landing; then
/// cleared, so it never lands there twice.

@ProviderFor(JustAddedWallet)
const justAddedWalletProvider = JustAddedWalletFamily._();

/// The wallet just created, until [landing] shows its card landing; then
/// cleared, so it never lands there twice.
final class JustAddedWalletProvider
    extends $NotifierProvider<JustAddedWallet, int?> {
  /// The wallet just created, until [landing] shows its card landing; then
  /// cleared, so it never lands there twice.
  const JustAddedWalletProvider._({
    required JustAddedWalletFamily super.from,
    required WalletLanding super.argument,
  }) : super(
         retry: null,
         name: r'justAddedWalletProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$justAddedWalletHash();

  @override
  String toString() {
    return r'justAddedWalletProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  JustAddedWallet create() => JustAddedWallet();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is JustAddedWalletProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$justAddedWalletHash() => r'918abb39ddb69cfd58d654374a78c29f4536d08c';

/// The wallet just created, until [landing] shows its card landing; then
/// cleared, so it never lands there twice.

final class JustAddedWalletFamily extends $Family
    with
        $ClassFamilyOverride<JustAddedWallet, int?, int?, int?, WalletLanding> {
  const JustAddedWalletFamily._()
    : super(
        retry: null,
        name: r'justAddedWalletProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The wallet just created, until [landing] shows its card landing; then
  /// cleared, so it never lands there twice.

  JustAddedWalletProvider call(WalletLanding landing) =>
      JustAddedWalletProvider._(argument: landing, from: this);

  @override
  String toString() => r'justAddedWalletProvider';
}

/// The wallet just created, until [landing] shows its card landing; then
/// cleared, so it never lands there twice.

abstract class _$JustAddedWallet extends $Notifier<int?> {
  late final _$args = ref.$arg as WalletLanding;
  WalletLanding get landing => _$args;

  int? build(WalletLanding landing);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
