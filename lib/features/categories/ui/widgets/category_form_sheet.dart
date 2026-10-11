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
import 'package:waldo/core/widgets/form_name_field.dart';
import 'package:waldo/core/widgets/option_tile.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../categories_x.dart';
import '../../models/category.dart';
import '../../viewmodels/category_form_view_model.dart';

/// Same shape as the wallet form: grabber, title + close, a Name field,
/// a grid of types, and the dashed-stitch confirm pill.
class CategoryFormSheet extends ConsumerStatefulWidget {
  const CategoryFormSheet({super.key, this.category});

  final Category? category;

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

  String? _validateName(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.nameRequired;
    }
    if (value.trim().length > maxWalletNameLength) {
      return l10n.nameTooLong;
    }
    return null;
  }

  Future<void> _save(CategoryFormViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await viewModel.save(widget.category);
      if (success && mounted) Navigator.of(context).pop();
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
    final viewModel = ref.read(
      categoryFormViewModelProvider(widget.category).notifier,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        MediaQuery.of(context).viewInsets.bottom + Spacing.md,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isEditing ? l10n.editCategory : l10n.newCategory,
                    style: context.headlineLgStrong,
                  ),
                ),
                const SheetCloseButton(),
              ],
            ),
            const SizedBox(height: Spacing.md),
            FormNameField(
              fieldKey: const Key('categoryNameField'),
              controller: _nameController,
              label: l10n.name,
              hint: l10n.categoryNameHint,
              onChanged: viewModel.updateName,
              validator: (value) => _validateName(l10n, value),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
