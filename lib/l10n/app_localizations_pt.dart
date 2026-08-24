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
  String get settings => 'Configurações';

  @override
  String get wallets => 'Carteiras';

  @override
  String get noWalletsYet => 'Ainda não há carteiras';

  @override
  String get addFirstWallet =>
      'Toque em + para adicionar a sua primeira carteira';

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
  String get balanceLocked => 'Não pode ser alterado após a criação';

  @override
  String get save => 'Salvar';

  @override
  String get nameRequired => 'O nome é obrigatório';

  @override
  String get invalidNumber => 'Digite um número válido';

  @override
  String get walletsError =>
      'Houve um problema ao carregar suas carteiras. Tente novamente.';

  @override
  String get saveError =>
      'Houve um problema ao salvar a carteira. Tente novamente.';

  @override
  String get deleteError =>
      'Houve um problema ao apagar a carteira. Tente novamente.';

  @override
  String get deleteWallet => 'Apagar carteira?';

  @override
  String deleteWalletConfirm(String name) {
    return 'Isto vai apagar permanentemente \"$name\".';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Apagar';

  @override
  String get walletDeleted => 'Carteira apagada';

  @override
  String get undo => 'Desfazer';

  @override
  String get nameTooLong => 'O nome é muito longo';

  @override
  String get walletTypeChecking => 'Conta Corrente';

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
      'Toque em + para adicionar a sua primeira transação';

  @override
  String get newTransaction => 'Nova transação';

  @override
  String get editTransaction => 'Editar transação';

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
  String get deleteTransaction => 'Apagar transação?';

  @override
  String get deleteTransactionConfirm =>
      'Isto vai apagar permanentemente esta transação.';

  @override
  String get transactionDeleted => 'Transação apagada';

  @override
  String get transactionsError =>
      'Houve um problema ao carregar suas transações. Tente novamente.';

  @override
  String get transactionSaveError =>
      'Houve um problema ao salvar a transação. Tente novamente.';

  @override
  String get transactionDeleteError =>
      'Houve um problema ao apagar a transação. Tente novamente.';

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
      'Toque em + para adicionar a sua primeira categoria';

  @override
  String get newCategory => 'Nova categoria';

  @override
  String get editCategory => 'Editar categoria';

  @override
  String get manageCategories => 'Gerenciar categorias';

  @override
  String get deleteCategory => 'Apagar categoria?';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Isto vai apagar permanentemente \"$name\".';
  }

  @override
  String get categoryDeleted => 'Categoria apagada';

  @override
  String get categoriesError =>
      'Houve um problema ao carregar suas categorias. Tente novamente.';

  @override
  String get categorySaveError =>
      'Houve um problema ao salvar a categoria. Tente novamente.';

  @override
  String get categoryDeleteError =>
      'Houve um problema ao apagar a categoria. Tente novamente.';

  @override
  String get categoryTypeGroceries => 'Mercado';

  @override
  String get categoryTypeTransportation => 'Transporte';

  @override
  String get categoryTypeSubscriptions => 'Assinaturas';

  @override
  String get categoryTypeEducation => 'Educação';

  @override
  String get categoryTypeInvestments => 'Investimentos';

  @override
  String get none => 'Nenhuma';
}
