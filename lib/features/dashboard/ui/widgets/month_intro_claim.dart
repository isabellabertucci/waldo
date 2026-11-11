import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';

/// Lets a Home widget play its [MonthIntro] once per month.
mixin MonthIntroClaim<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// True when [intro] hasn't played for [month] yet; it then counts as
  /// played.
  bool claimMonthIntro(MonthIntro intro, DateTime month) {
    if (ref.read(playedMonthProvider(intro)) == month) return false;
    // After this frame: a provider can't change while widgets build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(playedMonthProvider(intro).notifier).mark(month);
    });
    return true;
  }
}
