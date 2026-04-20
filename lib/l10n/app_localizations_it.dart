// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'BudGator';

  @override
  String get settings => 'Impostazioni';

  @override
  String get language => 'Lingua';

  @override
  String get languageSystem => 'Lingua di sistema';

  @override
  String get languageGerman => 'Tedesco';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageSpanish => 'Spagnolo';

  @override
  String get homeLabel => 'Home';

  @override
  String get googlePayEnableTitle => 'Attiva rilevamento Google Pay';

  @override
  String get googlePayEnableBody =>
      'Per suggerire pagamenti automaticamente, Budgator ha bisogno dell\'accesso alle notifiche.';

  @override
  String get laterAction => 'Dopo';

  @override
  String get openSettingsAction => 'Apri impostazioni';

  @override
  String get closeAction => 'Chiudi';

  @override
  String get copyAction => 'Copia';

  @override
  String get copiedCsvClipboard => 'CSV copiato negli appunti.';

  @override
  String get csvImportHint =>
      'Incolla qui il CSV (inclusa intestazione: id,title,amount,date,category,type)';

  @override
  String get importAction => 'Importa';

  @override
  String transactionsImportedCount(int count) {
    return '$count transazioni importate.';
  }

  @override
  String get importFailedGeneric => 'Importazione non riuscita';

  @override
  String get resetAppDataConfirmBody =>
      'Tutte le transazioni, i budget e gli obiettivi di risparmio saranno reimpostati a 0. La modalita scura resta invariata.';

  @override
  String get resetAction => 'Reimposta';

  @override
  String get appDataResetDone => 'Dati app reimpostati.';

  @override
  String get paymentSavedTransaction => 'Pagamento salvato come transazione.';

  @override
  String get googlePayDetectedTitle => 'Pagamento Google Pay rilevato';

  @override
  String get paidAmountLabel => 'Importo pagato';

  @override
  String get paidAmountHint => 'es. 7,50';

  @override
  String get titleLabel => 'Titolo';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get ignoreAction => 'Ignora';

  @override
  String get invalidAmountMessage => 'Inserisci un importo valido.';

  @override
  String get googlePayPaymentDefaultTitle => 'Pagamento Google Pay';

  @override
  String get transactionDeleteTitle => 'Elimina transazione';

  @override
  String get transactionDeleteConfirm =>
      'Vuoi davvero eliminare questa transazione?';

  @override
  String get editTransactionTitle => 'Modifica transazione';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get dateLabel => 'Data';

  @override
  String get chooseAction => 'Scegli';

  @override
  String get invalidValuesMessage => 'Inserisci valori validi.';

  @override
  String get saveAnywayAction => 'Salva comunque';

  @override
  String get overspendCategoryLimitTitle => 'Limite categoria superato';

  @override
  String overspendNoSourceMessage(Object category, Object amount) {
    return '$category superata di $amount. Nessun\'altra categoria ha budget residuo da sottrarre. Salvare comunque?';
  }

  @override
  String categoryExceededByMessage(Object category, Object amount) {
    return '$category superata di $amount.';
  }

  @override
  String get deductionSaveFailed =>
      'Il prelievo dalla categoria non e stato salvato.';

  @override
  String get overspendTotalBudgetTitle => 'Budget totale superato';

  @override
  String overspendTotalBudgetMessage(Object amount) {
    return 'Questa spesa supera il budget totale mensile di $amount. Salvare comunque?';
  }

  @override
  String get overspendTransferQuestion =>
      'Vuoi sottrarre questo importo da un\'altra categoria?';

  @override
  String get deductValueFromLabel => 'Sottrai valore da';

  @override
  String get deductionAmountLabel => 'Importo da sottrarre';

  @override
  String get continueWithoutDeduction => 'Continua senza sottrazione';

  @override
  String get deductAmountAction => 'Sottrai importo';

  @override
  String get newTransactionTitle => 'Nuova transazione';

  @override
  String get captureIncomeExpenseSubtitle => 'Registra entrate o uscite';

  @override
  String get enterTitleValidation => 'Inserisci un titolo';

  @override
  String get enterAmountValidation => 'Inserisci importo';

  @override
  String get incomeTypeLabel => 'Tipo entrata';

  @override
  String get salaryLabel => 'Stipendio';

  @override
  String get otherIncomeLabel => 'Altra entrata';

  @override
  String get createCategoryAction => 'Aggiungi categoria';

  @override
  String get editTotalBudgetAction => 'Modifica budget totale';

  @override
  String get categoriesTitle => 'Categorie';

  @override
  String activeCount(int count) {
    return '$count attive';
  }

  @override
  String get noBudgetCategories => 'Nessuna categoria con budget';

  @override
  String get monthlyTotalBudgetChangeTitle => 'Modifica budget totale mensile';

  @override
  String get totalBudgetLabel => 'Budget totale';

  @override
  String get warningTitle => 'Avviso';

  @override
  String budgetTooLowWarningMessage(Object newBudget, Object allocated) {
    return 'Il nuovo budget ($newBudget) e inferiore alle categorie gia assegnate ($allocated). Regola le categorie.';
  }

  @override
  String get totalBudgetUpdated => 'Budget totale aggiornato';

  @override
  String get newCategoryTitle => 'Nuova categoria';

  @override
  String get categoryNameLabel => 'Nome categoria';

  @override
  String get budgetAllocationLabel => 'Assegnazione budget';

  @override
  String get colorLabel => 'Colore';

  @override
  String get iconLabel => 'Icona';

  @override
  String get addAction => 'Aggiungi';

  @override
  String get categoryNameRequired => 'Il nome categoria e obbligatorio';

  @override
  String get budgetMustBePositive => 'Il budget deve essere > 0';

  @override
  String budgetWouldBeExceededAvailable(Object amount) {
    return 'Il budget sarebbe superato. Disponibile: $amount';
  }

  @override
  String get categoryAlreadyExists => 'La categoria esiste gia';

  @override
  String get categoryAdded => 'Categoria aggiunta';

  @override
  String editCategoryTitle(Object name) {
    return 'Modifica $name';
  }

  @override
  String get categoryDeleted => 'Categoria eliminata';

  @override
  String get invalidAmountGeneric => 'Importo non valido';

  @override
  String budgetWouldBeExceededMax(Object amount) {
    return 'Il budget sarebbe superato. Max: $amount';
  }

  @override
  String get categoryUpdated => 'Categoria aggiornata';

  @override
  String get setupBudgetTitle => 'Configura budget';

  @override
  String get setupBudgetDescription =>
      'Per gestire le spese, crea prima un budget totale mensile. Poi puoi creare categorie e distribuire l\'importo.';

  @override
  String get createMonthlyBudgetAction => 'Crea budget mensile';

  @override
  String get monthlyBudgetTitle => 'Budget mensile';

  @override
  String get totalBudgetCurrentMonthLabel => 'Budget totale per questo mese';

  @override
  String get createAction => 'Crea';

  @override
  String get invalidPositiveAmountMessage =>
      'Inserisci un importo valido (> 0)';

  @override
  String get monthlyBudgetLabel => 'Budget mensile';

  @override
  String get spentLabel => 'Speso';

  @override
  String allocatedLabel(Object amount) {
    return 'Assegnato: $amount';
  }

  @override
  String availableLabel(Object amount) {
    return 'Disponibile: $amount';
  }

  @override
  String get noBudgetSet => 'Nessun budget impostato';

  @override
  String overrunByLabel(Object amount) {
    return 'Superato di $amount';
  }

  @override
  String get createSavingsGoalTitle => 'Crea obiettivo di risparmio';

  @override
  String get editSavingsGoalTitle => 'Modifica obiettivo di risparmio';

  @override
  String get goalNameLabel => 'Nome';

  @override
  String get goalAmountLabel => 'Importo obiettivo';

  @override
  String get alreadySavedLabel => 'Gia risparmiato';

  @override
  String get monthlyDeductionFormLabel => 'Prelievo mensile';

  @override
  String get debitDayLabel => 'Giorno addebito';

  @override
  String dayOfMonthLabel(int day) {
    return '$day. del mese';
  }

  @override
  String get automationActive => 'Automazione attiva';

  @override
  String get automaticMonthlyDeductionSubtitle =>
      'Registra automaticamente il prelievo mensile';

  @override
  String get savingsGoalDeleted => 'Obiettivo eliminato';

  @override
  String get enterValidValuesMessage => 'Inserisci valori validi.';

  @override
  String get savedCannotExceedTarget =>
      'Il risparmiato non puo superare l\'obiettivo.';

  @override
  String get savingsGoalCreated => 'Obiettivo creato';

  @override
  String get savingsGoalUpdated => 'Obiettivo aggiornato';

  @override
  String depositIntoGoalTitle(Object name) {
    return 'Versa in $name';
  }

  @override
  String get depositAction => 'Versa';

  @override
  String get goalAlreadyReached => 'Obiettivo gia completamente raggiunto.';

  @override
  String depositedAmountMessage(Object amount) {
    return '$amount versati';
  }

  @override
  String get newSavingsGoalAction => 'Nuovo obiettivo';

  @override
  String get noSavingsGoalsHint =>
      'Nessun obiettivo ancora. Crea un obiettivo con prelievo mensile.';

  @override
  String monthlyDeductionValue(Object amount) {
    return 'Prelievo mensile: $amount';
  }

  @override
  String debitDayValue(int day) {
    return 'Addebito: $day. del mese';
  }

  @override
  String get depositShortAction => 'Versa';

  @override
  String get editShortAction => 'Modifica';

  @override
  String get noTransactionsRecent => 'Nessuna transazione';

  @override
  String get recentTransactionsTitle => 'Ultime transazioni';

  @override
  String get allAction => 'Tutte';

  @override
  String get noExpensesLast30Days => 'Nessuna spesa negli ultimi 30 giorni';

  @override
  String get noCategoriesLabel => 'Nessuna categoria';

  @override
  String get topCategoriesTitle => 'Categorie principali';

  @override
  String get expensesLabel => 'Spese';

  @override
  String get monthlyBudgetRemainingLabel => 'Budget mensile restante';

  @override
  String get expensesTrendTitle => 'Andamento spese';

  @override
  String get todayLabel => 'Oggi';

  @override
  String get weekLabel => 'Settimana';

  @override
  String get monthLabel => 'Mese';

  @override
  String get savingsGoalsTitle => 'Obiettivi di risparmio';

  @override
  String get noActiveSavingsGoal => 'Nessun obiettivo attivo.';

  @override
  String get createSavingsGoalAction => 'Crea obiettivo';

  @override
  String savingsGoalHeader(Object name) {
    return 'Obiettivo: $name';
  }

  @override
  String get goalNameInputLabel => 'Nome obiettivo';

  @override
  String get targetAmountInputLabel => 'Importo obiettivo';

  @override
  String currentOfTarget(Object current, Object target) {
    return '$current di $target';
  }

  @override
  String get availableBalance => 'Saldo disponibile';

  @override
  String get okAction => 'OK';

  @override
  String get savingsGoalEditTitle => 'Modifica obiettivo di risparmio';

  @override
  String get savingsGoalNameLabel => 'Nome obiettivo';

  @override
  String get savingsGoalTargetLabel => 'Importo obiettivo';

  @override
  String goalDepositTransactionTitle(Object name) {
    return 'Versamento $name';
  }

  @override
  String get darkMode => 'Modalita scura';

  @override
  String get followsDeviceSetting => 'Segue l\'impostazione del dispositivo';

  @override
  String get enabled => 'Attivato';

  @override
  String get disabled => 'Disattivato';

  @override
  String get csvExport => 'Esporta CSV';

  @override
  String get csvImport => 'Importa CSV';

  @override
  String get copyTransactionsAsCsv => 'Copia le transazioni come CSV';

  @override
  String get importTransactionsFromCsv => 'Importa transazioni da CSV';

  @override
  String get resetAppData => 'Reimposta dati app';

  @override
  String get resetBudgetsGoalsTransactions =>
      'Reimposta budget, obiettivi e transazioni a 0';

  @override
  String get budgetAndGoals => 'Budget e obiettivi di risparmio';

  @override
  String get budgetsTab => 'Budget';

  @override
  String get savingsGoalsTab => 'Obiettivi';

  @override
  String get statsTitle => 'Statistiche';

  @override
  String statsBookingsInRange(int count) {
    return '$count movimenti nel periodo';
  }

  @override
  String get coreMetrics => 'Metriche principali';

  @override
  String get weeklyTrend => 'Andamento settimanale';

  @override
  String get categoryBreakdown => 'Ripartizione categorie';

  @override
  String get weekdayPattern => 'Schema giorni della settimana';

  @override
  String get statsEmptyTitle => 'Nessun dato per le statistiche';

  @override
  String get statsEmptySubtitle =>
      'Quando aggiungi transazioni, qui vedrai trend, categorie e tasso di risparmio.';

  @override
  String get statsPositiveTrend => 'Stai risparmiando nel trend';

  @override
  String get statsNegativeTrend => 'Le spese sono attualmente troppo alte';

  @override
  String netInRangeLabel(Object range) {
    return 'Netto in $range (entrate - uscite)';
  }

  @override
  String get incomeLabel => 'Entrate';

  @override
  String get expensesPerDayLabel => 'Spese / giorno';

  @override
  String get largestExpenseLabel => 'Spesa piu grande';

  @override
  String get activeDaysLabel => 'Giorni attivi';

  @override
  String get savingsRateLabel => 'Tasso di risparmio';

  @override
  String noExpenseStreakLabel(int days) {
    return 'senza spese: $days giorni';
  }

  @override
  String get noExpensesInRange => 'Nessuna spesa nel periodo selezionato.';

  @override
  String get weeklyAverageLabel => 'Media settimana';

  @override
  String get trendLabel => 'Trend';

  @override
  String get weeklyBarsHint =>
      'Ogni barra = una settimana. Cosi vedi subito valori anomali e cambi di trend.';

  @override
  String get noCategoryExpenses => 'Nessuna categoria con spese ancora.';

  @override
  String get noWeekdayExpenses =>
      'Nessuna spesa per giorno della settimana ancora.';

  @override
  String get highestExpenseDayHint =>
      'Rango 1 = giorno con spesa piu alta. L\'intensita del colore mostra subito la differenza.';

  @override
  String weekLabelPrefix(Object week) {
    return 'Settimana $week';
  }

  @override
  String get categoryGeneral => 'Generale';

  @override
  String get categoryEntertainment => 'Intrattenimento';

  @override
  String get categoryCafe => 'Cafe';

  @override
  String get range7Days => '7 giorni';

  @override
  String get range30Days => '30 giorni';

  @override
  String get range90Days => '90 giorni';

  @override
  String get rangeAll => 'Totale';

  @override
  String get transactionsTitle => 'Transazioni';

  @override
  String get tabAll => 'Tutte';

  @override
  String get tabIncome => 'Entrate';

  @override
  String get tabExpenses => 'Uscite';

  @override
  String get noTransactions => 'Nessuna transazione';

  @override
  String get edit => 'Modifica';

  @override
  String get delete => 'Elimina';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get addTransaction => 'Aggiungi transazione';
}
