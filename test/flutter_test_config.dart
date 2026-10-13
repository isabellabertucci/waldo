import 'dart:async';
import 'dart:ui' as ui;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final comparator = goldenFileComparator;
  if (comparator is LocalFileComparator) {
    goldenFileComparator = _RoundingTolerantComparator(
      comparator.basedir.resolve('flutter_test_config.dart'),
    );
  }

  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      // Only the CI goldens are in git, so per-machine macOS goldens are off.
      platformGoldensConfig: PlatformGoldensConfig(enabled: false),
    ),
    run: testMain,
  );
}

/// Linux and macOS round blended colors (e.g. a ShaderMask fade) a level
/// apart, so a golden made on one fails on the other by invisible pixels.
/// This passes images whose channels differ by at most [_maxChannelDelta].
class _RoundingTolerantComparator extends LocalFileComparator {
  _RoundingTolerantComparator(super.testFile);

  static const _maxChannelDelta = 2;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final goldenBytes = Uint8List.fromList(await getGoldenBytes(golden));
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      goldenBytes,
    );
    if (result.passed || await _onlyRounding(imageBytes, goldenBytes)) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }

  Future<bool> _onlyRounding(Uint8List a, Uint8List b) async {
    final imageA = await _decode(a);
    final imageB = await _decode(b);
    try {
      if (imageA.width != imageB.width || imageA.height != imageB.height) {
        return false;
      }
      final pixelsA = await imageA.toByteData();
      final pixelsB = await imageB.toByteData();
      if (pixelsA == null || pixelsB == null) return false;
      for (var i = 0; i < pixelsA.lengthInBytes; i++) {
        final delta = pixelsA.getUint8(i) - pixelsB.getUint8(i);
        if (delta.abs() > _maxChannelDelta) return false;
      }
      return true;
    } finally {
      imageA.dispose();
      imageB.dispose();
    }
  }

  Future<ui.Image> _decode(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }
}
