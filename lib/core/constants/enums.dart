enum WalletType { checking, savings, cash, credit, investment }

/// A wallet's leather, picked when it's made (DESIGN.md "Wallets").
enum LeatherFinish { black, yellow, green, white }

enum TransactionType { income, expense }

enum CategoryType {
  groceries,
  transportation,
  subscriptions,
  education,
  investments,
  others,
}

enum SortOrder { asc, desc }

enum Currency {
  usd,
  eur,
  gbp;

  /// ISO 4217 code, e.g. `USD`.
  String get code => name.toUpperCase();
}
