// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the app reads "now" from. The real app uses the device clock;
/// golden tests override it with a fixed date so their screenshots don't
/// change from one day to the next.
///
/// Returns a function rather than a [DateTime] so the provider can stay
/// alive for the whole app without freezing time at the moment it was
/// first read.

@ProviderFor(clock)
const clockProvider = ClockProvider._();

/// Where the app reads "now" from. The real app uses the device clock;
/// golden tests override it with a fixed date so their screenshots don't
/// change from one day to the next.
///
/// Returns a function rather than a [DateTime] so the provider can stay
/// alive for the whole app without freezing time at the moment it was
/// first read.

final class ClockProvider
    extends
        $FunctionalProvider<
          DateTime Function(),
          DateTime Function(),
          DateTime Function()
        >
    with $Provider<DateTime Function()> {
  /// Where the app reads "now" from. The real app uses the device clock;
  /// golden tests override it with a fixed date so their screenshots don't
  /// change from one day to the next.
  ///
  /// Returns a function rather than a [DateTime] so the provider can stay
  /// alive for the whole app without freezing time at the moment it was
  /// first read.
  const ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<DateTime Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTime Function() create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime Function()>(value),
    );
  }
}

String _$clockHash() => r'3f65ad34ac6fcd532de9004042bdf2ed2bd85b13';
