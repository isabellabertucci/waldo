import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:waldo/core/constants/app_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_form_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';

final _log = Logger('waldo.ui.wallet_form');

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

  String? _validateName(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.nameRequired;
    }
    if (value.trim().length > maxWalletNameLength) {
      return l10n.nameTooLong;
    }
    return null;
  }

  String? _validateBalance(AppLocalizations l10n, String? value) {
    if (_isEditing) return null;
    if (value == null || value.trim().isEmpty) return null;

    final currentType = ref
        .read(walletFormViewModelProvider(widget.wallet))
        .type;
    final allowsNegative = currentType == WalletType.credit;
    final parsedCents = parseToCents(value, allowNegative: allowsNegative);

    if (parsedCents == null || parsedCents.abs() > maxBalanceCents) {
      return l10n.invalidNumber;
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      _log.fine('Wallet form validation failed');
      return;
    }

    final viewModel = ref.read(
      walletFormViewModelProvider(widget.wallet).notifier,
    );
    try {
      final success = await viewModel.save(widget.wallet);
      if (success && mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.saveError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              _isEditing ? l10n.editWallet : l10n.newWallet,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              onChanged: viewModel.updateName,
              decoration: InputDecoration(labelText: l10n.name),
              validator: (value) => _validateName(l10n, value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<WalletType>(
              initialValue: formState.type,
              decoration: InputDecoration(labelText: l10n.type),
              items: WalletType.values.map((type) {
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
            TextFormField(
              controller: _balanceController,
              enabled: !_isEditing,
              onChanged: viewModel.updateBalance,
              decoration: InputDecoration(
                labelText: l10n.startingBalance,
                helperText: _isEditing ? l10n.balanceLocked : null,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) => _validateBalance(l10n, value),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}

extension WalletTypeLabel on WalletType {
  String label(AppLocalizations l10n) {
    return switch (this) {
      WalletType.checking => l10n.walletTypeChecking,
      WalletType.savings => l10n.walletTypeSavings,
      WalletType.cash => l10n.walletTypeCash,
      WalletType.credit => l10n.walletTypeCredit,
      WalletType.investment => l10n.walletTypeInvestment,
    };
  }
}
