import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/option_sheet.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/wallets_x.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// The wallet picker of both transaction sheets: each wallet with its type's
/// icon, as the Wallets screen shows it.
Future<void> showWalletPicker(
  BuildContext context, {
  required List<Wallet> wallets,
  required int? selected,
  required ValueChanged<int> onPicked,
}) {
  final l10n = AppLocalizations.of(context);

  return showOptionSheet<int?>(
    context,
    title: l10n.wallet,
    initialValue: selected,
    pickOnTap: true,
    options: [
      for (final wallet in wallets)
        SheetOption(
          value: wallet.id,
          label: wallet.name,
          subtitle: wallet.type.label(l10n),
          icon: wallet.type.icon,
        ),
    ],
    onConfirm: (id) {
      if (id != null) onPicked(id);
    },
  );
}
