import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_form_view_model.dart';

class WalletFormSheet extends ConsumerStatefulWidget {
  const WalletFormSheet({super.key, this.wallet});

  final Wallet? wallet;

  @override
  ConsumerState<WalletFormSheet> createState() => _WalletFormSheetState();
}

class _WalletFormSheetState extends ConsumerState<WalletFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;

  bool get _isEditing => widget.wallet != null;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(walletFormViewModelProvider(widget.wallet));
    _nameController = TextEditingController(text: initial.name);
    _balanceController = TextEditingController(text: initial.startingBalance);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = ref.read(
      walletFormViewModelProvider(widget.wallet).notifier,
    );
    final success = await viewModel.save(widget.wallet);
    if (success && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(walletFormViewModelProvider(widget.wallet));
    final viewModel = ref.read(
      walletFormViewModelProvider(widget.wallet).notifier,
    );

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
              _isEditing ? 'Edit Wallet' : 'New Wallet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              onChanged: viewModel.updateName,
              decoration: InputDecoration(
                labelText: 'Name',
                errorText: formState.nameError,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<WalletType>(
              initialValue: formState.type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: WalletType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.name));
              }).toList(),
              onChanged: (value) {
                if (value != null) viewModel.updateType(value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _balanceController,
              enabled: !_isEditing,
              onChanged: viewModel.updateBalance,
              decoration: InputDecoration(
                labelText: 'Starting balance',
                helperText: _isEditing
                    ? 'Cannot be changed after creation'
                    : null,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (_isEditing) return null;
                if (value == null || value.trim().isEmpty) return null;
                if (double.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
