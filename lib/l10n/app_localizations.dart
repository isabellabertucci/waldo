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

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Waldo'**
  String get appTitle;

  /// Dashboard tab label
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
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
  /// **'Tap + to add your first wallet'**
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

  /// Label inside the starting balance field of the new-wallet form
  ///
  /// In en, this message translates to:
  /// **'How much is in it today?'**
  String get startingBalancePrompt;

  /// Tag beside a form section title that doesn't need filling in
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

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
  /// **'There was a problem loading your wallets. Please try again.'**
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

  /// Accessibility label and tooltip for the backspace key on the amount keypad
  ///
  /// In en, this message translates to:
  /// **'Delete digit'**
  String get deleteDigit;

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

  /// Screen reader hint on the dashboard's month receipt, which opens the transaction list when tapped
  ///
  /// In en, this message translates to:
  /// **'Opens all transactions'**
  String get receiptHint;

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
  /// **'Tap + to add your first transaction'**
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

  /// Caption above the amount keypad, e.g. 'Expense · editing amount'
  ///
  /// In en, this message translates to:
  /// **'{type} · editing amount'**
  String editingAmountLabel(String type);

  /// Title of the dialog shown when leaving a field editor with unsaved edits
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// Message of the dialog shown when leaving a field editor with unsaved edits
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes to this field.'**
  String get discardChangesMessage;

  /// Discard button label, paired with Save on the unsaved-changes dialog
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

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
  /// **'There was a problem loading your transactions. Please try again.'**
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

  /// Empty state title for categories list
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesYet;

  /// Empty state subtitle for categories list
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first category'**
  String get addFirstCategory;

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

  /// Link from the transaction form to manage categories
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get manageCategories;

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

  /// Tooltip for the button that adds the typed category name
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

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
  /// **'There was a problem loading your categories. Please try again.'**
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

  /// Section header grouping the currency and date format rows in settings
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get moneySection;

  /// Section header grouping the theme row in settings
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// Subtitle under the Currency row in settings
  ///
  /// In en, this message translates to:
  /// **'How amounts are shown'**
  String get currencyRowSubtitle;

  /// Subtitle under the Date format row in settings
  ///
  /// In en, this message translates to:
  /// **'Used for a transaction\'s date'**
  String get dateFormatRowSubtitle;

  /// Notice shown at the bottom of the currency picker sheet
  ///
  /// In en, this message translates to:
  /// **'This changes the symbol only. Your amounts stay the same and are not converted.'**
  String get currencyChangeNotice;

  /// Generic error message shown when preferences fail to load
  ///
  /// In en, this message translates to:
  /// **'There was a problem loading your preferences. Please try again.'**
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
  /// **'There was a problem loading your dashboard. Please try again.'**
  String get dashboardError;

  /// Header line on the dashboard's receipt-style monthly summary, e.g. 'WALDO · OCTOBER 2026'
  ///
  /// In en, this message translates to:
  /// **'WALDO · {month} {year}'**
  String dashboardReceiptHeader(String month, String year);

  /// Receipt line for this month's expenses that have no category (never set, or their category was deleted)
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// Label for this month's income minus expenses (can be negative), shown (uppercased) as the total row of the dashboard's receipt. Deliberately not 'saved', which reads as money put into savings
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get monthNetLabel;

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

  /// Button label in the dashboard's category spending empty state
  ///
  /// In en, this message translates to:
  /// **'Add first transaction'**
  String get addFirstTransactionButton;

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

  /// Label on the dashed placeholder card peeking behind the balance card when there are no wallets yet
  ///
  /// In en, this message translates to:
  /// **'Slide in your first wallet'**
  String get firstRunPeekCta;

  /// Message shown in place of the receipt body when there are no wallets yet
  ///
  /// In en, this message translates to:
  /// **'Your month\'s receipt prints here after the first transaction.'**
  String get dashboardReceiptNoWallet;

  /// Wallet count shown on the balance card's empty state, always exactly zero
  ///
  /// In en, this message translates to:
  /// **'0 wallets'**
  String get zeroWalletsLabel;

  /// Title of the wallet transactions filter bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTitle;

  /// Screen reader hint on the button that shows the current month and type filter and opens the filter sheet
  ///
  /// In en, this message translates to:
  /// **'Opens the filter'**
  String get filterHint;

  /// Link that clears the filter bottom sheet back to its defaults
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filterReset;

  /// Section label (shown uppercased) above the month grid in the filter sheet
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get filterSectionMonth;

  /// Name of the month selector's left chevron, which scrolls to earlier months
  ///
  /// In en, this message translates to:
  /// **'Earlier months'**
  String get earlierMonths;

  /// Name of the month selector's right chevron, which scrolls to later months
  ///
  /// In en, this message translates to:
  /// **'Later months'**
  String get laterMonths;

  /// Section label (shown uppercased) above the income/expense toggle in the filter sheet
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterSectionType;

  /// Option in the filter sheet's type toggle that includes both income and expense
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterTypeAll;

  /// Button label at the bottom of the filter sheet, previewing how many transactions match the selection so far
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Show 1 transaction} other{Show {count} transactions}}'**
  String filterShowTransactions(int count);

  /// Filter chip label on the wallet transactions screen, e.g. 'All transactions' or 'Income transactions' - type is already localized
  ///
  /// In en, this message translates to:
  /// **'{type} transactions'**
  String filterChipLabel(String type);

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

  /// Caption on the wallets screen: the share of this month's income not spent, e.g. 'Kept 60% of what you received' - percent is pre-formatted
  ///
  /// In en, this message translates to:
  /// **'Kept {percent} of what you received'**
  String keptPercentThisMonth(String percent);

  /// Caption on the wallets screen when this month's expenses exceed its income, e.g. 'Spent 50% more than you received' - percent is pre-formatted and positive
  ///
  /// In en, this message translates to:
  /// **'Spent {percent} more than you received'**
  String overspentPercentThisMonth(String percent);

  /// Fallback caption on the wallets screen's fixed total balance bar when there's no income yet this month to compute a savings percentage
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 wallet} other{{count} wallets}}'**
  String walletsCountLabel(int count);
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
