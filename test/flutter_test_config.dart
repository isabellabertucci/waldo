import 'dart:async';

import 'package:alchemist/alchemist.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      // Only the platform-independent CI goldens are kept in git (see
      // .gitignore) - per-machine macOS goldens can't be shared, so a fresh
      // clone would always fail them.
      platformGoldensConfig: PlatformGoldensConfig(enabled: false),
    ),
    run: testMain,
  );
}
