import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/constants/app_constants.dart';
import 'package:waldo/core/database/save_failure.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/form_pill_field.dart';
import 'package:waldo/core/widgets/heading.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/core/widgets/sheet_grabber.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../categories_x.dart';
import '../../models/category.dart';
import '../../repositories/category_repository.dart';
import '../../viewmodels/category_list_view_model.dart';

/// Opens the new-category sheet, as the Wallets screen opens its own.
Future<void> showCategoryFormSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const CategoryFormSheet(),
  );
}

class CategoryFormSheet extends ConsumerStatefulWidget {
  const CategoryFormSheet({super.key});

  @override
  ConsumerState<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

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
    final taken = categories.any(
      (c) => c.namesInEveryLanguage.any((n) => nameKey(n) == key),
    );
    return taken ? l10n.categoryNameTaken : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saveError = null);

    try {
      await ref
          .read(categoryListViewModelProvider.notifier)
          .add(_nameController.text);
      if (mounted) Navigator.of(context).pop();
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

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            Spacing.md,
      ),
      child: SingleChildScrollView(
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
                        l10n.newCategory,
                        style: context.headlineLgExtraBold,
                      ),
                    ),
                  ),
                  const SheetCloseButton(),
                ],
              ),
              const SizedBox(height: Spacing.md),
              FormPillField(
                fieldKey: const Key('categoryNameField'),
                leading: const Icon(AppIcons.name),
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
                    style: context.bodyMdStrong.copyWith(color: colors.error),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
              ],
              SizedBox(
                width: double.infinity,
                child: DashedStitchButton(
                  icon: const Icon(AppIcons.check, size: IconSize.md),
                  label: l10n.createCategory,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
