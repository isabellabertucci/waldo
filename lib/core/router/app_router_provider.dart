import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_router.dart';
part 'app_router_provider.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: const DashboardRoute().location,
    routes: $appRoutes,
  );
}
