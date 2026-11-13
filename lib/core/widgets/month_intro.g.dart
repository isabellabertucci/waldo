// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_intro.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The month [intro] last played for this session, so scrolling back to it,
/// or a new figure on it, doesn't play it again.

@ProviderFor(PlayedMonth)
const playedMonthProvider = PlayedMonthFamily._();

/// The month [intro] last played for this session, so scrolling back to it,
/// or a new figure on it, doesn't play it again.
final class PlayedMonthProvider
    extends $NotifierProvider<PlayedMonth, DateTime?> {
  /// The month [intro] last played for this session, so scrolling back to it,
  /// or a new figure on it, doesn't play it again.
  const PlayedMonthProvider._({
    required PlayedMonthFamily super.from,
    required MonthIntro super.argument,
  }) : super(
         retry: null,
         name: r'playedMonthProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playedMonthHash();

  @override
  String toString() {
    return r'playedMonthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PlayedMonth create() => PlayedMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PlayedMonthProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playedMonthHash() => r'df0165883c6acb980bbf4a76e1b5dfebbcf69e3e';

/// The month [intro] last played for this session, so scrolling back to it,
/// or a new figure on it, doesn't play it again.

final class PlayedMonthFamily extends $Family
    with
        $ClassFamilyOverride<
          PlayedMonth,
          DateTime?,
          DateTime?,
          DateTime?,
          MonthIntro
        > {
  const PlayedMonthFamily._()
    : super(
        retry: null,
        name: r'playedMonthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The month [intro] last played for this session, so scrolling back to it,
  /// or a new figure on it, doesn't play it again.

  PlayedMonthProvider call(MonthIntro intro) =>
      PlayedMonthProvider._(argument: intro, from: this);

  @override
  String toString() => r'playedMonthProvider';
}

/// The month [intro] last played for this session, so scrolling back to it,
/// or a new figure on it, doesn't play it again.

abstract class _$PlayedMonth extends $Notifier<DateTime?> {
  late final _$args = ref.$arg as MonthIntro;
  MonthIntro get intro => _$args;

  DateTime? build(MonthIntro intro);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime?, DateTime?>,
              DateTime?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
