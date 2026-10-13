import 'package:flutter/material.dart';
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
    final color = this == WalletType.credit
        ? colors.error
        : colors.onSurfaceVariant;
    return BadgeStyle(
      background: color.withValues(alpha: 0.12),
      foreground: color,
    );
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
