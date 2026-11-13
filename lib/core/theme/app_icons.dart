import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

abstract final class AppIcons {
  // Navigation
  static const dashboard = PhosphorIconsRegular.house;
  static const dashboardSelected = PhosphorIconsFill.house;

  static const wallets = PhosphorIconsRegular.wallet;
  static const walletsSelected = PhosphorIconsFill.wallet;

  static const settings = PhosphorIconsRegular.gearSix;
  static const settingsSelected = PhosphorIconsFill.gearSix;

  // Wallet types
  static const walletChecking = PhosphorIconsRegular.bank;
  static const walletSavings = PhosphorIconsRegular.piggyBank;
  static const walletCash = PhosphorIconsRegular.wallet;
  static const walletCredit = PhosphorIconsRegular.creditCard;
  static const walletInvestment = PhosphorIconsRegular.trendUp;

  // Category types
  static const categoryGroceries = PhosphorIconsRegular.shoppingCart;
  static const categoryTransportation = PhosphorIconsRegular.car;
  static const categorySubscriptions = PhosphorIconsRegular.repeat;
  static const categoryEducation = PhosphorIconsRegular.graduationCap;
  static const categoryInvestments = PhosphorIconsRegular.trendUp;
  static const categoryOthers = PhosphorIconsRegular.dotsThreeCircle;
  static const categoryGeneric = PhosphorIconsRegular.tag;
  static const categoryNone = PhosphorIconsRegular.prohibit;

  // Transactions
  static const income = PhosphorIconsRegular.arrowDown;
  static const expense = PhosphorIconsRegular.arrowUp;
  static const calendar = PhosphorIconsRegular.calendar;
  static const receipt = PhosphorIconsRegular.receipt;
  static const note = PhosphorIconsRegular.textAlignLeft;
  static const filter = PhosphorIconsRegular.funnelSimple;
  static const allTypes = PhosphorIconsRegular.squaresFour;

  static const radioUnselected = PhosphorIconsRegular.circle;

  // Actions
  static const add = PhosphorIconsRegular.plus;
  static const edit = PhosphorIconsRegular.pencilSimple;
  static const delete = PhosphorIconsRegular.trash;
  static const moreHorizontal = PhosphorIconsBold.dotsThree;
  static const close = PhosphorIconsRegular.x;
  static const back = PhosphorIconsRegular.caretLeft;
  static const search = PhosphorIconsRegular.magnifyingGlass;
  static const check = PhosphorIconsRegular.check;
  static const chevronRight = PhosphorIconsRegular.caretRight;
  static const info = PhosphorIconsRegular.info;

  // Settings
  static const currency = PhosphorIconsRegular.currencyDollar;
  static const theme = PhosphorIconsRegular.moon;
  static const themeSystem = PhosphorIconsRegular.circleHalf;
  static const themeLight = PhosphorIconsRegular.sun;
  static const themeDark = PhosphorIconsRegular.moon;
}
