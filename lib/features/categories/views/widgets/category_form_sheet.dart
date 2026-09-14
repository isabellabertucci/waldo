import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/viewmodels/category_form_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';

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
    ref.watch(categoryFormViewModelProvider(widget.category));
    final viewModel = ref.read(
      categoryFormViewModelProvider(widget.category).notifier,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? l10n.editCategory : l10n.newCategory,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              onChanged: viewModel.updateName,
              decoration: InputDecoration(labelText: l10n.name),
              validator: (value) => _validateName(l10n, value),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _save(viewModel),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
