import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/database/save_failure.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/page_width.dart';
import 'package:waldo/core/widgets/undo_snack_bar.dart';
import 'package:waldo/core/widgets/circle_icon_button.dart';
import 'package:waldo/core/widgets/confirmation_dialog.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/surface_card.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/widgets/heading.dart';

import '../categories_x.dart';
import '../models/category.dart';
import '../viewmodels/category_list_view_model.dart';
import 'widgets/category_form_sheet.dart';

/// A field to add a category over the list of existing ones, each with an X.
/// "Others" has no X: deleted categories' transactions move there.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final categoriesAsync = ref.watch(categoryListViewModelProvider);

    return Scaffold(
      body: PageWidth(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.pageMargin,
                  Spacing.xs,
                  Spacing.pageMargin,
                  0,
                ),
                child: CircleIconButton(
                  tooltip: l10n.back,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(AppIcons.back),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.pageMargin,
                ),
                // Title and "+" as on the Wallets screen; "+" opens a sheet.
                child: Row(
                  children: [
                    Expanded(
                      child: Heading(
                        child: Text(
                          l10n.categories,
                          style: context.headlineSmExtraBold.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ),
                    DashedStitchButton(
                      icon: const Icon(AppIcons.add),
                      tooltip: l10n.newCategory,
                      onPressed: () => showCategoryFormSheet(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: switch (categoriesAsync) {
                  AsyncValue(:final value?) => _CategoriesBody(
                    categories: value,
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
      ),
    );
  }
}

class _CategoriesBody extends ConsumerStatefulWidget {
  const _CategoriesBody({required this.categories});

  final List<Category> categories;

  @override
  ConsumerState<_CategoriesBody> createState() => _CategoriesBodyState();
}

class _CategoriesBodyState extends ConsumerState<_CategoriesBody> {
  bool _isOthers(Category category) =>
      category.isDefault && category.type == CategoryType.others;

  Future<void> _confirmDelete(Category category) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final viewModel = ref.read(categoryListViewModelProvider.notifier);
    final name = category.displayName(l10n);

    // Say how many transactions move to "Others" before anything happens.
    final int count;
    try {
      count = await viewModel.transactionCount(category.id!);
    } catch (e) {
      // Nothing is deleted, but the tap still gets an answer.
      final message = failureMessage(
        l10n,
        e,
        unknown: l10n.categoryDeleteError,
      );
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    if (!mounted) return;

    final confirmed = await ConfirmationDialog.show(
      context,
      title: l10n.deleteCategory,
      content: count > 0
          ? l10n.deleteCategoryMovesTransactions(
              count,
              name,
              l10n.categoryTypeOthers,
            )
          : l10n.deleteCategoryConfirm(name),
      confirmLabel: l10n.delete,
    );
    if (!confirmed) return;

    if (!viewModel.hideCategory(category.id!)) return;

    final undone = await showUndoSnackBar(
      messenger,
      title: l10n.categoryDeleted,
      subtitle: name,
      restoredLabel: l10n.categoryRestored,
    );
    if (undone) {
      viewModel.restoreCategory();
      return;
    }

    try {
      await viewModel.confirmDelete(category.id!);
    } catch (e) {
      viewModel.restoreCategory();
      final message = failureMessage(
        l10n,
        e,
        unknown: l10n.categoryDeleteError,
      );
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // A-Z by the name on screen, with the undeletable "Others" last.
    final categories = [...widget.categories]
      ..sort((a, b) {
        if (_isOthers(a) != _isOthers(b)) return _isOthers(a) ? 1 : -1;
        return a
            .displayName(l10n)
            .toLowerCase()
            .compareTo(b.displayName(l10n).toLowerCase());
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.pageMargin,
        Spacing.md,
        Spacing.pageMargin,
        Spacing.lg,
      ),
      children: [
        SurfaceCard(
          child: Column(
            children: [
              for (var i = 0; i < categories.length; i++) ...[
                _CategoryRow(
                  category: categories[i],
                  onDelete: _isOthers(categories[i])
                      ? null
                      : () => _confirmDelete(categories[i]),
                ),
                if (i != categories.length - 1)
                  const Divider(indent: Spacing.md, endIndent: Spacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One category: its icon, its name and, unless it's "Others", an X.
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, this.onDelete});

  final Category category;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final name = category.displayName(l10n);
    final onDelete = this.onDelete;

    // Its own node, so each name is read apart rather than all in one; its
    // delete button stays separate, so a tap on the row can't delete.
    return Semantics(
      container: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.xxs,
          Spacing.xxs,
          Spacing.xxs,
        ),
        child: Row(
          children: [
            Container(
              width: BadgeSize.md,
              height: BadgeSize.md,
              decoration: BoxDecoration(
                // The page behind the card, as if the disc were cut out of it.
                color: colors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                size: IconSize.md,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyMdBold,
              ),
            ),
            // A fixed-size slot, so rows line up whether or not they have an X.
            SizedBox.square(
              dimension: 48,
              child: onDelete == null
                  ? null
                  : IconButton(
                      tooltip: l10n.deleteCategoryNamed(name),
                      onPressed: onDelete,
                      icon: Icon(
                        AppIcons.close,
                        size: IconSize.lg,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
