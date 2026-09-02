import 'package:flutter/material.dart';
import 'package:waldo/core/constants/enums.dart';
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
  BadgeStyle get style {
    return switch (this) {
      WalletType.checking => const BadgeStyle(
        background: Color(0xFFE3F6D8),
        foreground: Color(0xFF1F7A3D),
      ),
      WalletType.savings => const BadgeStyle(
        background: Color(0xFFD3EEFF),
        foreground: Color(0xFF0E6BA8),
      ),
      WalletType.cash => const BadgeStyle(
        background: Color(0xFFD9F5E3),
        foreground: Color(0xFF177B3D),
      ),
      WalletType.credit => const BadgeStyle(
        background: Color(0xFFFCDCDC),
        foreground: Color(0xFFB3261E),
      ),
      WalletType.investment => const BadgeStyle(
        background: Color(0xFFFFE9C7),
        foreground: Color(0xFF9A6300),
      ),
    };
  }
}

extension WalletTypeIcon on WalletType {
  IconData get icon {
    return switch (this) {
      WalletType.checking => Icons.account_balance_outlined,
      WalletType.savings => Icons.savings_outlined,
      WalletType.cash => Icons.payments_outlined,
      WalletType.credit => Icons.credit_card_outlined,
      WalletType.investment => Icons.trending_up_outlined,
    };
  }
}
