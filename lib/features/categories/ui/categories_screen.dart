import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/circle_icon_button.dart';
import 'package:waldo/core/widgets/confirmation_dialog.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/surface_card.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../categories_x.dart';
import '../models/category.dart';
import '../viewmodels/category_list_view_model.dart';
import 'widgets/category_form_sheet.dart';

enum _CategoryAction { edit, delete }

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _openForm(BuildContext context, {Category? category}) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => CategoryFormSheet(category: category),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final categoriesAsync = ref.watch(categoryListViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Same header pattern as the per-wallet transactions screen: a
            // plain circle to go back, the dashed-stitch pill for "add".
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.pageMargin,
                Spacing.xs,
                Spacing.pageMargin,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleIconButton(
                    tooltip: l10n.back,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(AppIcons.back),
                  ),
                  DashedStitchButton(
                    icon: const Icon(AppIcons.add),
                    tooltip: l10n.newCategory,
                    onPressed: () => _openForm(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.pageMargin,
              ),
              child: Text(
                l10n.categories,
                style: context.headlineSmBold.copyWith(color: colors.onSurface),
              ),
            ),
            Expanded(
              child: switch (categoriesAsync) {
                AsyncValue(:final value?) => _CategoriesBody(
                  categories: value,
                  onEdit: (category) => _openForm(context, category: category),
                ),
                AsyncValue(hasError: true) => Center(
                  child: Text(l10n.categoriesError),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesBody extends ConsumerWidget {
  const _CategoriesBody({required this.categories, required this.onEdit});

  final List<Category> categories;
  final ValueChanged<Category> onEdit;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await ConfirmationDialog.show(
      context,
      title: l10n.deleteCategory,
      content: l10n.deleteCategoryConfirm(category.name),
      confirmLabel: l10n.delete,
    );

    if (!confirmed) return;

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
    final builtIn = categories.where((c) => c.isDefault).toList();
    final custom = categories.where((c) => !c.isDefault).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.pageMargin,
        Spacing.md,
        Spacing.pageMargin,
        Spacing.lg,
      ),
      children: [
        _SectionLabel(title: l10n.categoriesDefaultSection),
        _CategoryGroup(categories: builtIn),
        if (custom.isNotEmpty) ...[
          const SizedBox(height: Spacing.lg),
          _SectionLabel(title: l10n.categoriesCustomSection),
          _CategoryGroup(
            categories: custom,
            onEdit: onEdit,
            onDelete: (category) => _confirmDelete(context, ref, category),
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm, left: Spacing.xxs),
      child: Text(
        title.toUpperCase(),
        style: context.labelXs.copyWith(
          color: context.appColors.onSurfaceVariant,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

/// A [SurfaceCard] of category rows with a hairline divider between each -
/// the same statement-card look as the transaction lists. Rows only get the
/// edit/delete menu when [onEdit]/[onDelete] are given (custom categories).
class _CategoryGroup extends StatelessWidget {
  const _CategoryGroup({required this.categories, this.onEdit, this.onDelete});

  final List<Category> categories;
  final ValueChanged<Category>? onEdit;
  final ValueChanged<Category>? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SurfaceCard(
      child: Column(
        children: [
          for (var i = 0; i < categories.length; i++) ...[
            _CategoryRow(
              category: categories[i],
              onEdit: onEdit == null ? null : () => onEdit!(categories[i]),
              onDelete: onDelete == null
                  ? null
                  : () => onDelete!(categories[i]),
            ),
            if (i != categories.length - 1)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
                color: colors.onSurfaceVariant.withValues(alpha: 0.1),
              ),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, this.onEdit, this.onDelete});

  final Category category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final isCustom = !category.isDefault;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        isCustom ? Spacing.xs : Spacing.md,
        Spacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              category.type.icon,
              size: IconSize.md,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCustom ? category.name : category.type.label(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyMdBold,
                ),
                if (isCustom)
                  Text(
                    category.type.label(l10n),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (isCustom)
            PopupMenuButton<_CategoryAction>(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Rounded.md),
              ),
              icon: Icon(
                AppIcons.more,
                size: IconSize.lg,
                color: colors.onSurfaceVariant,
              ),
              onSelected: (action) => switch (action) {
                _CategoryAction.edit => onEdit?.call(),
                _CategoryAction.delete => onDelete?.call(),
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _CategoryAction.edit,
                  child: Row(
                    children: [
                      const Icon(AppIcons.edit, size: IconSize.lg),
                      const SizedBox(width: Spacing.xs),
                      Text(l10n.edit),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _CategoryAction.delete,
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.delete,
                        size: IconSize.lg,
                        color: colors.error,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(l10n.delete, style: TextStyle(color: colors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
