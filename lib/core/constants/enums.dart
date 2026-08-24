enum WalletType { checking, savings, cash, credit, investment }

enum TransactionType { income, expense }

extension TransactionTypeBalance on TransactionType {
  int balanceDelta(int amount) {
    return this == TransactionType.income ? amount : -amount;
  }
}

enum CategoryType {
  groceries,
  transportation,
  subscriptions,
  education,
  investments,
}

enum SortOrder { asc, desc }
