import 'package:flutter/material.dart';
import 'package:waldo/core/router/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
