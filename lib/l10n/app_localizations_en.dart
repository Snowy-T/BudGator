// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BudGator';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System language';

  @override
  String get languageGerman => 'German';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get homeLabel => 'Home';

  @override
  String get googlePayEnableTitle => 'Enable Google Pay detection';

  @override
  String get googlePayEnableBody =>
      'To suggest payments automatically, Budgator needs access to notifications.';

  @override
  String get laterAction => 'Later';

  @override
  String get openSettingsAction => 'Open settings';

  @override
  String get closeAction => 'Close';

  @override
  String get copyAction => 'Copy';

  @override
  String get copiedCsvClipboard => 'CSV copied to clipboard.';

  @override
  String get csvImportHint =>
      'Paste CSV here (including header: id,title,amount,date,category,type)';

  @override
  String get importAction => 'Import';

  @override
  String transactionsImportedCount(int count) {
    return '$count transactions imported.';
  }

  @override
  String get importFailedGeneric => 'Import failed';

  @override
  String get resetAppDataConfirmBody =>
      'All transactions, budgets, and savings goals will be reset to 0. Dark mode remains unchanged.';

  @override
  String get resetAction => 'Reset';

  @override
  String get appDataResetDone => 'App data has been reset.';

  @override
  String get paymentSavedTransaction => 'Payment saved as transaction.';

  @override
  String get googlePayDetectedTitle => 'Google Pay payment detected';

  @override
  String get paidAmountLabel => 'Paid amount';

  @override
  String get paidAmountHint => 'e.g. 7.50';

  @override
  String get titleLabel => 'Title';

  @override
  String get categoryLabel => 'Category';

  @override
  String get ignoreAction => 'Ignore';

  @override
  String get invalidAmountMessage => 'Please enter a valid amount.';

  @override
  String get googlePayPaymentDefaultTitle => 'Google Pay payment';

  @override
  String get transactionDeleteTitle => 'Delete transaction';

  @override
  String get transactionDeleteConfirm =>
      'Do you really want to delete this transaction?';

  @override
  String get editTransactionTitle => 'Edit transaction';

  @override
  String get typeLabel => 'Type';

  @override
  String get dateLabel => 'Date';

  @override
  String get chooseAction => 'Choose';

  @override
  String get invalidValuesMessage => 'Please enter valid values.';

  @override
  String get saveAnywayAction => 'Save anyway';

  @override
  String get overspendCategoryLimitTitle => 'Category limit exceeded';

  @override
  String overspendNoSourceMessage(Object category, Object amount) {
    return '$category exceeded by $amount. No other category has remaining budget to deduct. Save anyway?';
  }

  @override
  String categoryExceededByMessage(Object category, Object amount) {
    return '$category exceeded by $amount.';
  }

  @override
  String get deductionSaveFailed =>
      'Deduction from category could not be saved.';

  @override
  String get overspendTotalBudgetTitle => 'Total budget exceeded';

  @override
  String overspendTotalBudgetMessage(Object amount) {
    return 'This expense exceeds monthly total budget by $amount. Save anyway?';
  }

  @override
  String get overspendTransferQuestion =>
      'Do you want to deduct this amount from another category?';

  @override
  String get deductValueFromLabel => 'Deduct value from';

  @override
  String get deductionAmountLabel => 'Deduction amount';

  @override
  String get continueWithoutDeduction => 'Continue without deduction';

  @override
  String get deductAmountAction => 'Deduct amount';

  @override
  String get newTransactionTitle => 'New transaction';

  @override
  String get captureIncomeExpenseSubtitle => 'Capture income or expenses';

  @override
  String get enterTitleValidation => 'Enter a title';

  @override
  String get enterAmountValidation => 'Enter amount';

  @override
  String get incomeTypeLabel => 'Income type';

  @override
  String get salaryLabel => 'Salary';

  @override
  String get otherIncomeLabel => 'Other income';

  @override
  String get createCategoryAction => 'Add category';

  @override
  String get editTotalBudgetAction => 'Change total budget';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String activeCount(int count) {
    return '$count active';
  }

  @override
  String get noBudgetCategories => 'No categories with budget';

  @override
  String get monthlyTotalBudgetChangeTitle => 'Change monthly total budget';

  @override
  String get totalBudgetLabel => 'Total budget';

  @override
  String get warningTitle => 'Warning';

  @override
  String budgetTooLowWarningMessage(Object newBudget, Object allocated) {
    return 'The new budget ($newBudget) is lower than already allocated categories ($allocated). Please adjust categories.';
  }

  @override
  String get totalBudgetUpdated => 'Total budget updated';

  @override
  String get newCategoryTitle => 'New category';

  @override
  String get categoryNameLabel => 'Category name';

  @override
  String get budgetAllocationLabel => 'Budget allocation';

  @override
  String get colorLabel => 'Color';

  @override
  String get iconLabel => 'Icon';

  @override
  String get addAction => 'Add';

  @override
  String get categoryNameRequired => 'Category name is required';

  @override
  String get budgetMustBePositive => 'Budget must be > 0';

  @override
  String budgetWouldBeExceededAvailable(Object amount) {
    return 'Budget would be exceeded. Available: $amount';
  }

  @override
  String get categoryAlreadyExists => 'Category already exists';

  @override
  String get categoryAdded => 'Category added';

  @override
  String editCategoryTitle(Object name) {
    return 'Edit $name';
  }

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get invalidAmountGeneric => 'Invalid amount';

  @override
  String budgetWouldBeExceededMax(Object amount) {
    return 'Budget would be exceeded. Max: $amount';
  }

  @override
  String get categoryUpdated => 'Category updated';

  @override
  String get setupBudgetTitle => 'Setup budget';

  @override
  String get setupBudgetDescription =>
      'To manage expenses, first create a monthly total budget. You can then create categories and distribute the amount.';

  @override
  String get createMonthlyBudgetAction => 'Create monthly budget';

  @override
  String get monthlyBudgetTitle => 'Monthly budget';

  @override
  String get totalBudgetCurrentMonthLabel => 'Total budget for this month';

  @override
  String get createAction => 'Create';

  @override
  String get invalidPositiveAmountMessage =>
      'Please enter a valid amount (> 0)';

  @override
  String get monthlyBudgetLabel => 'Monthly budget';

  @override
  String get spentLabel => 'Spent';

  @override
  String allocatedLabel(Object amount) {
    return 'Allocated: $amount';
  }

  @override
  String availableLabel(Object amount) {
    return 'Available: $amount';
  }

  @override
  String get noBudgetSet => 'No budget set';

  @override
  String overrunByLabel(Object amount) {
    return 'Exceeded by $amount';
  }

  @override
  String get createSavingsGoalTitle => 'Create savings goal';

  @override
  String get editSavingsGoalTitle => 'Edit savings goal';

  @override
  String get goalNameLabel => 'Name';

  @override
  String get goalAmountLabel => 'Target amount';

  @override
  String get alreadySavedLabel => 'Already saved';

  @override
  String get monthlyDeductionFormLabel => 'Monthly deduction';

  @override
  String get debitDayLabel => 'Debit day';

  @override
  String dayOfMonthLabel(int day) {
    return '$day. of month';
  }

  @override
  String get automationActive => 'Automation active';

  @override
  String get automaticMonthlyDeductionSubtitle =>
      'Book monthly deduction automatically';

  @override
  String get savingsGoalDeleted => 'Savings goal deleted';

  @override
  String get enterValidValuesMessage => 'Please enter valid values.';

  @override
  String get savedCannotExceedTarget =>
      'Already saved amount cannot exceed target.';

  @override
  String get savingsGoalCreated => 'Savings goal created';

  @override
  String get savingsGoalUpdated => 'Savings goal updated';

  @override
  String depositIntoGoalTitle(Object name) {
    return 'Deposit to $name';
  }

  @override
  String get depositAction => 'Deposit';

  @override
  String get goalAlreadyReached => 'Goal is already fully reached.';

  @override
  String depositedAmountMessage(Object amount) {
    return '$amount deposited';
  }

  @override
  String get newSavingsGoalAction => 'New savings goal';

  @override
  String get noSavingsGoalsHint =>
      'No savings goals yet. Create a goal with monthly deduction.';

  @override
  String monthlyDeductionValue(Object amount) {
    return 'Monthly deduction: $amount';
  }

  @override
  String debitDayValue(int day) {
    return 'Debit: $day. of month';
  }

  @override
  String get depositShortAction => 'Deposit';

  @override
  String get editShortAction => 'Edit';

  @override
  String get noTransactionsRecent => 'No transactions';

  @override
  String get recentTransactionsTitle => 'Recent transactions';

  @override
  String get allAction => 'All';

  @override
  String get noExpensesLast30Days => 'No expenses in the last 30 days';

  @override
  String get noCategoriesLabel => 'No categories';

  @override
  String get topCategoriesTitle => 'Top categories';

  @override
  String get expensesLabel => 'Expenses';

  @override
  String get monthlyBudgetRemainingLabel => 'Monthly budget remaining';

  @override
  String get expensesTrendTitle => 'Expense trend';

  @override
  String get todayLabel => 'Today';

  @override
  String get weekLabel => 'Week';

  @override
  String get monthLabel => 'Month';

  @override
  String get savingsGoalsTitle => 'Savings goals';

  @override
  String get noActiveSavingsGoal => 'No active savings goal yet.';

  @override
  String get createSavingsGoalAction => 'Create savings goal';

  @override
  String savingsGoalHeader(Object name) {
    return 'Savings goal: $name';
  }

  @override
  String get goalNameInputLabel => 'Goal name';

  @override
  String get targetAmountInputLabel => 'Target amount';

  @override
  String currentOfTarget(Object current, Object target) {
    return '$current of $target';
  }

  @override
  String get availableBalance => 'Available balance';

  @override
  String get okAction => 'OK';

  @override
  String get savingsGoalEditTitle => 'Edit savings goal';

  @override
  String get savingsGoalNameLabel => 'Goal name';

  @override
  String get savingsGoalTargetLabel => 'Goal amount';

  @override
  String goalDepositTransactionTitle(Object name) {
    return '$name deposit';
  }

  @override
  String get darkMode => 'Dark mode';

  @override
  String get followsDeviceSetting => 'Follows device setting';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get csvExport => 'CSV Export';

  @override
  String get csvImport => 'CSV Import';

  @override
  String get copyTransactionsAsCsv => 'Copy transactions as CSV';

  @override
  String get importTransactionsFromCsv => 'Import transactions from CSV';

  @override
  String get resetAppData => 'Reset app data';

  @override
  String get resetBudgetsGoalsTransactions =>
      'Resets budgets, goals, and transactions to 0';

  @override
  String get budgetAndGoals => 'Budget & Savings Goals';

  @override
  String get budgetsTab => 'Budgets';

  @override
  String get savingsGoalsTab => 'Savings Goals';

  @override
  String get statsTitle => 'Statistics';

  @override
  String statsBookingsInRange(int count) {
    return '$count entries in range';
  }

  @override
  String get coreMetrics => 'Core metrics';

  @override
  String get weeklyTrend => 'Weekly trend';

  @override
  String get categoryBreakdown => 'Category split';

  @override
  String get weekdayPattern => 'Weekday pattern';

  @override
  String get statsEmptyTitle => 'No data for statistics yet';

  @override
  String get statsEmptySubtitle =>
      'As soon as you add transactions, you will see trends, categories and savings rate here.';

  @override
  String get statsPositiveTrend => 'You are saving in the trend';

  @override
  String get statsNegativeTrend => 'Expenses are currently too high';

  @override
  String netInRangeLabel(Object range) {
    return 'Net in $range (income - expenses)';
  }

  @override
  String get incomeLabel => 'Income';

  @override
  String get expensesPerDayLabel => 'Expenses / day';

  @override
  String get largestExpenseLabel => 'Largest expense';

  @override
  String get activeDaysLabel => 'Active days';

  @override
  String get savingsRateLabel => 'Savings rate';

  @override
  String noExpenseStreakLabel(int days) {
    return 'no-spend: $days days';
  }

  @override
  String get noExpensesInRange => 'No expenses in the selected range.';

  @override
  String get weeklyAverageLabel => 'Average week';

  @override
  String get trendLabel => 'Trend';

  @override
  String get weeklyBarsHint =>
      'Each bar = one week. This helps you see outliers and trend shifts immediately.';

  @override
  String get noCategoryExpenses => 'No categories with expenses yet.';

  @override
  String get noWeekdayExpenses => 'No expenses by weekday yet.';

  @override
  String get highestExpenseDayHint =>
      'Rank 1 = highest spending day. The color intensity shows the difference at a glance.';

  @override
  String weekLabelPrefix(Object week) {
    return 'Week $week';
  }

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryCafe => 'Cafe';

  @override
  String get range7Days => '7 days';

  @override
  String get range30Days => '30 days';

  @override
  String get range90Days => '90 days';

  @override
  String get rangeAll => 'Overall';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get tabAll => 'All';

  @override
  String get tabIncome => 'Income';

  @override
  String get tabExpenses => 'Expenses';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get addTransaction => 'Add transaction';
}
