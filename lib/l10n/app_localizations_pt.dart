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
}
