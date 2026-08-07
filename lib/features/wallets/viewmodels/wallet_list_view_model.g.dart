// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WalletListViewModel)
const walletListViewModelProvider = WalletListViewModelFamily._();

final class WalletListViewModelProvider
    extends $AsyncNotifierProvider<WalletListViewModel, List<Wallet>> {
  const WalletListViewModelProvider._({
    required WalletListViewModelFamily super.from,
    required SortOrder super.argument,
  }) : super(
         retry: null,
         name: r'walletListViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$walletListViewModelHash();

  @override
  String toString() {
    return r'walletListViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WalletListViewModel create() => WalletListViewModel();

  @override
  bool operator ==(Object other) {
    return other is WalletListViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$walletListViewModelHash() =>
    r'9d180797d4e239a22a9aa9a65d7b105de42ceee0';

final class WalletListViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          WalletListViewModel,
          AsyncValue<List<Wallet>>,
          List<Wallet>,
          FutureOr<List<Wallet>>,
          SortOrder
        > {
  const WalletListViewModelFamily._()
    : super(
        retry: null,
        name: r'walletListViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WalletListViewModelProvider call({SortOrder sortOrder = SortOrder.desc}) =>
      WalletListViewModelProvider._(argument: sortOrder, from: this);

  @override
  String toString() => r'walletListViewModelProvider';
}

abstract class _$WalletListViewModel extends $AsyncNotifier<List<Wallet>> {
  late final _$args = ref.$arg as SortOrder;
  SortOrder get sortOrder => _$args;

  FutureOr<List<Wallet>> build({SortOrder sortOrder = SortOrder.desc});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(sortOrder: _$args);
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
