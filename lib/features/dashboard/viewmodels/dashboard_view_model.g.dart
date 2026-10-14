// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The month the dashboard is currently showing stats for. Defaults to the
/// current month; changeable via the month picker in the dashboard's app bar.

@ProviderFor(SelectedDashboardMonth)
const selectedDashboardMonthProvider = SelectedDashboardMonthProvider._();

/// The month the dashboard is currently showing stats for. Defaults to the
/// current month; changeable via the month picker in the dashboard's app bar.
final class SelectedDashboardMonthProvider
    extends $NotifierProvider<SelectedDashboardMonth, DateTime> {
  /// The month the dashboard is currently showing stats for. Defaults to the
  /// current month; changeable via the month picker in the dashboard's app bar.
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
/// current month; changeable via the month picker in the dashboard's app bar.

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
    r'8115fe35077d88bf7f40c6383a75c5ab963f13e5';

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
