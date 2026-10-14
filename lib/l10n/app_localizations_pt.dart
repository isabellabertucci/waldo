// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Waldo';

  @override
  String get dashboard => 'Painel';

  @override
  String get transactions => 'Transações';

  @override
  String get settings => 'Definições';

  @override
  String get wallets => 'Carteiras';

  @override
  String get noWalletsYet => 'Ainda não há carteiras';

  @override
  String get addFirstWallet =>
      'Toca em + para adicionares a tua primeira carteira';

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
  String get startingBalanceHint => 'Podes alterar isto depois';

  @override
  String get balanceLocked => 'Não pode ser alterado após a criação';

  @override
  String get walletNameHint => 'ex: Casa, Viagem';

  @override
  String get createWallet => 'Criar carteira';

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
      'Ocorreu um problema ao carregar as tuas carteiras. Tenta novamente.';

  @override
  String get saveError =>
      'Ocorreu um problema ao guardar a carteira. Tenta novamente.';

  @override
  String get deleteError =>
      'Ocorreu um problema ao apagar a carteira. Tenta novamente.';

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
  String get deleteDigit => 'Apagar dígito';

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
  String get walletTypeCredit => 'Cartão de Crédito';

  @override
  String get walletTypeInvestment => 'Investimento';

  @override
  String get noTransactionsYet => 'Ainda não há transações';

  @override
  String get addFirstTransaction =>
      'Toca em + para adicionares a tua primeira transação';

  @override
  String get newTransaction => 'Nova transação';

  @override
  String get transactionDefaultDescription => 'Transação';

  @override
  String get amount => 'Valor';

  @override
  String get date => 'Data';

  @override
  String get wallet => 'Carteira';

  @override
  String get category => 'Categoria';

  @override
  String get transactionDescription => 'Descrição';

  @override
  String get descriptionHint => 'Para que foi?';

  @override
  String get addExpense => 'Adicionar despesa';

  @override
  String get addIncome => 'Adicionar receita';

  @override
  String get addNewCategory => 'Nova';

  @override
  String get transactionNote => 'Nota';

  @override
  String editingAmountLabel(String type) {
    return '$type · a editar valor';
  }

  @override
  String get discardChangesTitle => 'Descartar alterações?';

  @override
  String get discardChangesMessage =>
      'Tens alterações por guardar neste campo.';

  @override
  String get discard => 'Descartar';

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
  String get transactionsError =>
      'Ocorreu um problema ao carregar as tuas transações. Tenta novamente.';

  @override
  String get transactionSaveError =>
      'Ocorreu um problema ao guardar a transação. Tenta novamente.';

  @override
  String get transactionDeleteError =>
      'Ocorreu um problema ao apagar a transação. Tenta novamente.';

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
  String get noCategoriesYet => 'Ainda não há categorias';

  @override
  String get addFirstCategory =>
      'Toca em + para adicionares a tua primeira categoria';

  @override
  String get newCategory => 'Nova categoria';

  @override
  String get editCategory => 'Editar categoria';

  @override
  String get manageCategories => 'Gerir categorias';

  @override
  String get deleteCategory => 'Apagar categoria?';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Isto vai apagar permanentemente \"$name\". As transações que a usam mantêm os seus dados, mas perdem a categoria.';
  }

  @override
  String get categoryDeleted => 'Categoria apagada';

  @override
  String get categoriesError =>
      'Ocorreu um problema ao carregar as tuas categorias. Tenta novamente.';

  @override
  String get categorySaveError =>
      'Ocorreu um problema ao guardar a categoria. Tenta novamente.';

  @override
  String get categoryDeleteError =>
      'Ocorreu um problema ao apagar a categoria. Tenta novamente.';

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
  String get moneySection => 'Dinheiro';

  @override
  String get appearanceSection => 'Aparência';

  @override
  String get currencyRowSubtitle => 'Como os valores são apresentados';

  @override
  String get dateFormatRowSubtitle => 'Usado em listas e detalhes';

  @override
  String get currencyChangeNotice =>
      'Isto altera apenas o símbolo. Os teus valores mantêm-se e não são convertidos.';

  @override
  String get preferencesError =>
      'Ocorreu um problema ao carregar as tuas preferências. Tenta novamente.';

  @override
  String get preferencesSaveError =>
      'Ocorreu um problema ao guardar a tua preferência. Tenta novamente.';

  @override
  String get currencyNameUsd => 'Dólar americano';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'Libra esterlina';

  @override
  String get totalBalance => 'Saldo Total';

  @override
  String get add => 'Adicionar';

  @override
  String get dashboardError =>
      'Ocorreu um problema ao carregar o teu painel. Tenta novamente.';

  @override
  String dashboardReceiptHeader(String month, String year) {
    return 'WALDO · $month $year';
  }

  @override
  String get uncategorized => 'Sem categoria';

  @override
  String get savedLabel => 'Poupado';

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
  String get addFirstTransactionButton => 'Adicionar primeira transação';

  @override
  String get cashFlow => 'Fluxo de Caixa';

  @override
  String get recentTransactions => 'Transações Recentes';

  @override
  String get noRecentTransactions => 'Ainda não há transações';

  @override
  String get firstRunPeekCta => 'Desliza a tua primeira carteira';

  @override
  String get dashboardReceiptNoWallet =>
      'O recibo do mês aparece aqui depois da primeira transação.';

  @override
  String get zeroWalletsLabel => '0 carteiras';

  @override
  String get filterTitle => 'Filtro';

  @override
  String get filterReset => 'Repor';

  @override
  String get filterSectionMonth => 'Mês';

  @override
  String get filterSectionType => 'Tipo';

  @override
  String get filterTypeAll => 'Todas';

  @override
  String filterShowTransactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count transações',
      one: 'Ver 1 transação',
    );
    return '$_temp0';
  }

  @override
  String filterChipLabel(String type) {
    return 'Tipo: $type';
  }

  @override
  String get noTransactionsForFilter =>
      'Nenhuma transação corresponde a este filtro.';

  @override
  String get transactionsGroupToday => 'Hoje';

  @override
  String get transactionsGroupYesterday => 'Ontem';

  @override
  String savedPercentThisMonth(String percent) {
    return 'Poupaste $percent este mês';
  }

  @override
  String overspentPercentThisMonth(String percent) {
    return 'Gastaste mais $percent do que recebeste';
  }

  @override
  String walletsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carteiras',
      one: '1 carteira',
    );
    return '$_temp0';
  }

  @override
  String get currencyOptionEur => 'EUR (€)';

  @override
  String get currencyOptionGbp => 'GBP (£)';

  @override
  String get currencyOptionUsd => 'USD (\$)';

  @override
  String get darkMode => 'Modo Escuro';
}
