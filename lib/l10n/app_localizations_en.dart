// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Waldo';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transactions';

  @override
  String get settings => 'Settings';

  @override
  String get wallets => 'Wallets';

  @override
  String get noWalletsYet => 'No wallets yet';

  @override
  String get addFirstWallet => 'Tap + to add your first wallet';

  @override
  String get newWallet => 'New Wallet';

  @override
  String get editWallet => 'Edit Wallet';

  @override
  String get name => 'Name';

  @override
  String get type => 'Type';

  @override
  String get startingBalance => 'Starting balance';

  @override
  String get balanceLocked => 'Cannot be changed after creation';

  @override
  String get save => 'Save';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get walletsError =>
      'There was a problem loading your wallets. Please try again.';

  @override
  String get saveError =>
      'There was a problem saving the wallet. Please try again.';

  @override
  String get deleteError =>
      'There was a problem deleting the wallet. Please try again.';

  @override
  String get deleteWallet => 'Delete wallet?';

  @override
  String deleteWalletConfirm(String name) {
    return 'This will permanently delete \"$name\".';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get walletDeleted => 'Wallet deleted';

  @override
  String get undo => 'Undo';

  @override
  String get nameTooLong => 'Name is too long';

  @override
  String get walletTypeChecking => 'Checking';

  @override
  String get walletTypeSavings => 'Savings';

  @override
  String get walletTypeCash => 'Cash';

  @override
  String get walletTypeCredit => 'Credit Card';

  @override
  String get walletTypeInvestment => 'Investment';
}
