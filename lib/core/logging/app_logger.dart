import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

bool _loggingInitialized = false;

void initLogging() {
  if (_loggingInitialized) return;
  _loggingInitialized = true;

  Logger.root.level = kReleaseMode ? Level.WARNING : Level.ALL;

  Logger.root.onRecord.listen((record) {
    developer.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
      error: record.error,
      stackTrace: record.stackTrace,
    );

    if (kDebugMode) {
      debugPrint(
        '[${record.level.name}] ${record.loggerName}: ${record.message}',
      );
    }
  });
}

bool _globalErrorLoggersInstalled = false;

void installGlobalErrorLoggers() {
  if (_globalErrorLoggersInstalled) return;
  _globalErrorLoggersInstalled = true;

  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    Logger.root.severe(
      'FlutterError: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
    previousOnError?.call(details);
  };

  final previousPlatformOnError = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    Logger.root.severe('Unhandled platform error', error, stackTrace);
    return previousPlatformOnError?.call(error, stackTrace) ?? false;
  };
}
