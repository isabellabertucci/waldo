import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_form_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';

class WalletFormSheet extends ConsumerStatefulWidget {
  const WalletFormSheet({super.key, this.wallet});

  final Wallet? wallet;

  @override
  ConsumerState<WalletFormSheet> createState() => _WalletFormSheetState();
}

class _WalletFormSheetState extends ConsumerState<WalletFormSheet> {
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
    final viewModel = ref.read(
      walletFormViewModelProvider(widget.wallet).notifier,
    );
    final success = await viewModel.save(widget.wallet);
    if (success && mounted) Navigator.of(context).pop();
  }

  String? _errorText(AppLocalizations l10n, String? key) {
    return switch (key) {
      'nameRequired' => l10n.nameRequired,
      'invalidNumber' => l10n.invalidNumber,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isEditing ? l10n.editWallet : l10n.newWallet,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            onChanged: viewModel.updateName,
            decoration: InputDecoration(
              labelText: l10n.name,
              errorText: _errorText(l10n, formState.nameError),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<WalletType>(
            initialValue: formState.type,
            decoration: InputDecoration(labelText: l10n.type),
            items: WalletType.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(type.name));
            }).toList(),
            onChanged: (value) {
              if (value != null) viewModel.updateType(value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _balanceController,
            enabled: !_isEditing,
            onChanged: viewModel.updateBalance,
            decoration: InputDecoration(
              labelText: l10n.startingBalance,
              helperText: _isEditing ? l10n.balanceLocked : null,
              errorText: _errorText(l10n, formState.balanceError),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
    );
  }
}
