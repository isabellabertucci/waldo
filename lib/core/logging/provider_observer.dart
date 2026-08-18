import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:logging/logging.dart';

final _log = Logger('waldo');

final class AppProviderObserver extends ProviderObserver {
  const AppProviderObserver();

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    if (error is ProviderException) {
      return;
    }

    final providerName =
        context.provider.name ?? context.provider.runtimeType.toString();
    _log.severe('Provider failed: $providerName', error, stackTrace);
  }
}
