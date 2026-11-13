import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/form_sheet_body.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/constants/app_constants.dart';
import 'package:waldo/core/widgets/app_sheet.dart';
import 'package:waldo/core/database/save_failure.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/pill_button.dart';
import 'package:waldo/core/widgets/form_pill_field.dart';
import 'package:waldo/core/widgets/heading.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/core/widgets/sheet_grabber.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../categories_x.dart';
import '../../models/category.dart';
import '../../repositories/category_repository.dart';
import '../../viewmodels/category_list_view_model.dart';

/// Opens the category sheet, new or for renaming [category], as the
/// Wallets screen opens its own. Returns the saved category's id, or null.
Future<int?> showCategoryFormSheet(BuildContext context, {Category? category}) {
  return showAppSheet<int>(
    context,
    builder: (_) => CategoryFormSheet(category: category),
  );
}

class CategoryFormSheet extends ConsumerStatefulWidget {
  const CategoryFormSheet({super.key, this.category});

  /// The custom category being renamed; null for a new one.
  final Category? category;

  @override
  ConsumerState<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.category?.name,
  );

  bool get _isEditing => widget.category != null;

  /// Shown above the button: a SnackBar would land behind the sheet.
  String? _saveError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _validateName(
    AppLocalizations l10n,
    String? value,
    List<Category> categories,
  ) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return l10n.nameRequired;
    if (name.length > maxCategoryNameLength) return l10n.nameTooLong;

    // Built-ins match in every language, not just the one on screen.
    final key = nameKey(name);
    // Its own name is fine: renaming "Gym" to "gym" changes only the case.
    final taken = categories.any(
      (c) =>
          c.id != widget.category?.id &&
          c.namesInEveryLanguage.any((n) => nameKey(n) == key),
    );
    return taken ? l10n.categoryNameTaken : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saveError = null);

    try {
      final viewModel = ref.read(categoryListViewModelProvider.notifier);
      final editing = widget.category;
      final int? id;
      if (editing == null) {
        id = await viewModel.add(_nameController.text);
        // A second tap while the first saves: that one closes the sheet,
        // with the id the picker selects.
        if (id == null) return;
      } else {
        await viewModel.rename(editing.id!, _nameController.text);
        id = editing.id;
      }
      if (mounted) Navigator.of(context).pop(id);
    } catch (e) {
      if (!mounted) return;
      final message = e is DuplicateCategoryNameException
          // The list on screen was stale; the database still caught it.
          ? l10n.categoryNameTaken
          : failureMessage(l10n, e, unknown: l10n.categorySaveError);
      setState(() => _saveError = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    // Names already in use, for the duplicate check.
    final categories =
        ref.watch(categoryListViewModelProvider).value ?? const [];

    return FormSheetBody(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetGrabber(),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(
                  child: Heading(
                    child: Text(
                      _isEditing ? l10n.editCategory : l10n.newCategory,
                      style: context.titleSection,
                    ),
                  ),
                ),
                const SheetCloseButton(),
              ],
            ),
            const SizedBox(height: Spacing.md),
            FormPillField(
              fieldKey: const Key('categoryNameField'),
              textCapitalization: TextCapitalization.sentences,
              maxLength: maxCategoryNameLength,
              controller: _nameController,
              label: l10n.name,
              required: true,
              hint: l10n.categoryNameHint,
              onSubmitted: (_) => _save(),
              validator: (value) => _validateName(l10n, value, categories),
            ),
            const SizedBox(height: Spacing.md),
            if (_saveError case final error?) ...[
              SizedBox(
                width: double.infinity,
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                  style: context.bodyStrong.copyWith(color: colors.negative),
                ),
              ),
              const SizedBox(height: Spacing.sm),
            ],
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: _isEditing ? l10n.saveChanges : l10n.createCategory,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
