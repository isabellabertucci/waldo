import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// Dashboard tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dashboard;

  /// Transactions tab label
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Wallets tab and screen title
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get wallets;

  /// Empty state title for wallets list
  ///
  /// In en, this message translates to:
  /// **'No wallets yet'**
  String get noWalletsYet;

  /// Empty state subtitle for wallets list
  ///
  /// In en, this message translates to:
  /// **'A wallet is where you keep money: in hand, at the bank or in savings.'**
  String get addFirstWallet;

  /// Title of the create wallet form
  ///
  /// In en, this message translates to:
  /// **'New wallet'**
  String get newWallet;

  /// Title of the edit wallet form
  ///
  /// In en, this message translates to:
  /// **'Edit wallet'**
  String get editWallet;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Type field label (shared between wallets and transactions)
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Starting balance field label
  ///
  /// In en, this message translates to:
  /// **'Starting balance'**
  String get startingBalance;

  /// Read by screen readers after a field label marked with *
  ///
  /// In en, this message translates to:
  /// **'required'**
  String get requiredField;

  /// Helper text for locked balance field
  ///
  /// In en, this message translates to:
  /// **'Cannot be changed after creation'**
  String get balanceLocked;

  /// Placeholder text for the wallet name field
  ///
  /// In en, this message translates to:
  /// **'e.g. Home, Travel'**
  String get walletNameHint;

  /// Button label for creating a new wallet
  ///
  /// In en, this message translates to:
  /// **'Create wallet'**
  String get createWallet;

  /// Title of the category sheet when renaming a custom category
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// Button that saves the new category in the new-category sheet
  ///
  /// In en, this message translates to:
  /// **'Create category'**
  String get createCategory;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Confirm button label on a single-field edit sheet (e.g. editing just the amount or just the name of a transaction)
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Validation error for empty name
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// Validation error for invalid balance
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidNumber;

  /// Generic error message shown when wallets fail to load
  ///
  /// In en, this message translates to:
  /// **'There was a problem loading your wallets.'**
  String get walletsError;

  /// Shown when saving a wallet fails for a reason the user can't fix; nothing was written
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the wallet. Nothing was changed.'**
  String get saveError;

  /// Generic error message shown when deleting a wallet fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the wallet. Nothing was changed.'**
  String get deleteError;

  /// Delete confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete wallet?'**
  String get deleteWallet;

  /// Delete confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\".'**
  String deleteWalletConfirm(String name);

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Accessibility label and tooltip for the button that closes a sheet
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Accessibility label and tooltip for a back/chevron-left button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Accessibility label and tooltip for the eye button when amounts are visible - tapping it masks them
  ///
  /// In en, this message translates to:
  /// **'Hide balance'**
  String get hideBalance;

  /// Accessibility label and tooltip for the eye button when amounts are masked - tapping it reveals them
  ///
  /// In en, this message translates to:
  /// **'Show balance'**
  String get showBalance;

  /// Edit action label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Snackbar message after deleting a wallet
  ///
  /// In en, this message translates to:
  /// **'Wallet deleted'**
  String get walletDeleted;

  /// Short confirmation after tapping Undo on a deleted wallet
  ///
  /// In en, this message translates to:
  /// **'Wallet restored'**
  String get walletRestored;

  /// Undo button label in snackbar
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Validation error when the wallet name exceeds the max length
  ///
  /// In en, this message translates to:
  /// **'Name is too long'**
  String get nameTooLong;

  /// Checking account wallet type
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get walletTypeChecking;

  /// Savings account wallet type
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get walletTypeSavings;

  /// Cash wallet type
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get walletTypeCash;

  /// Credit card wallet type
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get walletTypeCredit;

  /// Investment wallet type
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get walletTypeInvestment;

  /// Empty state title for transactions list
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// Empty state subtitle for transactions list
  ///
  /// In en, this message translates to:
  /// **'The transactions you log show up here.'**
  String get addFirstTransaction;

  /// Title of the create transaction form
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get newTransaction;

  /// Fallback label when a transaction has no description
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transactionDefaultDescription;

  /// Screen reader name of the ⋮ menu on a wallet card or transaction row; names the item so each one is told apart
  ///
  /// In en, this message translates to:
  /// **'{name} options'**
  String optionsFor(String name);

  /// Amount field label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Date field label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Wallet field label
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Transaction title field label: the name shown on the list and the detail
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get transactionTitle;

  /// Placeholder text for the new transaction's description field
  ///
  /// In en, this message translates to:
  /// **'What was it for?'**
  String get descriptionHint;

  /// Button label for creating a new expense transaction
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// Button label for creating a new income transaction
  ///
  /// In en, this message translates to:
  /// **'Add income'**
  String get addIncome;

  /// Transaction note field label - a free-text note separate from its title
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get transactionNote;

  /// Placeholder for the transaction's note field
  ///
  /// In en, this message translates to:
  /// **'Anything to remember?'**
  String get noteHint;

  /// Delete confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get deleteTransaction;

  /// Delete confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this transaction.'**
  String get deleteTransactionConfirm;

  /// Button on a transaction's read-only view that switches it into edit mode
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTransactionAction;

  /// Button that commits every field's changes on a transaction's edit screen at once
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// Snackbar message after deleting a transaction
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// Short confirmation after tapping Undo on a deleted transaction
  ///
  /// In en, this message translates to:
  /// **'Transaction restored'**
  String get transactionRestored;

  /// Generic error message shown when transactions fail to load
  ///
  /// In en, this message translates to:
  /// **'There was a problem loading your transactions.'**
  String get transactionsError;

  /// Shown when saving a transaction fails for a reason the user can't fix; the write was rolled back
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the transaction. Nothing was changed.'**
  String get transactionSaveError;

  /// Shown when a save fails because the device storage is full
  ///
  /// In en, this message translates to:
  /// **'Your phone is out of space. Free some up and try again.'**
  String get saveErrorStorageFull;

  /// Shown when a save fails because the database was briefly busy or closed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save right now. Please try again.'**
  String get saveErrorTemporary;

  /// Generic error message shown when deleting a transaction fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the transaction. Nothing was changed.'**
  String get transactionDeleteError;

  /// Validation error for empty amount
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountRequired;

  /// Validation error for missing date
  ///
  /// In en, this message translates to:
  /// **'Date is required'**
  String get dateRequired;

  /// Validation error for missing wallet
  ///
  /// In en, this message translates to:
  /// **'Wallet is required'**
  String get walletRequired;

  /// Income transaction type
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transactionTypeIncome;

  /// Expense transaction type
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get transactionTypeExpense;

  /// Categories screen title
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Title of the create category form
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// Placeholder in the category name field
  ///
  /// In en, this message translates to:
  /// **'e.g. Coffee, Gym'**
  String get categoryNameHint;

  /// Delete confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get deleteCategory;

  /// Delete confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'This will delete \"{name}\".'**
  String deleteCategoryConfirm(String name);

  /// Delete confirmation when transactions use the category; they are reassigned to the Others category
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction uses \"{name}\"} other{{count} transactions use \"{name}\"}}. If you delete it, {count, plural, =1{it moves} other{they move}} to {others}.'**
  String deleteCategoryMovesTransactions(int count, String name, String others);

  /// Tooltip for the delete (X) button on a category row
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String deleteCategoryNamed(String name);

  /// Snackbar message after deleting a category
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// Short confirmation after tapping Undo on a deleted category
  ///
  /// In en, this message translates to:
  /// **'Category restored'**
  String get categoryRestored;

  /// Generic error message shown when categories fail to load
  ///
  /// In en, this message translates to:
  /// **'There was a problem loading your categories.'**
  String get categoriesError;

  /// Generic error message shown when saving a category fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the category. Nothing was changed.'**
  String get categorySaveError;

  /// Validation error when the user types a category name that is already shown in the list
  ///
  /// In en, this message translates to:
  /// **'A category with this name already exists'**
  String get categoryNameTaken;

  /// Validation error when the user types a wallet name another wallet already uses, ignoring case
  ///
  /// In en, this message translates to:
  /// **'A wallet with this name already exists'**
  String get walletNameTaken;

  /// Generic error message shown when deleting a category fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the category. Nothing was changed.'**
  String get categoryDeleteError;

  /// Groceries category type
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get categoryTypeGroceries;

  /// Transportation category type
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get categoryTypeTransportation;

  /// Subscriptions category type
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get categoryTypeSubscriptions;

  /// Education category type
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryTypeEducation;

  /// Investments category type
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get categoryTypeInvestments;

  /// Label for the catch-all category type, for anything that fits none of the others
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get categoryTypeOthers;

  /// Label for selecting no category on a transaction
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Theme row/section title and sheet title in settings
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Option to follow the device's theme setting
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Option to always use light theme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Option to always use dark theme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Currency row title and sheet title in settings
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Date format row title and sheet title in settings
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get dateFormat;

  /// Notice shown at the bottom of the currency picker sheet
  ///
  /// In en, this message translates to:
  /// **'This changes the symbol only. Your amounts stay the same and are not converted.'**
  String get currencyChangeNotice;

  /// Generic error message shown when preferences fail to load
  ///
  /// In en, this message translates to:
  /// **'There was a problem loading your preferences.'**
  String get preferencesError;

  /// Error message shown when a preference fails to save
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your preference. Nothing was changed.'**
  String get preferencesSaveError;

  /// US Dollar full name in the currency picker
  ///
  /// In en, this message translates to:
  /// **'US dollar'**
  String get currencyNameUsd;

  /// Euro full name in the currency picker
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currencyNameEur;

  /// British Pound full name in the currency picker
  ///
  /// In en, this message translates to:
  /// **'British pound'**
  String get currencyNameGbp;

  /// Label above the total balance amount on the dashboard
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get totalBalance;

  /// Short label for the quick-add button on the balance card
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Generic error message shown when dashboard data fails to load
  ///
  /// In en, this message translates to:
  /// **'There was a problem loading your dashboard.'**
  String get dashboardError;

  /// Receipt line for this month's expenses that have no category (never set, or their category was deleted)
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// Rollup row label on the dashboard's receipt summary for categories past the first few, e.g. 'Other (3)' summing their combined amount
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Other (1)} other{Other ({count})}}'**
  String dashboardReceiptOtherCategories(int count);

  /// Link that navigates to a full list from a dashboard section preview
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Empty state hint for the dashboard's category spending section
  ///
  /// In en, this message translates to:
  /// **'Add your first transaction to see it broken down by category here.'**
  String get categorySpendingEmptyHint;

  /// Dashboard cash flow chart card title
  ///
  /// In en, this message translates to:
  /// **'Cash flow'**
  String get cashFlow;

  /// Screen reader name of the cash flow chart showing expenses; from/to are the first and last months, e.g. Nov 2025
  ///
  /// In en, this message translates to:
  /// **'Expenses by month, {from} to {to}'**
  String cashFlowChartExpense(String from, String to);

  /// Screen reader name of the cash flow chart showing income; from/to are the first and last months, e.g. Nov 2025
  ///
  /// In en, this message translates to:
  /// **'Income by month, {from} to {to}'**
  String cashFlowChartIncome(String from, String to);

  /// Screen reader value of the cash flow chart while the balance is hidden
  ///
  /// In en, this message translates to:
  /// **'Amounts hidden'**
  String get amountsHidden;

  /// Dashboard section header for the recent transactions list
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactions;

  /// Name of the month selector's left chevron, which selects the month before
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// Name of the month selector's right chevron, which selects the month after
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// Option in the filter sheet's type toggle that includes both income and expense
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterTypeAll;

  /// Title of the transactions list opened from the dashboard receipt, e.g. 'Transactions in October 2026'
  ///
  /// In en, this message translates to:
  /// **'Transactions in {month}'**
  String transactionsInMonth(String month);

  /// Empty state shown on the wallet transactions screen when the active filter excludes every transaction
  ///
  /// In en, this message translates to:
  /// **'No transactions match this filter.'**
  String get noTransactionsForFilter;

  /// Date group header for transactions dated today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get transactionsGroupToday;

  /// Date group header for transactions dated yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get transactionsGroupYesterday;

  /// Fallback caption on the wallets screen's fixed total balance bar when there's no income yet this month to compute a savings percentage
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 wallets} =1{1 wallet} other{{count} wallets}}'**
  String walletsCountLabel(int count);

  /// Home: title over the wallet stack, opens the Wallets tab
  ///
  /// In en, this message translates to:
  /// **'Your wallets'**
  String get yourWallets;

  /// Home: pill under the total balance with this month's net change, e.g. '▲ +1 682,62 $ this month'
  ///
  /// In en, this message translates to:
  /// **'{amount} this month'**
  String monthChangeThisMonth(String amount);

  /// Home: the same pill for a past month
  ///
  /// In en, this message translates to:
  /// **'{amount} in {month}'**
  String monthChangeInMonth(String amount, String month);

  /// Home: label under the eye button that hides balances
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get actionHide;

  /// Home: label under the main button, which adds a transaction
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get actionTransaction;

  /// Home: title of the card listing the month's expense by category
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get categorySpending;

  /// Wallets: the action circle that opens the filter by type
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get actionFilter;

  /// Wallets: placeholder and name of the search field
  ///
  /// In en, this message translates to:
  /// **'Search wallets'**
  String get searchWallets;

  /// Wallets: how many wallets the search and filter leave, of all of them
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total}'**
  String walletsShownOf(int shown, int total);

  /// Wallets: screen reader name of the pill with the sum of the positive balances
  ///
  /// In en, this message translates to:
  /// **'In the black: {amount}'**
  String walletsInPositive(String amount);

  /// Wallets: screen reader name of the pill with the sum of the negative balances
  ///
  /// In en, this message translates to:
  /// **'In the red: {amount}'**
  String walletsInNegative(String amount);

  /// Wallets: a row's line for a wallet below zero
  ///
  /// In en, this message translates to:
  /// **'In the red'**
  String get walletStatusNegative;

  /// Wallets: a row's line for a wallet at zero
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get walletStatusEmpty;

  /// Wallets: a row's line for a wallet above zero - its share of all the positive balances, e.g. '12%'
  ///
  /// In en, this message translates to:
  /// **'{percent} of your money'**
  String walletStatusShare(String percent);

  /// Wallets: when the search and filter leave nothing
  ///
  /// In en, this message translates to:
  /// **'No wallets found'**
  String get noWalletsMatch;

  /// Wallets: screen reader hint for a row's long press
  ///
  /// In en, this message translates to:
  /// **'edit or delete'**
  String get walletActionsHint;

  /// Wallets: the hint under the list
  ///
  /// In en, this message translates to:
  /// **'Press and hold a wallet to edit or delete it'**
  String get walletRowHint;

  /// Wallet screen: under the wallet, its share of all the positive balances, e.g. '12%'
  ///
  /// In en, this message translates to:
  /// **'{percent} of your money'**
  String walletShareOfPositive(String percent);

  /// Wallet screen: under a wallet below zero
  ///
  /// In en, this message translates to:
  /// **'In the red · {amount}'**
  String walletInRedBy(String amount);

  /// Wallet screen: the tab with the wallet's cash flow and spending by category
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get walletAnalysis;

  /// A filter tile's count of the transactions it leaves
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 transactions} =1{1 transaction} other{{count} transactions}}'**
  String transactionsCountLabel(int count);

  /// Wallet form: heading of the leather colour choice
  ///
  /// In en, this message translates to:
  /// **'Leather colour'**
  String get leatherColour;

  /// Wallet form: a leather colour, for screen readers
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get leatherBlack;

  /// Wallet form: a leather colour, for screen readers
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get leatherYellow;

  /// Wallet form: a leather colour, for screen readers
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get leatherGreen;

  /// Wallet form: a leather colour, for screen readers
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get leatherWhite;

  /// Transaction row: what a long press does, read by screen readers
  ///
  /// In en, this message translates to:
  /// **'edit or delete'**
  String get transactionActionsHint;

  /// Under a list of transactions: how to edit or delete one
  ///
  /// In en, this message translates to:
  /// **'Press and hold a transaction to edit or delete it'**
  String get transactionRowHint;

  /// Delete wallet confirmation when the wallet has transactions, which are deleted with it
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\" and {count, plural, =0{its transactions} =1{its 1 transaction} other{its {count} transactions}}.'**
  String deleteWalletWithTransactions(String name, int count);

  /// Button under a loading error: loads it again
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// On a wallet's leather, over its balance
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get walletBalanceLabel;

  /// Over the new-transaction sheet's chips of the categories used last
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentCategories;

  /// App icon shortcut (press and hold the icon): opens the new-transaction sheet as an expense
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get newExpense;

  /// App icon shortcut (press and hold the icon): opens the new-transaction sheet as an income
  ///
  /// In en, this message translates to:
  /// **'New income'**
  String get newIncome;

  /// Home before any wallet: the button that opens the new wallet sheet
  ///
  /// In en, this message translates to:
  /// **'Create your first wallet'**
  String get createFirstWallet;

  /// Home's pill under the total before any transaction this month
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get noActivityYet;

  /// Home before any wallet: the placeholder for the month's cash flow card
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get monthSummary;

  /// Home before any wallet: when the month's summary appears
  ///
  /// In en, this message translates to:
  /// **'Shows up here after your first transaction.'**
  String get monthSummaryLater;

  /// Home before any wallet: the placeholder for the recent transactions
  ///
  /// In en, this message translates to:
  /// **'No transactions yet. Create a wallet first.'**
  String get recentTransactionsLater;

  /// Wallets screen header with no wallets, in place of the count
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get walletsNone;

  /// Settings: heading over currency, date format and theme
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// Settings: heading over categories
  ///
  /// In en, this message translates to:
  /// **'Organize'**
  String get settingsOrganize;

  /// Categories screen: heading over the categories that come with the app
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get categoriesBuiltIn;

  /// Categories screen: heading over the categories the user made
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get categoriesYours;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
