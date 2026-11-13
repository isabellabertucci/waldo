import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'month_intro.g.dart';

/// What plays on Home when it shows a new month.
enum MonthIntro { cashFlowDraw }

/// The month [intro] last played for this session, so scrolling back to it,
/// or a new figure on it, doesn't play it again.
@Riverpod(keepAlive: true)
class PlayedMonth extends _$PlayedMonth {
  @override
  DateTime? build(MonthIntro intro) => null;

  void mark(DateTime month) => state = month;
}

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
