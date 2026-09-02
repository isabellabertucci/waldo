# Design System Branch Review

Branch: `feat/design-system`
Commits reviewed: `ae54eb8` → `396e741` → `15a984b`

Findings are grouped by file. Line numbers refer to the current working tree.

---

## lib/features/wallets/wallets_x.dart

### 1. Architecture — hardcoded badge colors (not design tokens)
`WalletTypeStyle.style` returns literal `Color(0xFF...)` values for every wallet type (lines 27–47). The design-system branch introduced `AppColors` precisely so components consume tokens, and several of these exact colors already exist as tokens (`primaryStrong` = `0xFF177B3D`, `primary` = `0xFF63DC78`, etc.). Hardcoded colors bypass the light/dark theme and can't react to theming.

Violation: breaks "components only consume theme tokens — no hardcoded values." Matters because these colors won't adapt to dark mode and duplicate values that already live in `AppColors`.
Fix: derive each badge from `AppColors` tokens passed in (or add a token set for category/wallet-type accents) instead of raw `Color()`.

### 2. Architecture — icons use raw Material `Icons.*` instead of `AppIcons`
`WalletTypeIcon.icon` returns `Icons.account_balance_outlined`, `Icons.savings_outlined`, etc. (lines 51–61). `AppIcons` already defines wallet-type icons (`walletChecking`, `walletSavings`, `walletCash`, `walletCredit`, `walletInvestment`, lines 15–19) that are never used.

Violation: the design system centralizes icon constants, but this feature bypasses it, and it duplicates icons already defined in `AppIcons`. Two sources of truth for the same asset.
Fix: `WalletTypeIcon` should return from `AppIcons` (or be deleted in favor of the existing `AppIcons` members).

### 3. Placement — display-layer extensions in a feature-root file
`WalletTypeLabel` (l10n label) legitimately belongs with the model/enum. But `WalletTypeStyle` (colors) and `WalletTypeIcon` (icons) are pure presentation-layer helpers yet live in a feature-root `wallets_x.dart`, while the actual screens that use them (`views/wallets_screen.dart`) live under `views/`. Compare with how `category_form_sheet.dart` keeps its `TransactionTypeLabel` co-located.

Violation: file placement should reflect what the code does; these are view-layer helpers misplaced at the feature root.
Fix (chosen): keep the l10n `label` where it is; move `style`/`icon` into the `views/` layer (e.g. a `wallet_type_view.dart` under `views/`).

---

## lib/core/theme/theme_provider.dart

### 4. Architecture — state management inside the design-system folder
`ThemeModeNotifier` (a Riverpod `Notifier`) and the `themeModeProvider` live in `lib/core/theme/`, the same folder as pure presentation tokens (`app_colors.dart`, `spacing.dart`, `common.dart`).

Violation: the design system should be presentation-only; embedding app-feature state management (a provider + notifier) in it mixes concerns, and it's deliberately excluded from `app_design_system.dart` because it isn't presentation.
Fix (chosen): move `themeProvider`/`ThemeModeNotifier` to a state location, e.g. `lib/core/state/theme_mode.dart` or `lib/features/settings/`, keeping `lib/core/theme/` presentation-only.

---

## lib/core/theme/app_icons.dart

### 5. Placement — icons in the `theme/` folder
`app_icons.dart` holds icon *constants* but lives beside token/theme files. It is not exported by `app_design_system.dart` (a signal it doesn't belong in the theme surface).

Violation: file placement should match what the file does; icon constants aren't theme/design tokens.
Fix (chosen): move to a dedicated `lib/core/assets/app_icons.dart` (or `lib/core/ui/app_icons.dart`) and export from the design-system barrel it's meant to be part of.

---

## lib/features/wallets/views/wallets_screen.dart

### 6. Imports — inconsistent relative/absolute mixing
Lines 1–14 mix relative and absolute imports with no stable grouping:
```dart
import '../../../core/widgets/empty_state.dart';   // relative
import '../models/wallet.dart';                    // relative
import 'package:waldo/l10n/app_localizations.dart'; // absolute
import 'package:waldo/core/router/app_router.dart'; // absolute
```
Most other files (e.g. `transaction_detail_screen.dart`) group all `package:` imports first, then relative ones. This file interleaves them.

Violation: inconsistency in the relative-vs-absolute convention within the same repo.
Fix (chosen): group all `package:waldo/...` imports at the top, then relative `./` imports below, matching `transaction_detail_screen.dart`.

### 7. Convention — hardcoded, unlocalized string
Line 222: `Text('Edit')` is a raw string. Compare the sibling menu item (lines 236–239) which correctly uses `l10n.delete`.

Violation: the codebase localizes all user-facing strings via `AppLocalizations`; this bypasses i18n.
Fix: `Text(l10n.editTransaction)` (or the existing `edit` key).

### 8. Convention — raw Material icons and `Colors.white` instead of design-system
- `Icon(Icons.add)` (line 41) — `AppIcons.add` exists.
- `Colors.white` (line 83) — hardcoded color; should be a token (e.g. `onError`/`onPrimary` from the scheme).
- `Icons.account_balance_wallet_outlined` (line 137), `Icons.more_vert` (line 196), `Icons.edit_outlined` (line 220), `Icons.delete_outline` (line 231) — all have `AppIcons` equivalents (`wallets`, `more`, `edit`, `delete`).

Violation: the design system is being adopted only partially; widgets still reach past `AppIcons`/tokens to raw Material APIs.
Fix (chosen): swap these to `AppIcons.*` and a token color.

---

## lib/features/transactions/views/transactions_screen.dart

### 9. Imports — inconsistent relative/absolute mixing
Lines 10–15 mix relative (`../../../core/widgets/empty_state.dart`, `../...`) and absolute (`package:waldo/...`) inline, same problem as `wallets_screen.dart`.

Violation: inconsistent import convention.
Fix: group `package:` imports first, then relative, as in `transaction_detail_screen.dart`.

### 10. Convention — hardcoded, unlocalized strings
- Line 97: `'Transactions in this wallet'`
- Line 193: `'Income'`
- Line 202: `'Expense'`

Violation: string literals displayed to users bypass `AppLocalizations`.
Fix: add l10n keys and use them.

### 11. Convention — hardcoded radius instead of token
Line 233: `BorderRadius.circular(16)` should use `Rounded.lg` (which resolves to `Spacing.lg` = 16), keeping radii consistent with `Rounded` elsewhere in the same file (`Rounded.md`, etc.).

Violation: hardcoded magic value where a design-system token exists.
Fix: `BorderRadius.circular(Rounded.lg)`.

### 12. Convention — raw Material icons
`Icon(Icons.add)` (line 52), `Icons.receipt_long_outlined` (line 70), `Icons.arrow_downward_rounded`/`arrow_upward_rounded` (lines 139–140) — `AppIcons.add`, `receipt`, `income`, `expense` already exist and are not used.

Violation: partial design-system adoption; duplicates `AppIcons`.
Fix: use `AppIcons.*`.

---

## lib/features/transactions/views/transaction_detail_screen.dart

### 13. Convention — `Colors.white` and raw Material icons
- `Colors.white` (line 60) hardcoded; should be a scheme token.
- `Icons.arrow_downward_rounded`/`arrow_upward_rounded` (lines 225–226), `Icons.calendar_today_outlined` (line 267), `Icons.account_balance_wallet_outlined` (line 275) — `AppIcons` has `income`/`expense`/`calendar`/`wallets` equivalents that aren't used.

Note: this file is otherwise the strongest example of token usage (uses `AppIcons.more/edit/delete` at lines 115/140/151 and `Rounded`/`Spacing` throughout) — the counterexample to cite for how the others should look.
Violation: partial adoption (mixed `AppIcons` and raw `Icons`/`Colors.white`).
Fix: swap remaining raw values to tokens/`AppIcons`.

---

## lib/features/categories/views/widgets/category_form_sheet.dart

### 14. Convention — hardcoded spacing instead of tokens
Lines 68–71 use literal `16` for padding, and lines 83/91 use `SizedBox(height: 16/24)`. The design-system `Spacing` scale exists (`md`=12, `lg`=16, `xl`=24) but this sheet (and the other two form sheets) is not converted.

Violation: hardcoded magic spacing numbers bypass the new token system.
Fix: `Spacing.md`/`Spacing.lg`/`Spacing.xl` and `Spacing.md` SizedBoxes, like `transaction_detail_screen.dart`.

---

## lib/features/wallets/views/widgets/wallet_form_sheet.dart

### 15. Convention — hardcoded spacing instead of tokens
Lines 102–105 (literal `16` padding), 117/124/138 (`SizedBox(height: 16)`), 152 (`SizedBox(height: 24)`) — same as `category_form_sheet.dart`.

Violation: magic spacing numbers where `Spacing` tokens exist.
Fix: use `Spacing.*` tokens.

---

## lib/features/transactions/views/widgets/transaction_form_sheet.dart

### 16. Convention — hardcoded spacing instead of tokens
Lines 119–122 (literal `16` padding), and `SizedBox(height: 16/8/24)` at lines 135/145/159/180/209/235/243. It imports `package:waldo/core/utils/utils.dart` for `parseToCents` but does not import `Spacing`.

Violation: same magic-spacing issue; this file was touched heavily this branch and left unconverted.
Fix: import `spacing.dart` and use `Spacing.*` tokens in the sheet layout (and standardize the sheet padding to `Rounded`/`Spacing`).

---

## lib/features/settings/ui/settings_screen.dart

### 17. Convention — hardcoded, unlocalized strings
Line 13 `'Settings'` and line 17 `'Dark mode'` are raw strings in a file changed on this branch. Every other screen uses `AppLocalizations` (`l10n.wallets`, `l10n.categories`, ...).

Violation: bypasses i18n; also `'Settings'` duplicates the `l10n.settings` string already used in `app_shell.dart`.
Fix: use `l10n.settings` and add a `darkMode` key.

---

## lib/core/theme/common.dart

### 18. Convention — leftover/dead comment
Line 97: `// era 12` is a leftover Portuguese scratch note ("it used to be 12") from editing the `ListTile` contentPadding.

Violation: leftover non-code comment tied to a single edit; no place in a design system.
Fix: remove the comment, or replace with an explanatory comment about the intent of the padding.

### 19. Convention — hardcoded padding values vs tokens
Lines 95–96 and 105 use literal `20/6` and `16/16` padding. These are theme-data (not per-screen) so are lower risk, but they could reference `Spacing` to keep a single source of padding.
Fix: optional; reference `Spacing.*` if full token adoption is desired.

---

## lib/core/theme/rounded.dart

### 20. Convention — `final` instead of `const`
Lines 6–9 declare `static final sm/md/lg/xl`, but they only reference `Spacing.sm/md/lg/xl` (static `const`), so they can be `static const`.
Violation: unnecessary runtime fields; inconsistent with the `const` style used by `Spacing` and elsewhere.
Fix: `static const sm = Spacing.sm;` etc.

Also note: aliasing the spacing scale to be "radii" (`Rounded.lg = Spacing.lg`) conflates two concerns and makes `pill = 9999.0` the only true radius; consider a dedicated radius scale if radii should differ from spacing.

---

## lib/core/theme/app_design_system.dart

### 21. Convention — unused/incomplete barrel (dead code)
`grep` for `app_design_system` finds zero usages anywhere in `lib/` or `test/`: the barrel is never imported, so it's dead code. It also only exports `app_colors`, `common`, `app_theme` — omitting `spacing`, `rounded`, and `app_icons`, so it can't serve as the single design-system surface even if used.

Violation: dead export that also provides an incomplete public surface (misleading).
Fix (chosen): either delete the barrel, or export the full token set (`spacing`, `rounded`, `app_icons`) and actually import it from the app so the design system has one entry point.

---

## lib/features/categories/repositories/category_repository.dart

### 22. Convention — duplicate `@override` annotation
Lines 71–72:
```dart
@override
@override
Future<void> update(Category category) async {
```
Violation: duplicate annotation introduced in this branch; dead/static-analysis noise.
Fix: remove one `@override`.

---

## lib/core/database/migrations/v00001_create_initial_schema.dart

### 23. Convention — raw strings for seeded category names
The migration seeds default category names as inline literals (lines ~36–40: `'Groceries'`, `'Transportation'`, ...). These become the source of truth for test-friendly ordering (see the `ZZZ Test Category` test workaround in `categories_screen_test.dart`). No bug, but the names are magic strings repeated in tests with no shared constant.
Fix (optional): hoist to a shared constant used by both migration and tests.

---

## Cross-cutting / checklist items

### 24. `gap` not used anywhere — inconsistent spacing primitive
`rg "gap:"` returns **zero** matches in `lib/`. The design-system branch added a `Spacing` scale yet screens still use a mixture of `SizedBox(height: ...)` inside `Column`/`Row` and `ListView.separated` `separatorBuilder`. There is no consistent primitive: `transaction_detail_screen.dart` uses explicit `SizedBox`, `transactions_screen.dart` and `wallets_screen.dart` use `ListView.separated` + `SizedBox`, and the form sheets use raw literal SizedBoxes.
Violation: the spacing system has no canonical idiom, so spacing is applied three different ways with the same semantic meaning.
Fix (chosen): standardize `Column`/`Row` spacing on the built-in `gap:` parameter (e.g. `gap: Spacing.md`) and keep `ListView.separated` for lists; remove stray literal `SizedBox` values in the form sheets. This is the cleanest of the three mid-change states.

### 25. Raw Material `Icons.*` adoption is inconsistent (repeat theme)
`AppIcons` was introduced, but `Icons.add`, `Icons.edit`, `Icons.delete`, `Icons.more_vert`, `Icons.arrow_*`, `Icons.calendar_*`, `Icons.receipt_*`, `Icons.account_balance_wallet_outlined` are still used directly across views. Only `app_shell.dart` and parts of `transaction_detail_screen.dart` adopt `AppIcons`.
Fix (chosen): sweep all views to `AppIcons.*` in the same pass as the token work, so there is one source of truth for icon assets.

---

## Summary

- **Architecture violations: 4** — `wallets_x.dart` raw badge colors (#1) and raw icons (#2); `theme_provider.dart` state in design system (#4); `app_icons.dart` misplaced in theme folder (#5).
- **Import violations: 3** — mixed relative/absolute grouping in `wallets_screen.dart` (#6), `transactions_screen.dart` (#9), `categories_screen.dart` (same pattern; grouped with #6/#9).
- **Placement issues: 4** — `app_icons.dart` (#5), `theme_provider.dart` (#4), `wallets_x.dart` display helpers (#3), plus incomplete `app_design_system.dart` barrel (#21).
- **Convention issues: 13** — duplicate `@override` (#22), hardcoded unlocalized strings (#7, #10, #17), hardcoded radii/spacing/colors/raw icons (#11, #12, #13, #14, #15, #16, #25), leftover comment (#18), `Rounded` constness (#20), dead barrel (#21), `gap`/spacing inconsistency (#24). Minor optional: seeded-name constants (#23).

Highest-impact fixes to do first: adopt tokens everywhere (kill hardcoded colors/spacing/radius/icons), localize the stray strings, remove the duplicate `@override` and leftover comment, and decide the fate of the `app_design_system.dart` barrel.
