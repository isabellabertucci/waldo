const String appName = 'Waldo';

const int maxBalanceCents = 99999999999;

// Input limits: fields stop accepting text here instead of failing on save.
const int maxWalletNameLength = 50;
const int maxCategoryNameLength = 30;
const int maxTransactionDescriptionLength = 100;
const int maxTransactionNoteLength = 500;

/// Whole-number digits an amount field accepts: up to 999 999 999.99,
/// which matches [maxBalanceCents].
const int maxAmountWholeDigits = 9;
