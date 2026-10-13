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
  String get startingBalancePrompt => 'How much is in it today?';

  @override
  String get optional => 'Optional';

  @override
  String get balanceLocked => 'Cannot be changed after creation';

  @override
  String get walletNameHint => 'e.g. Home, Travel';

  @override
  String get createWallet => 'Create wallet';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

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
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get deleteDigit => 'Delete digit';

  @override
  String get hideBalance => 'Hide balance';

  @override
  String get showBalance => 'Show balance';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get walletDeleted => 'Wallet deleted';

  @override
  String get walletRestored => 'Wallet restored';

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
  String get descriptionHint => 'What was it for?';

  @override
  String get addExpense => 'Add expense';

  @override
  String get addIncome => 'Add income';

  @override
  String get transactionNote => 'Note';

  @override
  String editingAmountLabel(String type) {
    return '$type · editing amount';
  }

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesMessage => 'You have unsaved changes to this field.';

  @override
  String get discard => 'Discard';

  @override
  String get deleteTransaction => 'Delete transaction?';

  @override
  String get deleteTransactionConfirm =>
      'This will permanently delete this transaction.';

  @override
  String get editTransactionAction => 'Edit transaction';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get transactionRestored => 'Transaction restored';

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
  String get newCategory => 'New category';

  @override
  String get categoryNameHint => 'e.g. Coffee, Gym';

  @override
  String get manageCategories => 'Manage categories';

  @override
  String get deleteCategory => 'Delete category?';

  @override
  String deleteCategoryConfirm(String name) {
    return 'This will delete \"$name\".';
  }

  @override
  String deleteCategoryMovesTransactions(
    int count,
    String name,
    String others,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions use \"$name\"',
      one: '1 transaction uses \"$name\"',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'they move',
      one: 'it moves',
    );
    return '$_temp0. If you delete it, $_temp1 to $others.';
  }

  @override
  String get addCategory => 'Add category';

  @override
  String deleteCategoryNamed(String name) {
    return 'Delete $name';
  }

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get categoryRestored => 'Category restored';

  @override
  String get categoriesError =>
      'There was a problem loading your categories. Please try again.';

  @override
  String get categorySaveError =>
      'There was a problem saving the category. Please try again.';

  @override
  String get categoryNameTaken => 'A category with this name already exists';

  @override
  String get walletNameTaken => 'A wallet with this name already exists';

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
  String get categoryTypeOthers => 'Others';

  @override
  String get none => 'None';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get currency => 'Currency';

  @override
  String get dateFormat => 'Date format';

  @override
  String get moneySection => 'Money';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get currencyRowSubtitle => 'How amounts are shown';

  @override
  String get dateFormatRowSubtitle => 'Used in lists and details';

  @override
  String get currencyChangeNotice =>
      'This changes the symbol only. Your amounts stay the same and are not converted.';

  @override
  String get preferencesError =>
      'There was a problem loading your preferences. Please try again.';

  @override
  String get preferencesSaveError =>
      'There was a problem saving your preference. Please try again.';

  @override
  String get currencyNameUsd => 'US dollar';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'British pound';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get add => 'Add';

  @override
  String get dashboardError =>
      'There was a problem loading your dashboard. Please try again.';

  @override
  String dashboardReceiptHeader(String month, String year) {
    return 'WALDO · $month $year';
  }

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get monthNetLabel => 'Net';

  @override
  String dashboardReceiptOtherCategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Other ($count)',
      one: 'Other (1)',
    );
    return '$_temp0';
  }

  @override
  String get seeAll => 'See all';

  @override
  String get categorySpendingEmptyHint =>
      'Add your first transaction to see it broken down by category here.';

  @override
  String get addFirstTransactionButton => 'Add first transaction';

  @override
  String get cashFlow => 'Cash Flow';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get firstRunPeekCta => 'Slide in your first wallet';

  @override
  String get dashboardReceiptNoWallet =>
      'Your month\'s receipt prints here after the first transaction.';

  @override
  String get zeroWalletsLabel => '0 wallets';

  @override
  String get filterTitle => 'Filter';

  @override
  String get filterReset => 'Reset';

  @override
  String get filterSectionMonth => 'Month';

  @override
  String get earlierMonths => 'Earlier months';

  @override
  String get laterMonths => 'Later months';

  @override
  String get filterSectionType => 'Type';

  @override
  String get filterTypeAll => 'All';

  @override
  String filterShowTransactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count transactions',
      one: 'Show 1 transaction',
    );
    return '$_temp0';
  }

  @override
  String filterChipLabel(String type) {
    return '$type transactions';
  }

  @override
  String get noTransactionsForFilter => 'No transactions match this filter.';

  @override
  String get transactionsGroupToday => 'Today';

  @override
  String get transactionsGroupYesterday => 'Yesterday';

  @override
  String keptPercentThisMonth(String percent) {
    return 'Kept $percent of what you received';
  }

  @override
  String overspentPercentThisMonth(String percent) {
    return 'Spent $percent more than you received';
  }

  @override
  String walletsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wallets',
      one: '1 wallet',
    );
    return '$_temp0';
  }
}
