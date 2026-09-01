import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state.dart';
import '../models/category.dart';
import '../viewmodels/category_list_view_model.dart';
import 'widgets/category_form_sheet.dart';
import 'package:waldo/l10n/app_localizations.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(categoryListViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.categories)),
      body: switch (categoriesAsync) {
        AsyncError() => Center(child: Text(l10n.categoriesError)),
        AsyncData(:final value) => _CategoriesBody(categories: value),
        _ => const Center(child: CircularProgressIndicator()),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const CategoryFormSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoriesBody extends ConsumerWidget {
  const _CategoriesBody({required this.categories});

  final List<Category> categories;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteCategoryConfirm(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final viewModel = ref.read(categoryListViewModelProvider.notifier);

    if (!viewModel.hideCategory(category.id!)) return;

    var undone = false;

    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.categoryDeleted),
        duration: const Duration(seconds: 5),
        persist: false,
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () {
            undone = true;
            viewModel.restoreCategory();
          },
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 5));

    if (undone) return;

    try {
      await viewModel.confirmDelete(category.id!);
    } catch (_) {
      viewModel.restoreCategory();
      messenger.showSnackBar(SnackBar(content: Text(l10n.categoryDeleteError)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (categories.isEmpty) {
      return EmptyState(
        icon: Icons.category_outlined,
        title: l10n.noCategoriesYet,
        subtitle: l10n.addFirstCategory,
      );
    }

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          title: Text(category.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => CategoryFormSheet(category: category),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, ref, category),
              ),
            ],
          ),
        );
      },
    );
  }
}
