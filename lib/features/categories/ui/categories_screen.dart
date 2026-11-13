import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/rows_card.dart';
import 'package:waldo/core/widgets/sheet_page.dart';
import 'package:waldo/core/widgets/load_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/core/widgets/badge_row.dart';
import 'package:waldo/core/database/save_failure.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/undo_snack_bar.dart';
import 'package:waldo/core/widgets/circle_icon_button.dart';
import 'package:waldo/core/widgets/confirmation_dialog.dart';
import 'package:waldo/core/widgets/pill_button.dart';
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

    // As the other pages: the beige top with back, the title and the main
    // action, then the white sheet (DESIGN.md "Rows card").
    final back = CircleIconButton(
      flat: true,
      tint: colors.chip,
      tooltip: l10n.back,
      onPressed: () => Navigator.of(context).pop(),
      child: const Icon(AppIcons.back, size: IconSize.lg),
    );
    return Scaffold(
      body: SheetPage(
        // Once the title scrolls away: back stays in reach.
        bar: SheetPageBar(title: l10n.categories, leading: back),
        top: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            back,
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(
                  child: Heading(
                    child: Text(l10n.categories, style: context.titlePage),
                  ),
                ),
                PillButton(
                  icon: const Icon(AppIcons.add),
                  tooltip: l10n.newCategory,
                  onPressed: () => showCategoryFormSheet(context),
                ),
              ],
            ),
          ],
        ),
        sheet: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.pageMargin),
          child: switch (categoriesAsync) {
            AsyncValue(:final value?) => _CategoriesBody(categories: value),
            AsyncValue(hasError: true) => LoadError(
              message: l10n.categoriesError,
              onRetry: () => ref.invalidate(categoryListViewModelProvider),
            ),
            _ => const Padding(
              padding: EdgeInsets.all(Spacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
          },
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
      viewModel.restoreCategory(category.id!);
      return;
    }

    try {
      await viewModel.confirmDelete(category.id!);
    } catch (e) {
      viewModel.restoreCategory(category.id!);
      final message = failureMessage(
        l10n,
        e,
        unknown: l10n.categoryDeleteError,
      );
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  List<Widget> _rows(List<Category> categories) => [
    for (final category in categories)
      _CategoryRow(
        category: category,
        // Built-ins follow the app's language, so only the user's own
        // categories can be renamed.
        onTap: category.isDefault
            ? null
            : () => showCategoryFormSheet(context, category: category),
        // The built-ins always stay; only the user's own go.
        onDelete: category.isDefault ? null : () => _confirmDelete(category),
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = widget.categories.inDisplayOrder(l10n);
    // The built-ins in one section, the user's own in a second one below.
    final builtIns = categories.where((c) => c.isDefault).toList();
    final own = categories.where((c) => !c.isDefault).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RowsCard(title: l10n.categoriesBuiltIn, children: _rows(builtIns)),
        if (own.isNotEmpty) ...[
          const SizedBox(height: Spacing.md),
          RowsCard(title: l10n.categoriesYours, children: _rows(own)),
        ],
      ],
    );
  }
}

/// One category: its icon, its name and, if it's one of the user's own, an
/// X. A tap on one of those opens it for renaming.
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, this.onTap, this.onDelete});

  final Category category;
  final VoidCallback? onTap;
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
      button: onTap != null,
      // Its own ink layer: the card's colour would paint over the ripple.
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            // The settings rows' insets: 16 at the sides, 12 above and
            // below the disc.
            padding: const EdgeInsets.fromLTRB(
              Spacing.sm,
              Spacing.xs,
              Spacing.xxs,
              Spacing.xs,
            ),
            child: BadgeRow(
              gap: Spacing.component,
              badge: RowDisc(icon: category.icon, color: colors.ink),
              // A fixed-size slot, so rows line up whether or not they have an X.
              trailing: SizedBox.square(
                dimension: kMinInteractiveDimension,
                child: onDelete == null
                    ? null
                    : IconButton(
                        tooltip: l10n.deleteCategoryNamed(name),
                        onPressed: onDelete,
                        icon: Icon(
                          AppIcons.close,
                          size: IconSize.lg,
                          color: colors.inkMuted,
                        ),
                      ),
              ),
              child: WholeWordsText.singleLine(name, style: context.bodyStrong),
            ),
          ),
        ),
      ),
    );
  }
}
