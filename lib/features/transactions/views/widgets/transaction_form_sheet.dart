import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/utils/utils.dart';
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

  Future<void> _pickDate(
    TransactionFormViewModel viewModel,
    DateTime? current,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) viewModel.updateDate(picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      _log.fine('Transaction form validation failed');
      return;
    }
    final viewModel = ref.read(
      transactionFormViewModelProvider(
        widget.transaction,
        initialWalletId: widget.initialWalletId,
      ).notifier,
    );
    try {
      final success = await viewModel.save(widget.transaction);
      if (success && mounted) {
        Navigator.of(context).pop();
      } else if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.dateRequired)));
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
    final dateFormat = DateFormat.yMMMd();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
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
                  child: Text(transactionTypeLabel(l10n, type)),
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
            InkWell(
              onTap: () => _pickDate(viewModel, formState.date),
              child: InputDecorator(
                decoration: InputDecoration(labelText: l10n.date),
                child: Text(
                  formState.date == null
                      ? ''
                      : dateFormat.format(formState.date!),
                ),
              ),
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
            FilledButton(onPressed: _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}
