# Code Review — `feat/homepage`

Scope: all 5 commits on `feat/homepage` since it diverged from `main` (merge-base `d61005a`), 44 files changed. Generated code (`*.freezed.dart`, `*.g.dart`, `app_localizations*.dart`) excluded from manual review — those are Freezed/Riverpod/Flutter-gen output, not hand-written.

`flutter analyze` was run against the branch: **no issues found** (no unused imports, no dead code the linter can detect).

---

## `lib/features/dashboard/viewmodels/dashboard_view_model.dart`

**Import violation — line 5**
```dart
import 'package:waldo/features/dashboard/models/dashboard_data.dart';
```
This file and `dashboard_data.dart` are both inside the `dashboard` feature, so per the repo's own convention (confirmed in `transaction_list_tile.dart`, `category_form_view_model.dart`, etc.) this should be a relative import. Package imports across features exist so a feature's public surface is explicit; using them for same-folder-tree files just adds noise and inconsistency.
**Fix:** `import '../models/dashboard_data.dart';`

---

## `lib/features/dashboard/ui/dashboard_screen.dart`

**Import violations — lines 6–11**
```dart
import 'package:waldo/features/dashboard/models/dashboard_data.dart';
import 'package:waldo/features/dashboard/ui/widgets/balance_overview_card.dart';
import 'package:waldo/features/dashboard/ui/widgets/cash_flow_card.dart';
import 'package:waldo/features/dashboard/ui/widgets/category_spending_list.dart';
import 'package:waldo/features/dashboard/ui/widgets/recent_transactions_list.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
```
All six are same-feature files imported with absolute paths. Same rule as above — cross-feature imports (line 12, `preferences/...`) are correctly absolute, but these should be relative.
**Fix:**
```dart
import 'models/dashboard_data.dart';
import 'widgets/balance_overview_card.dart';
import 'widgets/cash_flow_card.dart';
import 'widgets/category_spending_list.dart';
import 'widgets/recent_transactions_list.dart';
import '../viewmodels/dashboard_view_model.dart';
```

---

## `lib/features/dashboard/ui/widgets/category_spending_list.dart`

**Import violation — line 10**
```dart
import 'package:waldo/features/dashboard/models/dashboard_data.dart';
```
Same-feature file. **Fix:** `import '../../models/dashboard_data.dart';`

**Convention nit — line 114**
```dart
width: MediaQuery.of(context).size.width / 1.5,
```
Magic number `1.5` with no explanation in the file itself (the "~1.5 cards visible" intent lives only in the epic spec, not in the code). A future reader can't tell if `1.5` is arbitrary or load-bearing.
**Fix — chosen:** extract to a named constant, e.g. `const _cardWidthDivisor = 1.5;`, right above the class.

**Soft observation — lines 51, 126, 131**
`colors.primaryStrong` (the brand/income-green token) is reused for the "See all" link color and the category-icon circle tint, in a widget that only ever displays **expense** totals. This isn't a hard violation — `primaryStrong` already had a dual decorative/income purpose before this branch, and line 106 uses it correctly for "spending decreased" (green = good). But visually pairing a green icon tint with expense amounts can read as "this category is doing well" when it's just a neutral list item.
**Fix — chosen:** use a neutral/decorative token (e.g. `colors.onSurfaceVariant` or a dedicated `colors.accent`) for the icon tint and "See all" link, and reserve `primaryStrong` strictly for the income/positive-delta meaning it already has on line 106. If the design system doesn't have a neutral accent token yet, that's a one-line addition to `AppColors`, not a bigger change.

---

## `lib/features/dashboard/ui/widgets/cash_flow_card.dart`

**Import violation — line 9**
```dart
import 'package:waldo/features/dashboard/models/dashboard_data.dart';
```
Same-feature file. **Fix:** `import '../../models/dashboard_data.dart';`

**Translation/locale bug — lines 117–123**
```dart
String _compactCurrency(int cents, String currencyCode) {
  final formatter = NumberFormat.compactSimpleCurrency(
    locale: 'en_US',
    name: currencyCode,
  );
  return formatter.format(cents / 100);
}
```
This hardcodes `en_US` while the rest of the widget correctly derives locale from context (`Localizations.localeOf(context)`, line 27). A pt-BR user would see chart axis labels formatted in en-US number style (e.g. `1.2K` vs. pt's `1,2 mil`), inconsistent with every other number/date on the same screen.
**Fix — chosen:** pass the already-computed `locale` string into `_compactCurrency` (it's available in `build()` and already flows into `monthFormat`) instead of hardcoding `'en_US'`.

---

## `lib/features/categories/ui/widgets/category_form_sheet.dart`

**Import violations — lines 4–6**
```dart
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/viewmodels/category_form_view_model.dart';
```
All three are inside the `categories` feature (this file lives at `categories/ui/widgets/`). Should be relative.
**Fix:**
```dart
import '../../categories_x.dart';
import '../../models/category.dart';
import '../../viewmodels/category_form_view_model.dart';
```

---

## Extras (things not explicitly asked for in the checklist, but relevant)

**`gap` package is unused everywhere — not a regression, but not fixed either**
```
grep -rn "package:gap" lib/ test/   →  no matches
grep -rln "Gap("        lib/        →  no matches
```
`gap: ^3.0.1` is declared in `pubspec.yaml` but never imported anywhere in the codebase; every spacing gap uses `SizedBox` instead, including all the new dashboard widgets in this branch. This predates `feat/homepage` and wasn't introduced or worsened here, but since the branch adds several more `SizedBox`-based gaps, it's a good moment to resolve the inconsistency one way or the other.
**Fix — chosen:** remove `gap` from `pubspec.yaml`. `SizedBox` is the actual, universal convention in this codebase; keeping an unused dependency around just invites someone to use it inconsistently later. (Alternative: adopt `Gap()` repo-wide — more churn, no functional benefit, not recommended.)

**Translations — parity confirmed clean**
Checked `lib/l10n/app_en.arb` vs `lib/l10n/app_pt.arb` key sets programmatically after this branch's additions: 0 keys missing in either direction. All 13 new dashboard-related strings (`myFinances`, `overviewSubtitle`, `totalBalance`, `dashboardError`, `spendingsByCategory`, `seeAll`, `noSpendingThisMonth`, `percentFromLastMonth`, `cashFlow`, `overallRevenue`, `periodMonthly`, `recentTransactions`, `noRecentTransactions`) are present and translated in both files. No action needed. (The one real i18n issue found is the hardcoded `en_US` locale in `cash_flow_card.dart`, listed above.)

**Extension file placement — correct**
`lib/features/categories/categories_x.dart` sits at the feature root, matching the existing `lib/features/wallets/wallets_x.dart` convention exactly (not nested under `models/` or `utils/`). No action needed.

**`transaction_list_tile.dart` extraction — good example, not a finding**
The new `lib/features/transactions/ui/widgets/transaction_list_tile.dart` is a clean widget extraction from `transactions_screen.dart`: correct folder (`ui/widgets/`), correct relative import for its same-feature model (`import '../../models/transaction.dart';`), correct absolute imports for cross-folder deps (`core/theme`, `core/utils`, `l10n`). Calling this out because it's the pattern the import-violation fixes above should match.

**Migration edited in place (`v00001_create_initial_schema.dart`) rather than a new `v00002`**
Flagging only for completeness — this was an explicit, already-discussed decision (schema has no production data yet, so editing the initial migration in place was chosen over adding a new versioned migration). Not treated as a violation here.

---

## Summary

| Category | Count |
|---|---|
| Architecture violations (design-system purity, layering, feature leakage) | 0 |
| Import convention violations | 12 (across 6 files: `dashboard_view_model.dart` ×1, `dashboard_screen.dart` ×6, `category_spending_list.dart` ×1, `cash_flow_card.dart` ×1, `category_form_sheet.dart` ×3) |
| File placement issues | 0 |
| General convention issues (magic numbers, token reuse, locale bug, unused dependency) | 4 (`category_spending_list.dart` magic number, `category_spending_list.dart` color-token reuse, `cash_flow_card.dart` hardcoded locale, repo-wide unused `gap` dependency) |

No dead code, commented-out blocks, debug prints, or unused imports were found (`flutter analyze` clean). Translation parity is clean. No fixes have been applied — this file is findings only.
