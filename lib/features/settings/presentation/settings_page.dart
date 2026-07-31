import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Settings'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => const AccountsRoute().push(context),
              child: const Text('Accounts (standalone route)'),
            ),
          ],
        ),
      ),
    );
  }
}
