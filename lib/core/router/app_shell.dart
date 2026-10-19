import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_nav_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      // No fade on `body`: sheets and buttons rendered inside it would fade too.
      body: navigationShell,
      bottomNavigationBar: AppNavBar(
        currentIndex: currentIndex,
        // Tapping the current tab again pops that branch back to its root.
        onSelect: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == currentIndex,
        ),
      ),
    );
  }
}
