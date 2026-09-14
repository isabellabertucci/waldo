// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PreferencesViewModel)
const preferencesViewModelProvider = PreferencesViewModelProvider._();

final class PreferencesViewModelProvider
    extends $AsyncNotifierProvider<PreferencesViewModel, Preferences> {
  const PreferencesViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesViewModelHash();

  @$internal
  @override
  PreferencesViewModel create() => PreferencesViewModel();
}

String _$preferencesViewModelHash() =>
    r'3d57a2d6258b79edb57132a52990bd483a345339';

abstract class _$PreferencesViewModel extends $AsyncNotifier<Preferences> {
  FutureOr<Preferences> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<Preferences>, Preferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Preferences>, Preferences>,
              AsyncValue<Preferences>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
