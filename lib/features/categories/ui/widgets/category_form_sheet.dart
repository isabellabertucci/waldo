import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/constants/app_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/form_pill_field.dart';
import 'package:waldo/core/widgets/option_tile.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../categories_x.dart';
import '../../models/category.dart';
import '../../repositories/category_repository.dart';
import '../../viewmodels/category_form_view_model.dart';
import '../../viewmodels/category_list_view_model.dart';

/// Same shape as the wallet form: grabber, title + close, a Name field,
/// a grid of types, and the dashed-stitch confirm pill.
class CategoryFormSheet extends ConsumerStatefulWidget {
  const CategoryFormSheet({
    super.key,
    this.category,
    this.onBack,
    this.onSaved,
  });

  final Category? category;

  /// Set when the form is shown inside another sheet: a ‹ back button
  /// replaces the ✕, and there's no grabber of its own.
  final VoidCallback? onBack;

  /// Called with the saved category's id instead of closing the sheet.
  final ValueChanged<int>? onSaved;

  @override
  ConsumerState<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(categoryFormViewModelProvider(widget.category));
    _nameController = TextEditingController(text: initial.name);
  }

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
    if (name.length > maxWalletNameLength) return l10n.nameTooLong;

    // Compare with what's on screen, so built-ins match in the current language.
    final lower = name.toLowerCase();
    final taken = categories.any(
      (c) =>
          c.id != widget.category?.id &&
          c.displayName(l10n).toLowerCase() == lower,
    );
    if (taken) return l10n.categoryNameTaken;
    return null;
  }

  Future<void> _save(CategoryFormViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final id = await viewModel.save(widget.category);
      if (id == null || !mounted) return;
      final onSaved = widget.onSaved;
      if (onSaved != null) {
        onSaved(id);
      } else {
        Navigator.of(context).pop();
      }
    } on DuplicateCategoryNameException {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.categoryNameTaken)));
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.categorySaveError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final formState = ref.watch(categoryFormViewModelProvider(widget.category));
    final categories =
        ref.watch(categoryListViewModelProvider).value ?? const <Category>[];
    final viewModel = ref.read(
      categoryFormViewModelProvider(widget.category).notifier,
    );
    final onBack = widget.onBack;

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
              // Inside another sheet, the ‹ already says how to leave - no
              // grabber of its own (same as the transaction sheet's editors).
              if (onBack == null) ...[
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(Rounded.pill),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.md),
              ],
              Row(
                children: [
                  if (onBack != null) ...[
                    IconButton(
                      tooltip: l10n.back,
                      onPressed: onBack,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(AppIcons.back),
                    ),
                    const SizedBox(width: Spacing.xs),
                  ],
                  Expanded(
                    child: Text(
                      _isEditing ? l10n.editCategory : l10n.newCategory,
                      style: context.headlineLgStrong,
                    ),
                  ),
                  if (onBack == null) const SheetCloseButton(),
                ],
              ),
              const SizedBox(height: Spacing.md),
              FormPillField(
                fieldKey: const Key('categoryNameField'),
                leading: const Icon(AppIcons.name),
                textCapitalization: TextCapitalization.sentences,
                controller: _nameController,
                label: l10n.name,
                hint: l10n.categoryNameHint,
                onChanged: viewModel.updateName,
                validator: (value) => _validateName(l10n, value, categories),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                l10n.type.toUpperCase(),
                style: context.bodySmBold.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              GridView.count(
                // Scroll views add the screen's safe-area inset by default; this grid sits mid-sheet.
                padding: EdgeInsets.zero,
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: Spacing.sm,
                crossAxisSpacing: Spacing.sm,
                childAspectRatio: 1.05,
                children: [
                  for (final type in CategoryType.values)
                    OptionTile(
                      icon: type.icon,
                      label: type.label(l10n),
                      selected: type == formState.type,
                      onTap: () => viewModel.updateType(type),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              SizedBox(
                width: double.infinity,
                child: DashedStitchButton(
                  icon: const Icon(AppIcons.check, size: IconSize.md),
                  label: _isEditing ? l10n.saveChanges : l10n.createCategory,
                  onPressed: () => _save(viewModel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
