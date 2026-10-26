import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/database/save_failure.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/constants/app_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/page_width.dart';
import 'package:waldo/core/widgets/undo_snack_bar.dart';
import 'package:waldo/core/widgets/circle_icon_button.dart';
import 'package:waldo/core/widgets/confirmation_dialog.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/form_pill_field.dart';
import 'package:waldo/core/widgets/surface_card.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/widgets/heading.dart';

import '../categories_x.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';
import '../viewmodels/category_list_view_model.dart';

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
                child: Heading(
                  child: Text(
                    l10n.categories,
                    style: context.headlineSmBold.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _isOthers(Category category) =>
      category.isDefault && category.type == CategoryType.others;

  String? _validateName(AppLocalizations l10n, String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return l10n.nameRequired;
    if (name.length > maxCategoryNameLength) return l10n.nameTooLong;

    // Built-ins match in every language, not just the one on screen.
    final key = nameKey(name);
    final taken = widget.categories.any(
      (c) => c.namesInEveryLanguage.any((n) => nameKey(n) == key),
    );
    return taken ? l10n.categoryNameTaken : null;
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(categoryListViewModelProvider.notifier)
          .add(_nameController.text);
      // Empty again, ready for the next one.
      _nameController.clear();
    } on DuplicateCategoryNameException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.categoryNameTaken)));
    } catch (e) {
      final message = failureMessage(l10n, e, unknown: l10n.categorySaveError);
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

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
    final colors = context.appColors;
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
        Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                child: FormPillField(
                  fieldKey: const Key('categoryNameField'),
                  leading: const Icon(AppIcons.name),
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: maxCategoryNameLength,
                  onPage: true,
                  controller: _nameController,
                  label: l10n.newCategory,
                  hint: l10n.categoryNameHint,
                  onChanged: (_) {},
                  onSubmitted: (_) => _add(),
                  validator: (value) => _validateName(l10n, value),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              DashedStitchButton(
                icon: const Icon(AppIcons.add),
                tooltip: l10n.addCategory,
                onPressed: _add,
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
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
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
                    color: colors.onSurfaceVariant.withValues(alpha: 0.1),
                  ),
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

    return Padding(
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
              color: colors.onSurface.withValues(alpha: 0.06),
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
    );
  }
}
