import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_it.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BudGator'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get languageSystem;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// No description provided for @googlePayEnableTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Google Pay detection'**
  String get googlePayEnableTitle;

  /// No description provided for @googlePayEnableBody.
  ///
  /// In en, this message translates to:
  /// **'To suggest payments automatically, Budgator needs access to notifications.'**
  String get googlePayEnableBody;

  /// No description provided for @laterAction.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get laterAction;

  /// No description provided for @openSettingsAction.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettingsAction;

  /// No description provided for @closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// No description provided for @copyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyAction;

  /// No description provided for @copiedCsvClipboard.
  ///
  /// In en, this message translates to:
  /// **'CSV copied to clipboard.'**
  String get copiedCsvClipboard;

  /// No description provided for @csvImportHint.
  ///
  /// In en, this message translates to:
  /// **'Paste CSV here (including header: id,title,amount,date,category,type)'**
  String get csvImportHint;

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @transactionsImportedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions imported.'**
  String transactionsImportedCount(int count);

  /// No description provided for @importFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importFailedGeneric;

  /// No description provided for @resetAppDataConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'All transactions, budgets, and savings goals will be reset to 0. Dark mode remains unchanged.'**
  String get resetAppDataConfirmBody;

  /// No description provided for @resetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetAction;

  /// No description provided for @appDataResetDone.
  ///
  /// In en, this message translates to:
  /// **'App data has been reset.'**
  String get appDataResetDone;

  /// No description provided for @paymentSavedTransaction.
  ///
  /// In en, this message translates to:
  /// **'Payment saved as transaction.'**
  String get paymentSavedTransaction;

  /// No description provided for @googlePayDetectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Pay payment detected'**
  String get googlePayDetectedTitle;

  /// No description provided for @paidAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid amount'**
  String get paidAmountLabel;

  /// No description provided for @paidAmountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 7.50'**
  String get paidAmountHint;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @ignoreAction.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get ignoreAction;

  /// No description provided for @invalidAmountMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount.'**
  String get invalidAmountMessage;

  /// No description provided for @googlePayPaymentDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Pay payment'**
  String get googlePayPaymentDefaultTitle;

  /// No description provided for @transactionDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction'**
  String get transactionDeleteTitle;

  /// No description provided for @transactionDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this transaction?'**
  String get transactionDeleteConfirm;

  /// No description provided for @editTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTransactionTitle;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @chooseAction.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get chooseAction;

  /// No description provided for @invalidValuesMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid values.'**
  String get invalidValuesMessage;

  /// No description provided for @saveAnywayAction.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get saveAnywayAction;

  /// No description provided for @overspendCategoryLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Category limit exceeded'**
  String get overspendCategoryLimitTitle;

  /// No description provided for @overspendNoSourceMessage.
  ///
  /// In en, this message translates to:
  /// **'{category} exceeded by {amount}. No other category has remaining budget to deduct. Save anyway?'**
  String overspendNoSourceMessage(Object category, Object amount);

  /// No description provided for @categoryExceededByMessage.
  ///
  /// In en, this message translates to:
  /// **'{category} exceeded by {amount}.'**
  String categoryExceededByMessage(Object category, Object amount);

  /// No description provided for @deductionSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Deduction from category could not be saved.'**
  String get deductionSaveFailed;

  /// No description provided for @overspendTotalBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Total budget exceeded'**
  String get overspendTotalBudgetTitle;

  /// No description provided for @overspendTotalBudgetMessage.
  ///
  /// In en, this message translates to:
  /// **'This expense exceeds monthly total budget by {amount}. Save anyway?'**
  String overspendTotalBudgetMessage(Object amount);

  /// No description provided for @overspendTransferQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to deduct this amount from another category?'**
  String get overspendTransferQuestion;

  /// No description provided for @deductValueFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Deduct value from'**
  String get deductValueFromLabel;

  /// No description provided for @deductionAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Deduction amount'**
  String get deductionAmountLabel;

  /// No description provided for @continueWithoutDeduction.
  ///
  /// In en, this message translates to:
  /// **'Continue without deduction'**
  String get continueWithoutDeduction;

  /// No description provided for @deductAmountAction.
  ///
  /// In en, this message translates to:
  /// **'Deduct amount'**
  String get deductAmountAction;

  /// No description provided for @newTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get newTransactionTitle;

  /// No description provided for @captureIncomeExpenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture income or expenses'**
  String get captureIncomeExpenseSubtitle;

  /// No description provided for @enterTitleValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get enterTitleValidation;

  /// No description provided for @enterAmountValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmountValidation;

  /// No description provided for @incomeTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income type'**
  String get incomeTypeLabel;

  /// No description provided for @salaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salaryLabel;

  /// No description provided for @otherIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Other income'**
  String get otherIncomeLabel;

  /// No description provided for @createCategoryAction.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get createCategoryAction;

  /// No description provided for @editTotalBudgetAction.
  ///
  /// In en, this message translates to:
  /// **'Change total budget'**
  String get editTotalBudgetAction;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @activeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String activeCount(int count);

  /// No description provided for @noBudgetCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories with budget'**
  String get noBudgetCategories;

  /// No description provided for @monthlyTotalBudgetChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change monthly total budget'**
  String get monthlyTotalBudgetChangeTitle;

  /// No description provided for @totalBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Total budget'**
  String get totalBudgetLabel;

  /// No description provided for @warningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warningTitle;

  /// No description provided for @budgetTooLowWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'The new budget ({newBudget}) is lower than already allocated categories ({allocated}). Please adjust categories.'**
  String budgetTooLowWarningMessage(Object newBudget, Object allocated);

  /// No description provided for @totalBudgetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Total budget updated'**
  String get totalBudgetUpdated;

  /// No description provided for @newCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategoryTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryNameLabel;

  /// No description provided for @budgetAllocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget allocation'**
  String get budgetAllocationLabel;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconLabel;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Category name is required'**
  String get categoryNameRequired;

  /// No description provided for @budgetMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Budget must be > 0'**
  String get budgetMustBePositive;

  /// No description provided for @budgetWouldBeExceededAvailable.
  ///
  /// In en, this message translates to:
  /// **'Budget would be exceeded. Available: {amount}'**
  String budgetWouldBeExceededAvailable(Object amount);

  /// No description provided for @categoryAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Category already exists'**
  String get categoryAlreadyExists;

  /// No description provided for @categoryAdded.
  ///
  /// In en, this message translates to:
  /// **'Category added'**
  String get categoryAdded;

  /// No description provided for @editCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String editCategoryTitle(Object name);

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @invalidAmountGeneric.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmountGeneric;

  /// No description provided for @budgetWouldBeExceededMax.
  ///
  /// In en, this message translates to:
  /// **'Budget would be exceeded. Max: {amount}'**
  String budgetWouldBeExceededMax(Object amount);

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated'**
  String get categoryUpdated;

  /// No description provided for @setupBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup budget'**
  String get setupBudgetTitle;

  /// No description provided for @setupBudgetDescription.
  ///
  /// In en, this message translates to:
  /// **'To manage expenses, first create a monthly total budget. You can then create categories and distribute the amount.'**
  String get setupBudgetDescription;

  /// No description provided for @createMonthlyBudgetAction.
  ///
  /// In en, this message translates to:
  /// **'Create monthly budget'**
  String get createMonthlyBudgetAction;

  /// No description provided for @monthlyBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudgetTitle;

  /// No description provided for @totalBudgetCurrentMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Total budget for this month'**
  String get totalBudgetCurrentMonthLabel;

  /// No description provided for @createAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createAction;

  /// No description provided for @invalidPositiveAmountMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount (> 0)'**
  String get invalidPositiveAmountMessage;

  /// No description provided for @monthlyBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudgetLabel;

  /// No description provided for @spentLabel.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spentLabel;

  /// No description provided for @allocatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Allocated: {amount}'**
  String allocatedLabel(Object amount);

  /// No description provided for @availableLabel.
  ///
  /// In en, this message translates to:
  /// **'Available: {amount}'**
  String availableLabel(Object amount);

  /// No description provided for @noBudgetSet.
  ///
  /// In en, this message translates to:
  /// **'No budget set'**
  String get noBudgetSet;

  /// No description provided for @overrunByLabel.
  ///
  /// In en, this message translates to:
  /// **'Exceeded by {amount}'**
  String overrunByLabel(Object amount);

  /// No description provided for @createSavingsGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Create savings goal'**
  String get createSavingsGoalTitle;

  /// No description provided for @editSavingsGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit savings goal'**
  String get editSavingsGoalTitle;

  /// No description provided for @goalNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get goalNameLabel;

  /// No description provided for @goalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get goalAmountLabel;

  /// No description provided for @alreadySavedLabel.
  ///
  /// In en, this message translates to:
  /// **'Already saved'**
  String get alreadySavedLabel;

  /// No description provided for @monthlyDeductionFormLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly deduction'**
  String get monthlyDeductionFormLabel;

  /// No description provided for @debitDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Debit day'**
  String get debitDayLabel;

  /// No description provided for @dayOfMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'{day}. of month'**
  String dayOfMonthLabel(int day);

  /// No description provided for @automationActive.
  ///
  /// In en, this message translates to:
  /// **'Automation active'**
  String get automationActive;

  /// No description provided for @automaticMonthlyDeductionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book monthly deduction automatically'**
  String get automaticMonthlyDeductionSubtitle;

  /// No description provided for @savingsGoalDeleted.
  ///
  /// In en, this message translates to:
  /// **'Savings goal deleted'**
  String get savingsGoalDeleted;

  /// No description provided for @enterValidValuesMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid values.'**
  String get enterValidValuesMessage;

  /// No description provided for @savedCannotExceedTarget.
  ///
  /// In en, this message translates to:
  /// **'Already saved amount cannot exceed target.'**
  String get savedCannotExceedTarget;

  /// No description provided for @savingsGoalCreated.
  ///
  /// In en, this message translates to:
  /// **'Savings goal created'**
  String get savingsGoalCreated;

  /// No description provided for @savingsGoalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Savings goal updated'**
  String get savingsGoalUpdated;

  /// No description provided for @depositIntoGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit to {name}'**
  String depositIntoGoalTitle(Object name);

  /// No description provided for @depositAction.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get depositAction;

  /// No description provided for @goalAlreadyReached.
  ///
  /// In en, this message translates to:
  /// **'Goal is already fully reached.'**
  String get goalAlreadyReached;

  /// No description provided for @depositedAmountMessage.
  ///
  /// In en, this message translates to:
  /// **'{amount} deposited'**
  String depositedAmountMessage(Object amount);

  /// No description provided for @newSavingsGoalAction.
  ///
  /// In en, this message translates to:
  /// **'New savings goal'**
  String get newSavingsGoalAction;

  /// No description provided for @noSavingsGoalsHint.
  ///
  /// In en, this message translates to:
  /// **'No savings goals yet. Create a goal with monthly deduction.'**
  String get noSavingsGoalsHint;

  /// No description provided for @monthlyDeductionValue.
  ///
  /// In en, this message translates to:
  /// **'Monthly deduction: {amount}'**
  String monthlyDeductionValue(Object amount);

  /// No description provided for @debitDayValue.
  ///
  /// In en, this message translates to:
  /// **'Debit: {day}. of month'**
  String debitDayValue(int day);

  /// No description provided for @depositShortAction.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get depositShortAction;

  /// No description provided for @editShortAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editShortAction;

  /// No description provided for @noTransactionsRecent.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get noTransactionsRecent;

  /// No description provided for @recentTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactionsTitle;

  /// No description provided for @allAction.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allAction;

  /// No description provided for @noExpensesLast30Days.
  ///
  /// In en, this message translates to:
  /// **'No expenses in the last 30 days'**
  String get noExpensesLast30Days;

  /// No description provided for @noCategoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get noCategoriesLabel;

  /// No description provided for @topCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Top categories'**
  String get topCategoriesTitle;

  /// No description provided for @expensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesLabel;

  /// No description provided for @monthlyBudgetRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget remaining'**
  String get monthlyBudgetRemainingLabel;

  /// No description provided for @expensesTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense trend'**
  String get expensesTrendTitle;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @weekLabel.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get weekLabel;

  /// No description provided for @monthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthLabel;

  /// No description provided for @savingsGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get savingsGoalsTitle;

  /// No description provided for @noActiveSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'No active savings goal yet.'**
  String get noActiveSavingsGoal;

  /// No description provided for @createSavingsGoalAction.
  ///
  /// In en, this message translates to:
  /// **'Create savings goal'**
  String get createSavingsGoalAction;

  /// No description provided for @savingsGoalHeader.
  ///
  /// In en, this message translates to:
  /// **'Savings goal: {name}'**
  String savingsGoalHeader(Object name);

  /// No description provided for @goalNameInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalNameInputLabel;

  /// No description provided for @targetAmountInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get targetAmountInputLabel;

  /// No description provided for @currentOfTarget.
  ///
  /// In en, this message translates to:
  /// **'{current} of {target}'**
  String currentOfTarget(Object current, Object target);

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get availableBalance;

  /// No description provided for @okAction.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okAction;

  /// No description provided for @savingsGoalEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit savings goal'**
  String get savingsGoalEditTitle;

  /// No description provided for @savingsGoalNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get savingsGoalNameLabel;

  /// No description provided for @savingsGoalTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal amount'**
  String get savingsGoalTargetLabel;

  /// No description provided for @goalDepositTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} deposit'**
  String goalDepositTransactionTitle(Object name);

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @followsDeviceSetting.
  ///
  /// In en, this message translates to:
  /// **'Follows device setting'**
  String get followsDeviceSetting;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @csvExport.
  ///
  /// In en, this message translates to:
  /// **'CSV Export'**
  String get csvExport;

  /// No description provided for @csvImport.
  ///
  /// In en, this message translates to:
  /// **'CSV Import'**
  String get csvImport;

  /// No description provided for @copyTransactionsAsCsv.
  ///
  /// In en, this message translates to:
  /// **'Copy transactions as CSV'**
  String get copyTransactionsAsCsv;

  /// No description provided for @importTransactionsFromCsv.
  ///
  /// In en, this message translates to:
  /// **'Import transactions from CSV'**
  String get importTransactionsFromCsv;

  /// No description provided for @resetAppData.
  ///
  /// In en, this message translates to:
  /// **'Reset app data'**
  String get resetAppData;

  /// No description provided for @resetBudgetsGoalsTransactions.
  ///
  /// In en, this message translates to:
  /// **'Resets budgets, goals, and transactions to 0'**
  String get resetBudgetsGoalsTransactions;

  /// No description provided for @budgetAndGoals.
  ///
  /// In en, this message translates to:
  /// **'Budget & Savings Goals'**
  String get budgetAndGoals;

  /// No description provided for @budgetsTab.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTab;

  /// No description provided for @savingsGoalsTab.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get savingsGoalsTab;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsBookingsInRange.
  ///
  /// In en, this message translates to:
  /// **'{count} entries in range'**
  String statsBookingsInRange(int count);

  /// No description provided for @coreMetrics.
  ///
  /// In en, this message translates to:
  /// **'Core metrics'**
  String get coreMetrics;

  /// No description provided for @weeklyTrend.
  ///
  /// In en, this message translates to:
  /// **'Weekly trend'**
  String get weeklyTrend;

  /// No description provided for @categoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Category split'**
  String get categoryBreakdown;

  /// No description provided for @weekdayPattern.
  ///
  /// In en, this message translates to:
  /// **'Weekday pattern'**
  String get weekdayPattern;

  /// No description provided for @statsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No data for statistics yet'**
  String get statsEmptyTitle;

  /// No description provided for @statsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'As soon as you add transactions, you will see trends, categories and savings rate here.'**
  String get statsEmptySubtitle;

  /// No description provided for @statsPositiveTrend.
  ///
  /// In en, this message translates to:
  /// **'You are saving in the trend'**
  String get statsPositiveTrend;

  /// No description provided for @statsNegativeTrend.
  ///
  /// In en, this message translates to:
  /// **'Expenses are currently too high'**
  String get statsNegativeTrend;

  /// No description provided for @netInRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Net in {range} (income - expenses)'**
  String netInRangeLabel(Object range);

  /// No description provided for @incomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeLabel;

  /// No description provided for @expensesPerDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Expenses / day'**
  String get expensesPerDayLabel;

  /// No description provided for @largestExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Largest expense'**
  String get largestExpenseLabel;

  /// No description provided for @activeDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get activeDaysLabel;

  /// No description provided for @savingsRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Savings rate'**
  String get savingsRateLabel;

  /// No description provided for @noExpenseStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'no-spend: {days} days'**
  String noExpenseStreakLabel(int days);

  /// No description provided for @noExpensesInRange.
  ///
  /// In en, this message translates to:
  /// **'No expenses in the selected range.'**
  String get noExpensesInRange;

  /// No description provided for @weeklyAverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Average week'**
  String get weeklyAverageLabel;

  /// No description provided for @trendLabel.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trendLabel;

  /// No description provided for @weeklyBarsHint.
  ///
  /// In en, this message translates to:
  /// **'Each bar = one week. This helps you see outliers and trend shifts immediately.'**
  String get weeklyBarsHint;

  /// No description provided for @noCategoryExpenses.
  ///
  /// In en, this message translates to:
  /// **'No categories with expenses yet.'**
  String get noCategoryExpenses;

  /// No description provided for @noWeekdayExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses by weekday yet.'**
  String get noWeekdayExpenses;

  /// No description provided for @highestExpenseDayHint.
  ///
  /// In en, this message translates to:
  /// **'Rank 1 = highest spending day. The color intensity shows the difference at a glance.'**
  String get highestExpenseDayHint;

  /// No description provided for @weekLabelPrefix.
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String weekLabelPrefix(Object week);

  /// No description provided for @categoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryCafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get categoryCafe;

  /// No description provided for @range7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get range7Days;

  /// No description provided for @range30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get range30Days;

  /// No description provided for @range90Days.
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get range90Days;

  /// No description provided for @rangeAll.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get rangeAll;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;

  /// No description provided for @tabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tabAll;

  /// No description provided for @tabIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get tabIncome;

  /// No description provided for @tabExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get tabExpenses;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get noTransactions;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;
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
      <String>['de', 'en', 'es', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
