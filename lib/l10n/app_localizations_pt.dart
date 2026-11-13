// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get dashboard => 'Início';

  @override
  String get transactions => 'Transações';

  @override
  String get settings => 'Definições';

  @override
  String get wallets => 'Carteiras';

  @override
  String get noWalletsYet => 'Ainda não tens carteiras';

  @override
  String get addFirstWallet =>
      'Uma carteira é onde guardas o dinheiro: em mão, no banco ou numa poupança.';

  @override
  String get newWallet => 'Nova carteira';

  @override
  String get editWallet => 'Editar carteira';

  @override
  String get name => 'Nome';

  @override
  String get type => 'Tipo';

  @override
  String get startingBalance => 'Saldo inicial';

  @override
  String get requiredField => 'obrigatório';

  @override
  String get balanceLocked => 'Não pode ser alterado após a criação';

  @override
  String get walletNameHint => 'ex: Casa, Viagem';

  @override
  String get createWallet => 'Criar carteira';

  @override
  String get editCategory => 'Editar categoria';

  @override
  String get createCategory => 'Criar categoria';

  @override
  String get save => 'Guardar';

  @override
  String get done => 'Concluído';

  @override
  String get nameRequired => 'O nome é obrigatório';

  @override
  String get invalidNumber => 'Introduz um número válido';

  @override
  String get walletsError =>
      'Ocorreu um problema ao carregar as tuas carteiras.';

  @override
  String get saveError =>
      'Não foi possível guardar a carteira. Nada foi alterado.';

  @override
  String get deleteError =>
      'Não foi possível apagar a carteira. Nada foi alterado.';

  @override
  String get deleteWallet => 'Apagar carteira?';

  @override
  String deleteWalletConfirm(String name) {
    return 'Isto vai apagar permanentemente \"$name\".';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Fechar';

  @override
  String get back => 'Voltar';

  @override
  String get hideBalance => 'Esconder saldo';

  @override
  String get showBalance => 'Mostrar saldo';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Apagar';

  @override
  String get walletDeleted => 'Carteira apagada';

  @override
  String get walletRestored => 'Carteira reposta';

  @override
  String get undo => 'Desfazer';

  @override
  String get nameTooLong => 'O nome é demasiado longo';

  @override
  String get walletTypeChecking => 'Conta à ordem';

  @override
  String get walletTypeSavings => 'Poupança';

  @override
  String get walletTypeCash => 'Dinheiro';

  @override
  String get walletTypeCredit => 'Cartão de crédito';

  @override
  String get walletTypeInvestment => 'Investimento';

  @override
  String get noTransactionsYet => 'Ainda não há transações';

  @override
  String get addFirstTransaction =>
      'As transações que registares aparecem aqui.';

  @override
  String get newTransaction => 'Nova transação';

  @override
  String get transactionDefaultDescription => 'Transação';

  @override
  String optionsFor(String name) {
    return 'Opções de $name';
  }

  @override
  String get amount => 'Valor';

  @override
  String get date => 'Data';

  @override
  String get wallet => 'Carteira';

  @override
  String get category => 'Categoria';

  @override
  String get transactionTitle => 'Título';

  @override
  String get descriptionHint => 'Para que foi?';

  @override
  String get addExpense => 'Adicionar despesa';

  @override
  String get addIncome => 'Adicionar receita';

  @override
  String get transactionNote => 'Nota';

  @override
  String get noteHint => 'Algo a lembrar?';

  @override
  String get deleteTransaction => 'Apagar transação?';

  @override
  String get deleteTransactionConfirm =>
      'Isto vai apagar permanentemente esta transação.';

  @override
  String get editTransactionAction => 'Editar transação';

  @override
  String get saveChanges => 'Guardar alterações';

  @override
  String get transactionDeleted => 'Transação apagada';

  @override
  String get transactionRestored => 'Transação reposta';

  @override
  String get transactionsError =>
      'Ocorreu um problema ao carregar as tuas transações.';

  @override
  String get transactionSaveError =>
      'Não foi possível guardar a transação. Nada foi alterado.';

  @override
  String get saveErrorStorageFull =>
      'Não há espaço no telemóvel. Liberta algum espaço e tenta novamente.';

  @override
  String get saveErrorTemporary =>
      'Não foi possível guardar agora. Tenta novamente.';

  @override
  String get transactionDeleteError =>
      'Não foi possível apagar a transação. Nada foi alterado.';

  @override
  String get amountRequired => 'O valor é obrigatório';

  @override
  String get dateRequired => 'A data é obrigatória';

  @override
  String get walletRequired => 'A carteira é obrigatória';

  @override
  String get transactionTypeIncome => 'Receita';

  @override
  String get transactionTypeExpense => 'Despesa';

  @override
  String get categories => 'Categorias';

  @override
  String get newCategory => 'Nova categoria';

  @override
  String get categoryNameHint => 'ex: Café, Ginásio';

  @override
  String get deleteCategory => 'Apagar categoria?';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Isto vai apagar \"$name\".';
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
      other: '$count transações usam \"$name\"',
      one: '1 transação usa \"$name\"',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'passam',
      one: 'passa',
    );
    return '$_temp0. Se a apagares, $_temp1 para $others.';
  }

  @override
  String deleteCategoryNamed(String name) {
    return 'Apagar $name';
  }

  @override
  String get categoryDeleted => 'Categoria apagada';

  @override
  String get categoryRestored => 'Categoria reposta';

  @override
  String get categoriesError =>
      'Ocorreu um problema ao carregar as tuas categorias.';

  @override
  String get categorySaveError =>
      'Não foi possível guardar a categoria. Nada foi alterado.';

  @override
  String get categoryNameTaken => 'Já existe uma categoria com esse nome';

  @override
  String get walletNameTaken => 'Já existe uma carteira com esse nome';

  @override
  String get categoryDeleteError =>
      'Não foi possível apagar a categoria. Nada foi alterado.';

  @override
  String get categoryTypeGroceries => 'Supermercado';

  @override
  String get categoryTypeTransportation => 'Transporte';

  @override
  String get categoryTypeSubscriptions => 'Subscrições';

  @override
  String get categoryTypeEducation => 'Educação';

  @override
  String get categoryTypeInvestments => 'Investimentos';

  @override
  String get categoryTypeOthers => 'Outros';

  @override
  String get none => 'Nenhuma';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get currency => 'Moeda';

  @override
  String get dateFormat => 'Formato de data';

  @override
  String get currencyChangeNotice =>
      'Isto altera apenas o símbolo. Os teus valores mantêm-se e não são convertidos.';

  @override
  String get preferencesError =>
      'Ocorreu um problema ao carregar as tuas preferências.';

  @override
  String get preferencesSaveError =>
      'Não foi possível guardar a tua preferência. Nada foi alterado.';

  @override
  String get currencyNameUsd => 'Dólar americano';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'Libra esterlina';

  @override
  String get totalBalance => 'Saldo total';

  @override
  String get add => 'Adicionar';

  @override
  String get dashboardError => 'Ocorreu um problema ao carregar o teu painel.';

  @override
  String get uncategorized => 'Sem categoria';

  @override
  String dashboardReceiptOtherCategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Outras ($count)',
      one: 'Outra (1)',
    );
    return '$_temp0';
  }

  @override
  String get seeAll => 'Ver todas';

  @override
  String get categorySpendingEmptyHint =>
      'Adiciona a tua primeira transação para a veres dividida por categoria aqui.';

  @override
  String get cashFlow => 'Fluxo de caixa';

  @override
  String cashFlowChartExpense(String from, String to) {
    return 'Despesas por mês, de $from a $to';
  }

  @override
  String cashFlowChartIncome(String from, String to) {
    return 'Receitas por mês, de $from a $to';
  }

  @override
  String get amountsHidden => 'Valores escondidos';

  @override
  String get recentTransactions => 'Transações recentes';

  @override
  String get previousMonth => 'Mês anterior';

  @override
  String get nextMonth => 'Mês seguinte';

  @override
  String get filterTypeAll => 'Todas';

  @override
  String transactionsInMonth(String month) {
    return 'Transações de $month';
  }

  @override
  String get noTransactionsForFilter =>
      'Nenhuma transação corresponde a este filtro.';

  @override
  String get transactionsGroupToday => 'Hoje';

  @override
  String get transactionsGroupYesterday => 'Ontem';

  @override
  String walletsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carteiras',
      one: '1 carteira',
      zero: '0 carteiras',
    );
    return '$_temp0';
  }

  @override
  String get yourWallets => 'As tuas carteiras';

  @override
  String monthChangeThisMonth(String amount) {
    return '$amount este mês';
  }

  @override
  String monthChangeInMonth(String amount, String month) {
    return '$amount em $month';
  }

  @override
  String get actionHide => 'Ocultar';

  @override
  String get actionTransaction => 'Transação';

  @override
  String get categorySpending => 'Gastos por categoria';

  @override
  String get actionFilter => 'Filtrar';

  @override
  String get searchWallets => 'Procurar carteira';

  @override
  String walletsShownOf(int shown, int total) {
    return '$shown de $total';
  }

  @override
  String walletsInPositive(String amount) {
    return 'Em positivo: $amount';
  }

  @override
  String walletsInNegative(String amount) {
    return 'Em negativo: $amount';
  }

  @override
  String get walletStatusNegative => 'Em negativo';

  @override
  String get walletStatusEmpty => 'Sem saldo';

  @override
  String walletStatusShare(String percent) {
    return '$percent do teu dinheiro';
  }

  @override
  String get noWalletsMatch => 'Nenhuma carteira encontrada';

  @override
  String get walletActionsHint => 'editar ou apagar';

  @override
  String get walletRowHint =>
      'Mantém premida uma carteira para a editar ou apagar';

  @override
  String walletShareOfPositive(String percent) {
    return '$percent do teu dinheiro';
  }

  @override
  String walletInRedBy(String amount) {
    return 'Em negativo · $amount';
  }

  @override
  String get walletAnalysis => 'Análise';

  @override
  String transactionsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transações',
      one: '1 transação',
      zero: '0 transações',
    );
    return '$_temp0';
  }

  @override
  String get leatherColour => 'Cor do couro';

  @override
  String get leatherBlack => 'Preto';

  @override
  String get leatherYellow => 'Amarelo';

  @override
  String get leatherGreen => 'Verde';

  @override
  String get leatherWhite => 'Branco';

  @override
  String get transactionActionsHint => 'editar ou apagar';

  @override
  String get transactionRowHint =>
      'Mantém premida uma transação para a editar ou apagar';

  @override
  String deleteWalletWithTransactions(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'as suas $count transações',
      one: 'a sua transação',
      zero: 'as suas transações',
    );
    return 'Isto vai apagar permanentemente \"$name\" e $_temp0.';
  }

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get walletBalanceLabel => 'Saldo';

  @override
  String get recentCategories => 'Recentes';

  @override
  String get newExpense => 'Nova despesa';

  @override
  String get newIncome => 'Nova receita';

  @override
  String get createFirstWallet => 'Criar a primeira carteira';

  @override
  String get noActivityYet => 'Ainda sem movimentos';

  @override
  String get monthSummary => 'Resumo do mês';

  @override
  String get monthSummaryLater => 'Aparece aqui depois da primeira transação.';

  @override
  String get recentTransactionsLater =>
      'Ainda não há transações. Cria uma carteira primeiro.';

  @override
  String get walletsNone => 'Nenhuma';

  @override
  String get settingsPreferences => 'Preferências';

  @override
  String get settingsOrganize => 'Organizar';

  @override
  String get categoriesBuiltIn => 'Incluídas';

  @override
  String get categoriesYours => 'As tuas';
}
