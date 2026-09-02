import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              title: const Text('Dark mode'),
              trailing: Switch.adaptive(
                value: themeMode == ThemeMode.dark,
                onChanged: (value) {
                  ref
                      .read(themeModeProvider.notifier)
                      .set(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
