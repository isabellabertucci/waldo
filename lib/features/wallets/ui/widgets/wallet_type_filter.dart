import 'package:flutter/material.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/widgets/filter_tiles.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../models/wallet.dart';
import '../../wallets_x.dart';

/// The order types are listed and grouped in: everyday money first, credit
/// last.
const walletTypeOrder = [
  WalletType.cash,
  WalletType.savings,
  WalletType.checking,
  WalletType.investment,
  WalletType.credit,
];

/// "All" and each wallet type, with how many wallets it has, three to a row;
/// the chosen one is green and stitched.
class WalletTypeFilter extends StatelessWidget {
  const WalletTypeFilter({
    super.key,
    required this.wallets,
    required this.selected,
    required this.onChanged,
  });

  final List<Wallet> wallets;

  /// The type shown, or null for all.
  final WalletType? selected;
  final ValueChanged<WalletType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FilterTiles(
      tiles: [
        (
          icon: AppIcons.allTypes,
          label: l10n.filterTypeAll,
          caption: l10n.walletsCountLabel(wallets.length),
          selected: selected == null,
          onTap: () => onChanged(null),
        ),
        for (final type in walletTypeOrder)
          (
            icon: type.icon,
            label: type.label(l10n),
            caption: l10n.walletsCountLabel(
              wallets.where((w) => w.type == type).length,
            ),
            selected: selected == type,
            onTap: () => onChanged(type),
          ),
      ],
    );
  }
}
