const dbName = 'waldo.db';

class WalletsTable {
  static const table = 'wallets';

  static const id = 'id';
  static const name = 'name';

  /// [nameKey] of the name; unique, so no two wallets share a name.
  static const nameKey = 'name_key';
  static const type = 'type';
  static const startingBalance = 'starting_balance';
  static const currentBalance = 'current_balance';
  static const createdAt = 'created_at';
}

class CategoriesTable {
  static const table = 'categories';

  static const id = 'id';
  static const name = 'name';

  /// [nameKey] of the name; unique among user-created categories.
  static const nameKey = 'name_key';
  static const isDefault = 'is_default';
  static const type = 'type';
  static const createdAt = 'created_at';
}

class TransactionsTable {
  static const table = 'transactions';

  static const id = 'id';
  static const walletId = 'wallet_id';
  static const categoryId = 'category_id';
  static const amount = 'amount';
  static const type = 'type';
  static const date = 'date';
  static const description = 'description';
  static const note = 'note';
  static const createdAt = 'created_at';
}

class PreferencesTable {
  static const table = 'preferences';

  static const id = 'id';
  static const preferredCurrency = 'preferred_currency';
  static const themeDark = 'theme_dark';
  static const dateFormat = 'date_format';
  static const updatedAt = 'updated_at';
}
