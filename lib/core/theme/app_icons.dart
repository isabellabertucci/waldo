import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

abstract final class AppIcons {
  // Navigation
  static const dashboard = PhosphorIconsRegular.chartPie;
  static const dashboardSelected = PhosphorIconsFill.chartPie;

  static const wallets = PhosphorIconsRegular.wallet;
  static const walletsSelected = PhosphorIconsFill.wallet;

  static const settings = PhosphorIconsRegular.slidersHorizontal;
  static const settingsSelected = PhosphorIconsFill.slidersHorizontal;

  // Wallet types
  static const walletChecking = PhosphorIconsRegular.bank;
  static const walletSavings = PhosphorIconsRegular.piggyBank;
  static const walletCash = PhosphorIconsRegular.wallet;
  static const walletCredit = PhosphorIconsRegular.creditCard;
  static const walletInvestment = PhosphorIconsRegular.trendUp;

  // Transactions
  static const income = PhosphorIconsRegular.arrowDown;
  static const expense = PhosphorIconsRegular.arrowUp;
  static const calendar = PhosphorIconsRegular.calendar;
  static const receipt = PhosphorIconsRegular.receipt;

  // Actions
  static const add = PhosphorIconsRegular.plus;
  static const edit = PhosphorIconsRegular.pencilSimple;
  static const delete = PhosphorIconsRegular.trash;
  static const more = PhosphorIconsBold.dotsThreeVertical;
  static const close = PhosphorIconsRegular.x;
  static const back = PhosphorIconsRegular.caretLeft;
  static const search = PhosphorIconsRegular.magnifyingGlass;
}
