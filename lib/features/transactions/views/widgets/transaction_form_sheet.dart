import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/categories/viewmodels/category_list_view_model.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_form_view_model.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';

final _log = Logger('waldo.ui.transaction_form');

class TransactionFormSheet extends ConsumerStatefulWidget {
  const TransactionFormSheet({
    super.key,
    this.transaction,
    this.initialWalletId,
  });

  final Transaction? transaction;
  final int? initialWalletId;

  @override
  ConsumerState<TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(
      transactionFormViewModelProvider(
        widget.transaction,
        initialWalletId: widget.initialWalletId,
      ),
    );
    _amountController = TextEditingController(text: initial.amount);
    _descriptionController = TextEditingController(text: initial.description);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateAmount(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.amountRequired;
    }
    final parsedCents = parseToCents(value, allowNegative: false);
    if (parsedCents == null || parsedCents <= 0) {
      return l10n.invalidNumber;
    }
    return null;
  }

  Future<DateTime?> _pickDate(DateTime? current) {
    return showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  Future<void> _save(TransactionFormViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      _log.fine('Transaction form validation failed');
      return;
    }
    try {
      final success = await viewModel.save(widget.transaction);
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.transactionSaveError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formState = ref.watch(
      transactionFormViewModelProvider(
        widget.transaction,
        initialWalletId: widget.initialWalletId,
      ),
    );
    final viewModel = ref.read(
      transactionFormViewModelProvider(
        widget.transaction,
        initialWalletId: widget.initialWalletId,
      ).notifier,
    );
    final walletsAsync = ref.watch(walletListViewModelProvider());
    final categoriesAsync = ref.watch(categoryListViewModelProvider);
    final dateFormat = DateFormat.yMMMd();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? l10n.editTransaction : l10n.newTransaction,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                onChanged: viewModel.updateAmount,
                decoration: InputDecoration(labelText: l10n.amount),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => _validateAmount(l10n, value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionType>(
                initialValue: formState.type,
                decoration: InputDecoration(labelText: l10n.type),
                items: TransactionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.label(l10n)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) viewModel.updateType(value);
                },
              ),
              const SizedBox(height: 16),
              switch (walletsAsync) {
                AsyncData(:final value) => DropdownButtonFormField<int>(
                  initialValue: formState.walletId,
                  decoration: InputDecoration(labelText: l10n.wallet),
                  items: value.map((wallet) {
                    return DropdownMenuItem(
                      value: wallet.id,
                      child: Text(wallet.name),
                    );
                  }).toList(),
                  onChanged: (walletId) {
                    if (walletId != null) viewModel.updateWalletId(walletId);
                  },
                  validator: (value) =>
                      value == null ? l10n.walletRequired : null,
                ),
                _ => const SizedBox.shrink(),
              },
              const SizedBox(height: 16),
              switch (categoriesAsync) {
                AsyncData(:final value) => DropdownButtonFormField<int?>(
                  initialValue: formState.categoryId,
                  decoration: InputDecoration(labelText: l10n.category),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.none)),
                    ...value.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }),
                  ],
                  onChanged: (categoryId) {
                    viewModel.updateCategoryId(categoryId);
                  },
                ),
                _ => const SizedBox.shrink(),
              },
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => const CategoriesRoute().push(context),
                  child: Text(l10n.manageCategories),
                ),
              ),
              const SizedBox(height: 8),
              FormField<DateTime>(
                initialValue: formState.date,
                validator: (value) => value == null ? l10n.dateRequired : null,
                builder: (field) {
                  return InkWell(
                    onTap: () async {
                      final picked = await _pickDate(formState.date);
                      if (picked == null) return;
                      viewModel.updateDate(picked);
                      field.didChange(picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.date,
                        errorText: field.errorText,
                      ),
                      child: Text(
                        formState.date == null
                            ? ''
                            : dateFormat.format(formState.date!),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                onChanged: viewModel.updateDescription,
                decoration: InputDecoration(
                  labelText: l10n.transactionDescription,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _save(viewModel),
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension TransactionTypeLabel on TransactionType {
  String label(AppLocalizations l10n) {
    return switch (this) {
      TransactionType.income => l10n.transactionTypeIncome,
      TransactionType.expense => l10n.transactionTypeExpense,
    };
  }
}
