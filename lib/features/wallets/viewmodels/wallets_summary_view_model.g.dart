// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallets_summary_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(walletsSummaryViewModel)
const walletsSummaryViewModelProvider = WalletsSummaryViewModelProvider._();

final class WalletsSummaryViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<WalletsSummary>,
          WalletsSummary,
          FutureOr<WalletsSummary>
        >
    with $FutureModifier<WalletsSummary>, $FutureProvider<WalletsSummary> {
  const WalletsSummaryViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletsSummaryViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletsSummaryViewModelHash();

  @$internal
  @override
  $FutureProviderElement<WalletsSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WalletsSummary> create(Ref ref) {
    return walletsSummaryViewModel(ref);
  }
}

String _$walletsSummaryViewModelHash() =>
    r'bf322acfaf74ab54581eae9e3ab14c19b197dddb';
