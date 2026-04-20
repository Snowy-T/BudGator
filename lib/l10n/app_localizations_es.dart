// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'BudGator';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Idioma del sistema';

  @override
  String get languageGerman => 'Aleman';

  @override
  String get languageEnglish => 'Ingles';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageSpanish => 'Espanol';

  @override
  String get homeLabel => 'Inicio';

  @override
  String get googlePayEnableTitle => 'Activar deteccion de Google Pay';

  @override
  String get googlePayEnableBody =>
      'Para sugerir pagos automaticamente, Budgator necesita acceso a las notificaciones.';

  @override
  String get laterAction => 'Mas tarde';

  @override
  String get openSettingsAction => 'Abrir ajustes';

  @override
  String get closeAction => 'Cerrar';

  @override
  String get copyAction => 'Copiar';

  @override
  String get copiedCsvClipboard => 'CSV copiado al portapapeles.';

  @override
  String get csvImportHint =>
      'Pega aqui el CSV (incluyendo cabecera: id,title,amount,date,category,type)';

  @override
  String get importAction => 'Importar';

  @override
  String transactionsImportedCount(int count) {
    return '$count transacciones importadas.';
  }

  @override
  String get importFailedGeneric => 'Importacion fallida';

  @override
  String get resetAppDataConfirmBody =>
      'Todas las transacciones, presupuestos y objetivos de ahorro se restableceran a 0. El modo oscuro no cambia.';

  @override
  String get resetAction => 'Restablecer';

  @override
  String get appDataResetDone => 'Los datos de la app se restablecieron.';

  @override
  String get paymentSavedTransaction => 'Pago guardado como transaccion.';

  @override
  String get googlePayDetectedTitle => 'Pago de Google Pay detectado';

  @override
  String get paidAmountLabel => 'Importe pagado';

  @override
  String get paidAmountHint => 'p. ej. 7,50';

  @override
  String get titleLabel => 'Titulo';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get ignoreAction => 'Ignorar';

  @override
  String get invalidAmountMessage => 'Introduce un importe valido.';

  @override
  String get googlePayPaymentDefaultTitle => 'Pago de Google Pay';

  @override
  String get transactionDeleteTitle => 'Eliminar transaccion';

  @override
  String get transactionDeleteConfirm =>
      'Deseas eliminar realmente esta transaccion?';

  @override
  String get editTransactionTitle => 'Editar transaccion';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get chooseAction => 'Elegir';

  @override
  String get invalidValuesMessage => 'Introduce valores validos.';

  @override
  String get saveAnywayAction => 'Guardar de todos modos';

  @override
  String get overspendCategoryLimitTitle => 'Limite de categoria superado';

  @override
  String overspendNoSourceMessage(Object category, Object amount) {
    return '$category superada por $amount. Ninguna otra categoria tiene presupuesto restante para descontar. Guardar de todos modos?';
  }

  @override
  String categoryExceededByMessage(Object category, Object amount) {
    return '$category superada por $amount.';
  }

  @override
  String get deductionSaveFailed =>
      'No se pudo guardar el descuento de la categoria.';

  @override
  String get overspendTotalBudgetTitle => 'Presupuesto total superado';

  @override
  String overspendTotalBudgetMessage(Object amount) {
    return 'Este gasto supera el presupuesto mensual total por $amount. Guardar de todos modos?';
  }

  @override
  String get overspendTransferQuestion =>
      'Quieres descontar este importe de otra categoria?';

  @override
  String get deductValueFromLabel => 'Descontar valor de';

  @override
  String get deductionAmountLabel => 'Importe a descontar';

  @override
  String get continueWithoutDeduction => 'Continuar sin descuento';

  @override
  String get deductAmountAction => 'Descontar importe';

  @override
  String get newTransactionTitle => 'Nueva transaccion';

  @override
  String get captureIncomeExpenseSubtitle => 'Registra ingresos o gastos';

  @override
  String get enterTitleValidation => 'Introduce un titulo';

  @override
  String get enterAmountValidation => 'Introduce importe';

  @override
  String get incomeTypeLabel => 'Tipo de ingreso';

  @override
  String get salaryLabel => 'Salario';

  @override
  String get otherIncomeLabel => 'Otro ingreso';

  @override
  String get createCategoryAction => 'Agregar categoria';

  @override
  String get editTotalBudgetAction => 'Cambiar presupuesto total';

  @override
  String get categoriesTitle => 'Categorias';

  @override
  String activeCount(int count) {
    return '$count activas';
  }

  @override
  String get noBudgetCategories => 'No hay categorias con presupuesto';

  @override
  String get monthlyTotalBudgetChangeTitle =>
      'Cambiar presupuesto mensual total';

  @override
  String get totalBudgetLabel => 'Presupuesto total';

  @override
  String get warningTitle => 'Advertencia';

  @override
  String budgetTooLowWarningMessage(Object newBudget, Object allocated) {
    return 'El nuevo presupuesto ($newBudget) es menor que las categorias ya asignadas ($allocated). Ajusta las categorias.';
  }

  @override
  String get totalBudgetUpdated => 'Presupuesto total actualizado';

  @override
  String get newCategoryTitle => 'Nueva categoria';

  @override
  String get categoryNameLabel => 'Nombre de categoria';

  @override
  String get budgetAllocationLabel => 'Asignacion de presupuesto';

  @override
  String get colorLabel => 'Color';

  @override
  String get iconLabel => 'Icono';

  @override
  String get addAction => 'Agregar';

  @override
  String get categoryNameRequired => 'El nombre de categoria es obligatorio';

  @override
  String get budgetMustBePositive => 'El presupuesto debe ser > 0';

  @override
  String budgetWouldBeExceededAvailable(Object amount) {
    return 'El presupuesto se excederia. Disponible: $amount';
  }

  @override
  String get categoryAlreadyExists => 'La categoria ya existe';

  @override
  String get categoryAdded => 'Categoria agregada';

  @override
  String editCategoryTitle(Object name) {
    return 'Editar $name';
  }

  @override
  String get categoryDeleted => 'Categoria eliminada';

  @override
  String get invalidAmountGeneric => 'Importe invalido';

  @override
  String budgetWouldBeExceededMax(Object amount) {
    return 'El presupuesto se excederia. Max: $amount';
  }

  @override
  String get categoryUpdated => 'Categoria actualizada';

  @override
  String get setupBudgetTitle => 'Configurar presupuesto';

  @override
  String get setupBudgetDescription =>
      'Para gestionar gastos, primero configura un presupuesto mensual total. Luego puedes crear categorias y distribuir el importe.';

  @override
  String get createMonthlyBudgetAction => 'Crear presupuesto mensual';

  @override
  String get monthlyBudgetTitle => 'Presupuesto mensual';

  @override
  String get totalBudgetCurrentMonthLabel => 'Presupuesto total para este mes';

  @override
  String get createAction => 'Crear';

  @override
  String get invalidPositiveAmountMessage =>
      'Introduce un importe valido (> 0)';

  @override
  String get monthlyBudgetLabel => 'Presupuesto mensual';

  @override
  String get spentLabel => 'Gastado';

  @override
  String allocatedLabel(Object amount) {
    return 'Asignado: $amount';
  }

  @override
  String availableLabel(Object amount) {
    return 'Disponible: $amount';
  }

  @override
  String get noBudgetSet => 'Sin presupuesto establecido';

  @override
  String overrunByLabel(Object amount) {
    return 'Superado por $amount';
  }

  @override
  String get createSavingsGoalTitle => 'Crear objetivo de ahorro';

  @override
  String get editSavingsGoalTitle => 'Editar objetivo de ahorro';

  @override
  String get goalNameLabel => 'Nombre';

  @override
  String get goalAmountLabel => 'Importe objetivo';

  @override
  String get alreadySavedLabel => 'Ya ahorrado';

  @override
  String get monthlyDeductionFormLabel => 'Descuento mensual';

  @override
  String get debitDayLabel => 'Dia de cobro';

  @override
  String dayOfMonthLabel(int day) {
    return '$day. del mes';
  }

  @override
  String get automationActive => 'Automatizacion activa';

  @override
  String get automaticMonthlyDeductionSubtitle =>
      'Registrar automaticamente el descuento mensual';

  @override
  String get savingsGoalDeleted => 'Objetivo eliminado';

  @override
  String get enterValidValuesMessage => 'Introduce valores validos.';

  @override
  String get savedCannotExceedTarget =>
      'Lo ahorrado no puede superar el objetivo.';

  @override
  String get savingsGoalCreated => 'Objetivo creado';

  @override
  String get savingsGoalUpdated => 'Objetivo actualizado';

  @override
  String depositIntoGoalTitle(Object name) {
    return 'Depositar en $name';
  }

  @override
  String get depositAction => 'Depositar';

  @override
  String get goalAlreadyReached =>
      'El objetivo ya esta completamente alcanzado.';

  @override
  String depositedAmountMessage(Object amount) {
    return '$amount depositados';
  }

  @override
  String get newSavingsGoalAction => 'Nuevo objetivo de ahorro';

  @override
  String get noSavingsGoalsHint =>
      'Aun no hay objetivos. Crea uno con descuento mensual.';

  @override
  String monthlyDeductionValue(Object amount) {
    return 'Descuento mensual: $amount';
  }

  @override
  String debitDayValue(int day) {
    return 'Cobro: $day. del mes';
  }

  @override
  String get depositShortAction => 'Depositar';

  @override
  String get editShortAction => 'Editar';

  @override
  String get noTransactionsRecent => 'No hay transacciones';

  @override
  String get recentTransactionsTitle => 'Ultimas transacciones';

  @override
  String get allAction => 'Todas';

  @override
  String get noExpensesLast30Days => 'No hay gastos en los ultimos 30 dias';

  @override
  String get noCategoriesLabel => 'No hay categorias';

  @override
  String get topCategoriesTitle => 'Categorias principales';

  @override
  String get expensesLabel => 'Gastos';

  @override
  String get monthlyBudgetRemainingLabel => 'Presupuesto mensual restante';

  @override
  String get expensesTrendTitle => 'Tendencia de gastos';

  @override
  String get todayLabel => 'Hoy';

  @override
  String get weekLabel => 'Semana';

  @override
  String get monthLabel => 'Mes';

  @override
  String get savingsGoalsTitle => 'Objetivos de ahorro';

  @override
  String get noActiveSavingsGoal => 'Aun no hay objetivo activo.';

  @override
  String get createSavingsGoalAction => 'Crear objetivo de ahorro';

  @override
  String savingsGoalHeader(Object name) {
    return 'Objetivo: $name';
  }

  @override
  String get goalNameInputLabel => 'Nombre del objetivo';

  @override
  String get targetAmountInputLabel => 'Importe objetivo';

  @override
  String currentOfTarget(Object current, Object target) {
    return '$current de $target';
  }

  @override
  String get availableBalance => 'Saldo disponible';

  @override
  String get okAction => 'OK';

  @override
  String get savingsGoalEditTitle => 'Editar objetivo de ahorro';

  @override
  String get savingsGoalNameLabel => 'Nombre del objetivo';

  @override
  String get savingsGoalTargetLabel => 'Importe objetivo';

  @override
  String goalDepositTransactionTitle(Object name) {
    return 'Deposito $name';
  }

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get followsDeviceSetting => 'Sigue la configuracion del dispositivo';

  @override
  String get enabled => 'Activado';

  @override
  String get disabled => 'Desactivado';

  @override
  String get csvExport => 'Exportar CSV';

  @override
  String get csvImport => 'Importar CSV';

  @override
  String get copyTransactionsAsCsv => 'Copiar transacciones como CSV';

  @override
  String get importTransactionsFromCsv => 'Importar transacciones desde CSV';

  @override
  String get resetAppData => 'Restablecer datos de la app';

  @override
  String get resetBudgetsGoalsTransactions =>
      'Restablece presupuestos, objetivos y transacciones a 0';

  @override
  String get budgetAndGoals => 'Presupuesto y objetivos de ahorro';

  @override
  String get budgetsTab => 'Presupuestos';

  @override
  String get savingsGoalsTab => 'Objetivos';

  @override
  String get statsTitle => 'Estadisticas';

  @override
  String statsBookingsInRange(int count) {
    return '$count movimientos en el periodo';
  }

  @override
  String get coreMetrics => 'Metricas clave';

  @override
  String get weeklyTrend => 'Tendencia semanal';

  @override
  String get categoryBreakdown => 'Distribucion por categoria';

  @override
  String get weekdayPattern => 'Patron por dia de la semana';

  @override
  String get statsEmptyTitle => 'Aun no hay datos para estadisticas';

  @override
  String get statsEmptySubtitle =>
      'Cuando agregues transacciones, aqui veras tendencias, categorias y tasa de ahorro.';

  @override
  String get statsPositiveTrend => 'Estas ahorrando en la tendencia';

  @override
  String get statsNegativeTrend => 'Los gastos estan demasiado altos ahora';

  @override
  String netInRangeLabel(Object range) {
    return 'Neto en $range (ingresos - gastos)';
  }

  @override
  String get incomeLabel => 'Ingresos';

  @override
  String get expensesPerDayLabel => 'Gastos / dia';

  @override
  String get largestExpenseLabel => 'Gasto mas grande';

  @override
  String get activeDaysLabel => 'Dias activos';

  @override
  String get savingsRateLabel => 'Tasa de ahorro';

  @override
  String noExpenseStreakLabel(int days) {
    return 'sin gastos: $days dias';
  }

  @override
  String get noExpensesInRange =>
      'Aun no hay gastos en el periodo seleccionado.';

  @override
  String get weeklyAverageLabel => 'Media semana';

  @override
  String get trendLabel => 'Tendencia';

  @override
  String get weeklyBarsHint =>
      'Cada barra = una semana. Asi ves valores atipicos y cambios de tendencia al instante.';

  @override
  String get noCategoryExpenses => 'Aun no hay categorias con gastos.';

  @override
  String get noWeekdayExpenses => 'Aun no hay gastos por dia de la semana.';

  @override
  String get highestExpenseDayHint =>
      'Rango 1 = dia con mayor gasto. La intensidad del color muestra la diferencia de un vistazo.';

  @override
  String weekLabelPrefix(Object week) {
    return 'Semana $week';
  }

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryEntertainment => 'Entretenimiento';

  @override
  String get categoryCafe => 'Cafe';

  @override
  String get range7Days => '7 dias';

  @override
  String get range30Days => '30 dias';

  @override
  String get range90Days => '90 dias';

  @override
  String get rangeAll => 'Total';

  @override
  String get transactionsTitle => 'Transacciones';

  @override
  String get tabAll => 'Todas';

  @override
  String get tabIncome => 'Ingresos';

  @override
  String get tabExpenses => 'Gastos';

  @override
  String get noTransactions => 'No hay transacciones';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get addTransaction => 'Agregar transaccion';
}
