enum WalletType { checking, savings, cash, credit, investment }

enum TransactionType { income, expense }

enum CategoryType {
  groceries,
  transportation,
  subscriptions,
  education,
  investments,
}

enum SortOrder { asc, desc }

enum Currency {
  usd,
  eur,
  gbp;

  /// ISO 4217 code, e.g. `USD`.
  String get code => name.toUpperCase();
}
