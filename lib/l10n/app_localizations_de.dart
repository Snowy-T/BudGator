// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'BudGator';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'Systemsprache';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italienisch';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get homeLabel => 'Home';

  @override
  String get googlePayEnableTitle => 'Google Pay Erkennung aktivieren';

  @override
  String get googlePayEnableBody =>
      'Damit Zahlungen automatisch vorgeschlagen werden, braucht Budgator Zugriff auf Benachrichtigungen.';

  @override
  String get laterAction => 'Spaeter';

  @override
  String get openSettingsAction => 'Einstellungen oeffnen';

  @override
  String get closeAction => 'Schliessen';

  @override
  String get copyAction => 'Kopieren';

  @override
  String get copiedCsvClipboard => 'CSV in die Zwischenablage kopiert.';

  @override
  String get csvImportHint =>
      'CSV hier einfuegen (inkl. Header: id,title,amount,date,category,type)';

  @override
  String get importAction => 'Importieren';

  @override
  String transactionsImportedCount(int count) {
    return '$count Transaktionen importiert.';
  }

  @override
  String get importFailedGeneric => 'Import fehlgeschlagen';

  @override
  String get resetAppDataConfirmBody =>
      'Alle Transaktionen, Budgets und Sparziele werden auf 0 zurueckgesetzt. Der Darkmode bleibt unveraendert.';

  @override
  String get resetAction => 'Zuruecksetzen';

  @override
  String get appDataResetDone => 'App-Daten wurden zurueckgesetzt.';

  @override
  String get paymentSavedTransaction => 'Zahlung als Transaktion gespeichert.';

  @override
  String get googlePayDetectedTitle => 'Google Pay Zahlung erkannt';

  @override
  String get paidAmountLabel => 'Bezahlter Betrag';

  @override
  String get paidAmountHint => 'z. B. 7,50';

  @override
  String get titleLabel => 'Titel';

  @override
  String get categoryLabel => 'Kategorie';

  @override
  String get ignoreAction => 'Ignorieren';

  @override
  String get invalidAmountMessage => 'Bitte gueltigen Betrag eingeben.';

  @override
  String get googlePayPaymentDefaultTitle => 'Google Pay Zahlung';

  @override
  String get transactionDeleteTitle => 'Transaktion loeschen';

  @override
  String get transactionDeleteConfirm =>
      'Moechtest du diese Transaktion wirklich loeschen?';

  @override
  String get editTransactionTitle => 'Transaktion bearbeiten';

  @override
  String get typeLabel => 'Typ';

  @override
  String get dateLabel => 'Datum';

  @override
  String get chooseAction => 'Waehlen';

  @override
  String get invalidValuesMessage => 'Bitte gueltige Werte eingeben.';

  @override
  String get saveAnywayAction => 'Trotzdem speichern';

  @override
  String get overspendCategoryLimitTitle => 'Kategorie-Limit ueberschritten';

  @override
  String overspendNoSourceMessage(Object category, Object amount) {
    return '$category wurde um $amount ueberschritten. Keine andere Kategorie hat Restbudget zum Abziehen. Trotzdem speichern?';
  }

  @override
  String categoryExceededByMessage(Object category, Object amount) {
    return '$category wurde um $amount ueberschritten.';
  }

  @override
  String get deductionSaveFailed =>
      'Abzug aus der Kategorie konnte nicht gespeichert werden.';

  @override
  String get overspendTotalBudgetTitle => 'Gesamtbudget ueberschritten';

  @override
  String overspendTotalBudgetMessage(Object amount) {
    return 'Diese Ausgabe liegt ueber dem monatlichen Gesamtbudget um $amount. Trotzdem speichern?';
  }

  @override
  String get overspendTransferQuestion =>
      'Moechtest du diesen Betrag von einer anderen Kategorie abziehen?';

  @override
  String get deductValueFromLabel => 'Wert abziehen von';

  @override
  String get deductionAmountLabel => 'Abzugsbetrag';

  @override
  String get continueWithoutDeduction => 'Ohne Abzug fortfahren';

  @override
  String get deductAmountAction => 'Betrag abziehen';

  @override
  String get newTransactionTitle => 'Neue Transaktion';

  @override
  String get captureIncomeExpenseSubtitle => 'Erfasse Einnahmen oder Ausgaben';

  @override
  String get enterTitleValidation => 'Titel eingeben';

  @override
  String get enterAmountValidation => 'Betrag eingeben';

  @override
  String get incomeTypeLabel => 'Einnahme-Typ';

  @override
  String get salaryLabel => 'Gehalt';

  @override
  String get otherIncomeLabel => 'Andere Einnahme';

  @override
  String get createCategoryAction => 'Kategorie hinzufuegen';

  @override
  String get editTotalBudgetAction => 'Gesamtbudget aendern';

  @override
  String get categoriesTitle => 'Kategorien';

  @override
  String activeCount(int count) {
    return '$count aktiv';
  }

  @override
  String get noBudgetCategories => 'Keine Kategorien mit Budget vorhanden';

  @override
  String get monthlyTotalBudgetChangeTitle =>
      'Monatliches Gesamtbudget aendern';

  @override
  String get totalBudgetLabel => 'Gesamtbudget';

  @override
  String get warningTitle => 'Warnung';

  @override
  String budgetTooLowWarningMessage(Object newBudget, Object allocated) {
    return 'Das neue Budget ($newBudget) ist kleiner als bereits verteilte Kategorien ($allocated). Bitte passe die Kategorien an.';
  }

  @override
  String get totalBudgetUpdated => 'Gesamtbudget aktualisiert';

  @override
  String get newCategoryTitle => 'Neue Kategorie';

  @override
  String get categoryNameLabel => 'Kategoriename';

  @override
  String get budgetAllocationLabel => 'Budget-Zuweisung';

  @override
  String get colorLabel => 'Farbe';

  @override
  String get iconLabel => 'Icon';

  @override
  String get addAction => 'Hinzufuegen';

  @override
  String get categoryNameRequired => 'Kategoriename ist erforderlich';

  @override
  String get budgetMustBePositive => 'Budget muss > 0 sein';

  @override
  String budgetWouldBeExceededAvailable(Object amount) {
    return 'Budget wuerde ueberschritten. Verfuegbar: $amount';
  }

  @override
  String get categoryAlreadyExists => 'Kategorie existiert bereits';

  @override
  String get categoryAdded => 'Kategorie hinzugefuegt';

  @override
  String editCategoryTitle(Object name) {
    return '$name bearbeiten';
  }

  @override
  String get categoryDeleted => 'Kategorie geloescht';

  @override
  String get invalidAmountGeneric => 'Ungueltiger Betrag';

  @override
  String budgetWouldBeExceededMax(Object amount) {
    return 'Budget wuerde ueberschritten. Max: $amount';
  }

  @override
  String get categoryUpdated => 'Kategorie aktualisiert';

  @override
  String get setupBudgetTitle => 'Budget einrichten';

  @override
  String get setupBudgetDescription =>
      'Um Ausgaben zu verwalten, richte zuerst ein monatliches Gesamtbudget ein. Danach kannst du Kategorien erstellen und den Betrag verteilen.';

  @override
  String get createMonthlyBudgetAction => 'Monatsbudget erstellen';

  @override
  String get monthlyBudgetTitle => 'Monatsbudget';

  @override
  String get totalBudgetCurrentMonthLabel => 'Gesamtbudget fuer diesen Monat';

  @override
  String get createAction => 'Erstellen';

  @override
  String get invalidPositiveAmountMessage =>
      'Bitte einen gueltigen Betrag (> 0) eingeben';

  @override
  String get monthlyBudgetLabel => 'Monatsbudget';

  @override
  String get spentLabel => 'Ausgegeben';

  @override
  String allocatedLabel(Object amount) {
    return 'Verteilt: $amount';
  }

  @override
  String availableLabel(Object amount) {
    return 'Verfuegbar: $amount';
  }

  @override
  String get noBudgetSet => 'Kein Budget gesetzt';

  @override
  String overrunByLabel(Object amount) {
    return 'Ueberschritten um $amount';
  }

  @override
  String get createSavingsGoalTitle => 'Sparziel erstellen';

  @override
  String get editSavingsGoalTitle => 'Sparziel bearbeiten';

  @override
  String get goalNameLabel => 'Name';

  @override
  String get goalAmountLabel => 'Zielbetrag';

  @override
  String get alreadySavedLabel => 'Bereits gespart';

  @override
  String get monthlyDeductionFormLabel => 'Monatlicher Abzug';

  @override
  String get debitDayLabel => 'Abbuchungstag';

  @override
  String dayOfMonthLabel(int day) {
    return '$day. des Monats';
  }

  @override
  String get automationActive => 'Automatik aktiv';

  @override
  String get automaticMonthlyDeductionSubtitle =>
      'Monatlichen Abzug automatisch verbuchen';

  @override
  String get savingsGoalDeleted => 'Sparziel geloescht';

  @override
  String get enterValidValuesMessage => 'Bitte valide Werte eingeben.';

  @override
  String get savedCannotExceedTarget =>
      'Bereits gespart darf Ziel nicht ueberschreiten.';

  @override
  String get savingsGoalCreated => 'Sparziel erstellt';

  @override
  String get savingsGoalUpdated => 'Sparziel aktualisiert';

  @override
  String depositIntoGoalTitle(Object name) {
    return 'In $name einzahlen';
  }

  @override
  String get depositAction => 'Einzahlen';

  @override
  String get goalAlreadyReached => 'Ziel ist bereits voll erreicht.';

  @override
  String depositedAmountMessage(Object amount) {
    return '$amount eingezahlt';
  }

  @override
  String get newSavingsGoalAction => 'Neues Sparziel';

  @override
  String get noSavingsGoalsHint =>
      'Noch keine Sparziele. Lege ein Ziel mit monatlichem Abzug an.';

  @override
  String monthlyDeductionValue(Object amount) {
    return 'Monatlicher Abzug: $amount';
  }

  @override
  String debitDayValue(int day) {
    return 'Abbuchung: $day. des Monats';
  }

  @override
  String get depositShortAction => 'Einzahlen';

  @override
  String get editShortAction => 'Bearbeiten';

  @override
  String get noTransactionsRecent => 'Keine Transaktionen';

  @override
  String get recentTransactionsTitle => 'Letzte Transaktionen';

  @override
  String get allAction => 'Alle';

  @override
  String get noExpensesLast30Days => 'Keine Ausgaben in den letzten 30 Tagen';

  @override
  String get noCategoriesLabel => 'Keine Kategorien';

  @override
  String get topCategoriesTitle => 'Top Kategorien';

  @override
  String get expensesLabel => 'Ausgaben';

  @override
  String get monthlyBudgetRemainingLabel => 'Monatsbudget Rest';

  @override
  String get expensesTrendTitle => 'Ausgaben Trend';

  @override
  String get todayLabel => 'Heute';

  @override
  String get weekLabel => 'Woche';

  @override
  String get monthLabel => 'Monat';

  @override
  String get savingsGoalsTitle => 'Sparziele';

  @override
  String get noActiveSavingsGoal => 'Noch kein Sparziel aktiv.';

  @override
  String get createSavingsGoalAction => 'Sparziel erstellen';

  @override
  String savingsGoalHeader(Object name) {
    return 'Sparziel: $name';
  }

  @override
  String get goalNameInputLabel => 'Zielname';

  @override
  String get targetAmountInputLabel => 'Zielbetrag';

  @override
  String currentOfTarget(Object current, Object target) {
    return '$current von $target';
  }

  @override
  String get availableBalance => 'Verfuegbarer Saldo';

  @override
  String get okAction => 'OK';

  @override
  String get savingsGoalEditTitle => 'Sparziel bearbeiten';

  @override
  String get savingsGoalNameLabel => 'Zielname';

  @override
  String get savingsGoalTargetLabel => 'Zielbetrag';

  @override
  String goalDepositTransactionTitle(Object name) {
    return '$name Einzahlung';
  }

  @override
  String get darkMode => 'Darkmode';

  @override
  String get followsDeviceSetting => 'Folgt der Geraeteeinstellung';

  @override
  String get enabled => 'Aktiviert';

  @override
  String get disabled => 'Deaktiviert';

  @override
  String get csvExport => 'CSV Export';

  @override
  String get csvImport => 'CSV Import';

  @override
  String get copyTransactionsAsCsv => 'Transaktionen als CSV kopieren';

  @override
  String get importTransactionsFromCsv => 'Transaktionen aus CSV importieren';

  @override
  String get resetAppData => 'App-Daten zuruecksetzen';

  @override
  String get resetBudgetsGoalsTransactions =>
      'Setzt Budgets, Ziele und Transaktionen auf 0';

  @override
  String get budgetAndGoals => 'Budget & Sparziele';

  @override
  String get budgetsTab => 'Budgets';

  @override
  String get savingsGoalsTab => 'Sparziele';

  @override
  String get statsTitle => 'Statistik';

  @override
  String statsBookingsInRange(int count) {
    return '$count Buchungen im Zeitraum';
  }

  @override
  String get coreMetrics => 'Kernmetriken';

  @override
  String get weeklyTrend => 'Wochenverlauf';

  @override
  String get categoryBreakdown => 'Kategorie-Anteile';

  @override
  String get weekdayPattern => 'Wochentags-Muster';

  @override
  String get statsEmptyTitle => 'Noch keine Daten fuer Statistik';

  @override
  String get statsEmptySubtitle =>
      'Sobald du Transaktionen hinzufuegst, siehst du hier Trends, Kategorien und Sparquote.';

  @override
  String get statsPositiveTrend => 'Du sparst im Trend';

  @override
  String get statsNegativeTrend => 'Ausgaben aktuell zu hoch';

  @override
  String netInRangeLabel(Object range) {
    return 'Netto in $range (Einnahmen - Ausgaben)';
  }

  @override
  String get incomeLabel => 'Einnahmen';

  @override
  String get expensesPerDayLabel => 'Ausgaben / Tag';

  @override
  String get largestExpenseLabel => 'Groesste Ausgabe';

  @override
  String get activeDaysLabel => 'Aktive Tage';

  @override
  String get savingsRateLabel => 'Sparquote';

  @override
  String noExpenseStreakLabel(int days) {
    return 'ausgabefrei: $days Tage';
  }

  @override
  String get noExpensesInRange => 'Noch keine Ausgaben im Zeitraum.';

  @override
  String get weeklyAverageLabel => 'Ø Woche';

  @override
  String get trendLabel => 'Trend';

  @override
  String get weeklyBarsHint =>
      'Je Balken = eine Woche. So siehst du Ausreisser und Trendwechsel sofort.';

  @override
  String get noCategoryExpenses => 'Noch keine Kategorien mit Ausgaben.';

  @override
  String get noWeekdayExpenses => 'Noch keine Ausgaben nach Wochentagen.';

  @override
  String get highestExpenseDayHint =>
      'Rang 1 = hoechster Ausgabentag. Die Farbstaerke zeigt dir den Unterschied auf einen Blick.';

  @override
  String weekLabelPrefix(Object week) {
    return 'Woche $week';
  }

  @override
  String get categoryGeneral => 'Allgemein';

  @override
  String get categoryEntertainment => 'Unterhaltung';

  @override
  String get categoryCafe => 'Cafe';

  @override
  String get range7Days => '7 Tage';

  @override
  String get range30Days => '30 Tage';

  @override
  String get range90Days => '90 Tage';

  @override
  String get rangeAll => 'Gesamt';

  @override
  String get transactionsTitle => 'Transaktionen';

  @override
  String get tabAll => 'Alle';

  @override
  String get tabIncome => 'Einnahmen';

  @override
  String get tabExpenses => 'Ausgaben';

  @override
  String get noTransactions => 'Keine Transaktionen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Loeschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get addTransaction => 'Transaktion hinzufuegen';
}
