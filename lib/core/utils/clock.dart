import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

/// Where the app reads "now" from. The real app uses the device clock;
/// golden tests override it with a fixed date so their screenshots don't
/// change from one day to the next.
///
/// Returns a function rather than a [DateTime] so the provider can stay
/// alive for the whole app without freezing time at the moment it was
/// first read.
@Riverpod(keepAlive: true)
DateTime Function() clock(Ref ref) => DateTime.now;
