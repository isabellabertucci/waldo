// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_category_deletes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Categories deleted but still inside their Undo window. Every screen
/// already shows their transactions in "Others", where the delete moves them.

@ProviderFor(PendingCategoryDeletes)
const pendingCategoryDeletesProvider = PendingCategoryDeletesProvider._();

/// Categories deleted but still inside their Undo window. Every screen
/// already shows their transactions in "Others", where the delete moves them.
final class PendingCategoryDeletesProvider
    extends $NotifierProvider<PendingCategoryDeletes, Set<int>> {
  /// Categories deleted but still inside their Undo window. Every screen
  /// already shows their transactions in "Others", where the delete moves them.
  const PendingCategoryDeletesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingCategoryDeletesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingCategoryDeletesHash();

  @$internal
  @override
  PendingCategoryDeletes create() => PendingCategoryDeletes();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<int>>(value),
    );
  }
}

String _$pendingCategoryDeletesHash() =>
    r'da4837f5431ca5806b1f61ec13a41e3b2d77ba28';

/// Categories deleted but still inside their Undo window. Every screen
/// already shows their transactions in "Others", where the delete moves them.

abstract class _$PendingCategoryDeletes extends $Notifier<Set<int>> {
  Set<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<int>, Set<int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<int>, Set<int>>,
              Set<int>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
