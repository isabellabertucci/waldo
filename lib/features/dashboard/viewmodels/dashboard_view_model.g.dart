// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The month the dashboard is currently showing stats for. Defaults to the
/// current month; changeable via the month row at the top of the dashboard.

@ProviderFor(SelectedDashboardMonth)
const selectedDashboardMonthProvider = SelectedDashboardMonthProvider._();

/// The month the dashboard is currently showing stats for. Defaults to the
/// current month; changeable via the month row at the top of the dashboard.
final class SelectedDashboardMonthProvider
    extends $NotifierProvider<SelectedDashboardMonth, DateTime> {
  /// The month the dashboard is currently showing stats for. Defaults to the
  /// current month; changeable via the month row at the top of the dashboard.
  const SelectedDashboardMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDashboardMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDashboardMonthHash();

  @$internal
  @override
  SelectedDashboardMonth create() => SelectedDashboardMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedDashboardMonthHash() =>
    r'd5019b5c2c704cac325a1dff9de2e6866455aeaa';

/// The month the dashboard is currently showing stats for. Defaults to the
/// current month; changeable via the month row at the top of the dashboard.

abstract class _$SelectedDashboardMonth extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

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

@ProviderFor(DashboardViewModel)
const dashboardViewModelProvider = DashboardViewModelProvider._();

final class DashboardViewModelProvider
    extends $AsyncNotifierProvider<DashboardViewModel, DashboardData> {
  const DashboardViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardViewModelHash();

  @$internal
  @override
  DashboardViewModel create() => DashboardViewModel();
}

String _$dashboardViewModelHash() =>
    r'd7e66078d2ea1a608f81286b186c59f0a5fd8e13';

abstract class _$DashboardViewModel extends $AsyncNotifier<DashboardData> {
  FutureOr<DashboardData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<DashboardData>, DashboardData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DashboardData>, DashboardData>,
              AsyncValue<DashboardData>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
