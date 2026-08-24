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

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get addFirstTransaction => 'Tap + to add your first transaction';

  @override
  String get newTransaction => 'New Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get transactionDefaultDescription => 'Transaction';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get wallet => 'Wallet';

  @override
  String get category => 'Category';

  @override
  String get transactionDescription => 'Description';

  @override
  String get deleteTransaction => 'Delete transaction?';

  @override
  String get deleteTransactionConfirm =>
      'This will permanently delete this transaction.';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get transactionsError =>
      'There was a problem loading your transactions. Please try again.';

  @override
  String get transactionSaveError =>
      'There was a problem saving the transaction. Please try again.';

  @override
  String get transactionDeleteError =>
      'There was a problem deleting the transaction. Please try again.';

  @override
  String get amountRequired => 'Amount is required';

  @override
  String get dateRequired => 'Date is required';

  @override
  String get walletRequired => 'Wallet is required';

  @override
  String get transactionTypeIncome => 'Income';

  @override
  String get transactionTypeExpense => 'Expense';

  @override
  String get categories => 'Categories';

  @override
  String get noCategoriesYet => 'No categories yet';

  @override
  String get addFirstCategory => 'Tap + to add your first category';

  @override
  String get newCategory => 'New Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get manageCategories => 'Manage categories';

  @override
  String get deleteCategory => 'Delete category?';

  @override
  String deleteCategoryConfirm(String name) {
    return 'This will permanently delete \"$name\".';
  }

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get categoriesError =>
      'There was a problem loading your categories. Please try again.';

  @override
  String get categorySaveError =>
      'There was a problem saving the category. Please try again.';

  @override
  String get categoryDeleteError =>
      'There was a problem deleting the category. Please try again.';

  @override
  String get categoryTypeGroceries => 'Groceries';

  @override
  String get categoryTypeTransportation => 'Transportation';

  @override
  String get categoryTypeSubscriptions => 'Subscriptions';

  @override
  String get categoryTypeEducation => 'Education';

  @override
  String get categoryTypeInvestments => 'Investments';

  @override
  String get none => 'None';
}
