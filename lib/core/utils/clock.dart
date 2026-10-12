import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

/// Where the app reads "now" from; golden tests override it with a fixed date.
/// A function, so the long-lived provider never freezes time.
@Riverpod(keepAlive: true)
DateTime Function() clock(Ref ref) => DateTime.now;
