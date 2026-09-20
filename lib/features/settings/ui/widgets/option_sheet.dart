import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';

class Option<T> {
  const Option({required this.label, required this.value});

  final String label;
  final T value;
}

class OptionSheet<T> extends StatelessWidget {
  const OptionSheet({
    required this.title,
    required this.groupValue,
    required this.options,
    required this.onSelected,
    super.key,
  });

  final String title;
  final T groupValue;
  final List<Option<T>> options;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.textTheme.titleLarge),
            const SizedBox(height: Spacing.md),
            RadioGroup<T>(
              groupValue: groupValue,
              onChanged: (value) {
                onSelected(value);
                Navigator.of(context).pop();
              },
              child: Column(
                children: options
                    .map(
                      (option) => RadioListTile<T>(
                        title: Text(option.label),
                        value: option.value,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
