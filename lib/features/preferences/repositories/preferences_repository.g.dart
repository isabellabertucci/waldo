// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(preferencesRepository)
const preferencesRepositoryProvider = PreferencesRepositoryProvider._();

final class PreferencesRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<IPreferencesRepository>,
          IPreferencesRepository,
          FutureOr<IPreferencesRepository>
        >
    with
        $FutureModifier<IPreferencesRepository>,
        $FutureProvider<IPreferencesRepository> {
  const PreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<IPreferencesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<IPreferencesRepository> create(Ref ref) {
    return preferencesRepository(ref);
  }
}

String _$preferencesRepositoryHash() =>
    r'0bf304db77c13d40e74284f3f510138e1262885b';
