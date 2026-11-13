// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboard => 'Home';

  @override
  String get transactions => 'Transactions';

  @override
  String get settings => 'Settings';

  @override
  String get wallets => 'Wallets';

  @override
  String get noWalletsYet => 'No wallets yet';

  @override
  String get addFirstWallet =>
      'A wallet is where you keep money: in hand, at the bank or in savings.';

  @override
  String get newWallet => 'New wallet';

  @override
  String get editWallet => 'Edit wallet';

  @override
  String get name => 'Name';

  @override
  String get type => 'Type';

  @override
  String get startingBalance => 'Starting balance';

  @override
  String get requiredField => 'required';

  @override
  String get balanceLocked => 'Cannot be changed after creation';

  @override
  String get walletNameHint => 'e.g. Home, Travel';

  @override
  String get createWallet => 'Create wallet';

  @override
  String get editCategory => 'Edit category';

  @override
  String get createCategory => 'Create category';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get walletsError => 'There was a problem loading your wallets.';

  @override
  String get saveError => 'Couldn\'t save the wallet. Nothing was changed.';

  @override
  String get deleteError => 'Couldn\'t delete the wallet. Nothing was changed.';

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
  String get walletTypeCredit => 'Credit card';

  @override
  String get walletTypeInvestment => 'Investment';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get addFirstTransaction => 'The transactions you log show up here.';

  @override
  String get newTransaction => 'New transaction';

  @override
  String get transactionDefaultDescription => 'Transaction';

  @override
  String optionsFor(String name) {
    return '$name options';
  }

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get wallet => 'Wallet';

  @override
  String get category => 'Category';

  @override
  String get transactionTitle => 'Title';

  @override
  String get descriptionHint => 'What was it for?';

  @override
  String get addExpense => 'Add expense';

  @override
  String get addIncome => 'Add income';

  @override
  String get transactionNote => 'Note';

  @override
  String get noteHint => 'Anything to remember?';

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
      'There was a problem loading your transactions.';

  @override
  String get transactionSaveError =>
      'Couldn\'t save the transaction. Nothing was changed.';

  @override
  String get saveErrorStorageFull =>
      'Your phone is out of space. Free some up and try again.';

  @override
  String get saveErrorTemporary =>
      'Couldn\'t save right now. Please try again.';

  @override
  String get transactionDeleteError =>
      'Couldn\'t delete the transaction. Nothing was changed.';

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
  String get newCategory => 'New category';

  @override
  String get categoryNameHint => 'e.g. Coffee, Gym';

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
  String deleteCategoryNamed(String name) {
    return 'Delete $name';
  }

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get categoryRestored => 'Category restored';

  @override
  String get categoriesError => 'There was a problem loading your categories.';

  @override
  String get categorySaveError =>
      'Couldn\'t save the category. Nothing was changed.';

  @override
  String get categoryNameTaken => 'A category with this name already exists';

  @override
  String get walletNameTaken => 'A wallet with this name already exists';

  @override
  String get categoryDeleteError =>
      'Couldn\'t delete the category. Nothing was changed.';

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
  String get currencyChangeNotice =>
      'This changes the symbol only. Your amounts stay the same and are not converted.';

  @override
  String get preferencesError =>
      'There was a problem loading your preferences.';

  @override
  String get preferencesSaveError =>
      'Couldn\'t save your preference. Nothing was changed.';

  @override
  String get currencyNameUsd => 'US dollar';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'British pound';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get add => 'Add';

  @override
  String get dashboardError => 'There was a problem loading your dashboard.';

  @override
  String get uncategorized => 'Uncategorized';

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
  String get cashFlow => 'Cash flow';

  @override
  String cashFlowChartExpense(String from, String to) {
    return 'Expenses by month, $from to $to';
  }

  @override
  String cashFlowChartIncome(String from, String to) {
    return 'Income by month, $from to $to';
  }

  @override
  String get amountsHidden => 'Amounts hidden';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get filterTypeAll => 'All';

  @override
  String transactionsInMonth(String month) {
    return 'Transactions in $month';
  }

  @override
  String get noTransactionsForFilter => 'No transactions match this filter.';

  @override
  String get transactionsGroupToday => 'Today';

  @override
  String get transactionsGroupYesterday => 'Yesterday';

  @override
  String walletsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wallets',
      one: '1 wallet',
      zero: '0 wallets',
    );
    return '$_temp0';
  }

  @override
  String get yourWallets => 'Your wallets';

  @override
  String monthChangeThisMonth(String amount) {
    return '$amount this month';
  }

  @override
  String monthChangeInMonth(String amount, String month) {
    return '$amount in $month';
  }

  @override
  String get actionHide => 'Hide';

  @override
  String get actionTransaction => 'Transaction';

  @override
  String get categorySpending => 'Spending by category';

  @override
  String get actionFilter => 'Filter';

  @override
  String get searchWallets => 'Search wallets';

  @override
  String walletsShownOf(int shown, int total) {
    return '$shown of $total';
  }

  @override
  String walletsInPositive(String amount) {
    return 'In the black: $amount';
  }

  @override
  String walletsInNegative(String amount) {
    return 'In the red: $amount';
  }

  @override
  String get walletStatusNegative => 'In the red';

  @override
  String get walletStatusEmpty => 'Empty';

  @override
  String walletStatusShare(String percent) {
    return '$percent of your money';
  }

  @override
  String get noWalletsMatch => 'No wallets found';

  @override
  String get walletActionsHint => 'edit or delete';

  @override
  String get walletRowHint => 'Press and hold a wallet to edit or delete it';

  @override
  String walletShareOfPositive(String percent) {
    return '$percent of your money';
  }

  @override
  String walletInRedBy(String amount) {
    return 'In the red · $amount';
  }

  @override
  String get walletAnalysis => 'Analysis';

  @override
  String transactionsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
      zero: '0 transactions',
    );
    return '$_temp0';
  }

  @override
  String get leatherColour => 'Leather colour';

  @override
  String get leatherBlack => 'Black';

  @override
  String get leatherYellow => 'Yellow';

  @override
  String get leatherGreen => 'Green';

  @override
  String get leatherWhite => 'White';

  @override
  String get transactionActionsHint => 'edit or delete';

  @override
  String get transactionRowHint =>
      'Press and hold a transaction to edit or delete it';

  @override
  String deleteWalletWithTransactions(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'its $count transactions',
      one: 'its 1 transaction',
      zero: 'its transactions',
    );
    return 'This will permanently delete \"$name\" and $_temp0.';
  }

  @override
  String get tryAgain => 'Try again';

  @override
  String get walletBalanceLabel => 'Balance';

  @override
  String get recentCategories => 'Recent';

  @override
  String get newExpense => 'New expense';

  @override
  String get newIncome => 'New income';

  @override
  String get createFirstWallet => 'Create your first wallet';

  @override
  String get noActivityYet => 'No activity yet';

  @override
  String get monthSummary => 'This month';

  @override
  String get monthSummaryLater => 'Shows up here after your first transaction.';

  @override
  String get recentTransactionsLater =>
      'No transactions yet. Create a wallet first.';

  @override
  String get walletsNone => 'None';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsOrganize => 'Organize';

  @override
  String get categoriesBuiltIn => 'Built-in';

  @override
  String get categoriesYours => 'Yours';
}
