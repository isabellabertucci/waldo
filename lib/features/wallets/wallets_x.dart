import 'package:flutter/material.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_colors.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/l10n/app_localizations.dart';

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

class BadgeStyle {
  const BadgeStyle({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

extension WalletTypeStyle on WalletType {
  /// Types are told apart by icon; only Credit gets the accent, as it can be negative.
  BadgeStyle style(AppColors colors) {
    final color = this == WalletType.credit ? colors.negative : colors.inkMuted;
    return BadgeStyle(
      background: color.withValues(alpha: Alpha.soft),
      foreground: color,
    );
  }
}

extension LeatherFinishLabel on LeatherFinish {
  String label(AppLocalizations l10n) {
    return switch (this) {
      LeatherFinish.black => l10n.leatherBlack,
      LeatherFinish.yellow => l10n.leatherYellow,
      LeatherFinish.green => l10n.leatherGreen,
      LeatherFinish.white => l10n.leatherWhite,
    };
  }
}

extension WalletTypeIcon on WalletType {
  IconData get icon {
    return switch (this) {
      WalletType.checking => AppIcons.walletChecking,
      WalletType.savings => AppIcons.walletSavings,
      WalletType.cash => AppIcons.walletCash,
      WalletType.credit => AppIcons.walletCredit,
      WalletType.investment => AppIcons.walletInvestment,
    };
  }
}

/// The leather to suggest for a new wallet: the one the fewest [wallets]
/// wear, so new wallets don't all look alike. Ties go to the first in
/// [LeatherFinish]'s order, so the first wallet is black.
LeatherFinish suggestedFinish(List<Wallet> wallets) {
  int uses(LeatherFinish f) => wallets.where((w) => w.finish == f).length;
  return LeatherFinish.values.reduce(
    (best, f) => uses(f) < uses(best) ? f : best,
  );
}

/// [balance]'s share of everything in the black ([positiveTotal]), as
/// "12%" - "<1%" for a sliver, so a small wallet never reads as nothing.
/// Null when the wallet isn't in the black.
String? positiveShareLabel(int balance, int positiveTotal) {
  if (balance <= 0 || positiveTotal <= 0) return null;
  final percent = (balance * 100 / positiveTotal).round();
  return percent < 1 ? '<1%' : '$percent%';
}
