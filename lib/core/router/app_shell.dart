import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waldo/core/widgets/page_width.dart';

import 'app_nav_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      // The navbar floats: pages scroll on behind it, with no band of
      // background cutting them off above it. They get its height as bottom
      // padding, to scroll their last row clear of it.
      extendBody: true,
      // No fade on `body`: sheets and buttons rendered inside it would fade too.
      body: PageWidth(child: navigationShell),
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
