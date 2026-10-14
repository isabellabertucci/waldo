---
version: alpha
name: Waldo
description: >
  Waldo is a personal finance app built on a warm, restrained monochrome
  palette - a cream canvas and ink-black ink, with no decorative color at
  all. The only hue in the system is a single burnt orange, reserved
  exclusively for errors and negative/expense amounts, so it reads as a true
  signal rather than decoration. Shapes lean soft and pill-like (stadium
  buttons, large-radius cards), type is Inter with tight negative tracking on
  display text, and the one piece of "material" flourish - a leather wallet
  card with a metallic finish - is deliberately fixed (dark ink + cream)
  across both themes, because a physical wallet doesn't change color when
  the room lights dim.
colors:
  primary: "{colors.primary-light}"
  transparent: "transparent"
  leather: "#141413"
  on-leather: "#F3F0EE"
  surface-light: "#FCFBFA"
  surface-dark: "#1F1D1B"
  on-surface-light: "#141413"
  on-surface-dark: "#F3F0EE"
  surface-container-light: "#F3F0EE"
  surface-container-dark: "#141413"
  on-surface-variant-light: "#696969"
  on-surface-variant-dark: "#A39E97"
  primary-light: "#141413"
  primary-dark: "#F3F0EE"
  primary-strong-light: "#000000"
  primary-strong-dark: "#FFFFFF"
  primary-container-light: "#F4F4F4"
  primary-container-dark: "#2A2724"
  on-primary-light: "#F3F0EE"
  on-primary-dark: "#141413"
  error-light: "#CF4500"
  error-dark: "#F37338"
  field-fill-light: "#F5F5F5"
  field-fill-dark: "#242422"
  field-border-light: "#EEEEEE"
  field-border-dark: "#353330"
typography:
  headline-display:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: 500
    lineHeight: 1.15
    letterSpacing: -0.64px
  headline-lg:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: 500
    lineHeight: 1.2
    letterSpacing: -0.44px
  headline-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: 500
    lineHeight: 1.2
    letterSpacing: -0.32px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: -0.08px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: -0.07px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: -0.06px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 500
    lineHeight: 1.1
    letterSpacing: -0.42px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: 500
    lineHeight: 1.1
    letterSpacing: -0.36px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: 500
    lineHeight: 1.1
    letterSpacing: -0.33px
  label-xs:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: 600
    lineHeight: 1.1
    letterSpacing: 0.4px
  body-md-strong:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 600
    lineHeight: 1.4
    letterSpacing: -0.07px
  body-md-bold:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 700
    lineHeight: 1.4
    letterSpacing: -0.07px
  body-sm-bold:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: 700
    lineHeight: 1.4
    letterSpacing: -0.06px
  label-lg-strong:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: -0.42px
  label-sm-bold:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: -0.33px
  headline-md-strong:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: -0.32px
  headline-lg-strong:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: -0.44px
  headline-sm-bold:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: -0.48px
  amount-display-bold:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: -0.56px
  headline-display-strong:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: 900
    lineHeight: 1.1
    letterSpacing: -0.56px
rounded:
  sm: 12px
  md: 20px
  lg: 28px
  pill: 9999px
spacing:
  xxs: 4px
  xs: 8px
  component: 12px
  sm: 16px
  md: 24px
  lg: 32px
  xl: 48px
  page-margin: 24px
components:
  button-primary-light:
    backgroundColor: "{colors.primary-light}"
    textColor: "{colors.on-primary-light}"
    typography: "{typography.label-lg-strong}"
    rounded: "{rounded.md}"
    padding: 16px
  button-primary-dark:
    backgroundColor: "{colors.primary-dark}"
    textColor: "{colors.on-primary-dark}"
    typography: "{typography.label-lg-strong}"
    rounded: "{rounded.md}"
    padding: 16px
  card-light:
    backgroundColor: "{colors.surface-light}"
    rounded: "{rounded.lg}"
  card-dark:
    backgroundColor: "{colors.surface-dark}"
    rounded: "{rounded.lg}"
  input-field-light:
    backgroundColor: "{colors.field-fill-light}"
    textColor: "{colors.on-surface-light}"
    typography: "{typography.body-md}"
    rounded: "{rounded.md}"
    padding: 16px
  input-field-dark:
    backgroundColor: "{colors.field-fill-dark}"
    textColor: "{colors.on-surface-dark}"
    typography: "{typography.body-md}"
    rounded: "{rounded.md}"
    padding: 16px
  input-field-border-light:
    backgroundColor: "{colors.field-border-light}"
    height: 1px
  input-field-border-dark:
    backgroundColor: "{colors.field-border-dark}"
    height: 1px
  wallet-card:
    backgroundColor: "{colors.leather}"
    textColor: "{colors.on-leather}"
    rounded: "{rounded.lg}"
  list-item-light:
    backgroundColor: "{colors.surface-light}"
    textColor: "{colors.on-surface-variant-light}"
    typography: "{typography.body-sm}"
    rounded: "{rounded.lg}"
  list-item-dark:
    backgroundColor: "{colors.surface-dark}"
    textColor: "{colors.on-surface-variant-dark}"
    typography: "{typography.body-sm}"
    rounded: "{rounded.lg}"
  amount-positive-light:
    textColor: "{colors.primary-strong-light}"
    typography: "{typography.label-lg-strong}"
  amount-positive-dark:
    textColor: "{colors.primary-strong-dark}"
    typography: "{typography.label-lg-strong}"
  amount-negative-light:
    textColor: "{colors.error-light}"
    typography: "{typography.label-lg-strong}"
  amount-negative-dark:
    textColor: "{colors.error-dark}"
    typography: "{typography.label-lg-strong}"
  app-bar:
    backgroundColor: "{colors.transparent}"
---

# Waldo Design System

## Overview

Waldo is a personal finance tracker: wallets, transactions, categories, a
dashboard. Its visual identity is deliberately quiet - a warm cream canvas
and near-black ink, almost no color, and generous pill-shaped rounding. The
app wants to feel calm and trustworthy rather than chart-y or alarmist, which
is why the single accent color (a burnt orange) is reserved strictly for
errors and negative amounts: when orange appears, it always means "pay
attention," never "this is a nice highlight."

The one departure from the flat ink/cream system is the wallet card: each
wallet renders on a photographic metal finish (platinum/gold/bronze) with a
true dark-metal gradient in dark mode, rather than the same light photo
dimmed down. This is treated as a physical material, not a themed surface -
its ink stays dark and its text stays cream in both themes, the way a real
leather wallet doesn't change color because the room got darker.

## Colors

- **Surface (`#FCFBFA` light / `#1F1D1B` dark):** The page canvas color -
  "Lifted Cream" in light mode, a warm near-black in dark mode. Cards,
  dialogs, sheets, and list items all sit on this.
- **On Surface (`#141413` light / `#F3F0EE` dark):** Primary text and icon
  color on top of `surface`.
- **Surface Container (`#F3F0EE` light / `#141413` dark):** One step away
  from `surface` - used as the `Scaffold` background behind cards, so cards
  visibly lift off the page.
- **On Surface Variant (`#696969` light / `#A39E97` dark):** Muted secondary
  text - dates, captions, placeholder-like labels, dividers at low alpha.
- **Primary (`#141413` light / `#F3F0EE` dark):** The CTA color - ink black
  in light mode, inverts to cream in dark mode. Used for filled buttons, the
  FAB, and the active nav indicator.
- **On Primary (`#F3F0EE` light / `#141413` dark):** Text/icon color on top
  of a `primary`-filled surface.
- **Primary Strong (`#000000` light / `#FFFFFF` dark):** A punchier tonal
  step beyond `primary` for the few places that need to read as the single
  most emphasized thing on a plain surface - income amounts, the chart's
  income series, the dashboard's "see all" link, and the date picker's
  "today" marker. It's the same ink/cream hue family as `primary`, just
  pushed to the far end (pure black / pure white) rather than a new color,
  which keeps Waldo's "almost no color" rule intact while still giving these
  specific moments real visual weight. It's a token for *emphasis on a plain
  surface*, not a substitute for `primary` on filled buttons or chips.
- **Primary Container (`#F4F4F4` light / `#2A2724` dark):** A soft tonal fill
  for selected/active chips and segmented controls.
- **Error (`#CF4500` light / `#F37338` dark):** The single accent hue in the
  entire system. Used only for destructive actions and negative/expense
  amounts - never decoratively.
- **Field Fill / Field Border (`#F5F5F5`/`#EEEEEE` light,
  `#242422`/`#353330` dark):** A neutral gray, deliberately *not* tinted
  toward the warm cream palette - text inputs need to read as "a field,"
  visually distinct from the cream cards and page background around them.
- **Leather / On Leather (`#141413` / `#F3F0EE`, same in both themes):** The
  wallet card's own material ink and cream-text pair. Fixed across light and
  dark because it models a physical object, not a themed surface.

## Typography

Everything is set in **Inter**. The base system has two weights - `500` for
anything that reads as a heading/label (with tight, slightly negative
tracking), and `400` for body copy (with a touch of negative tracking to
compensate for the lack of a true 450 weight) - plus four heavier "strong"
steps (`600`/`700`/`800`/`900`) reserved for the handful of places that need
to visually dominate the screen: transaction amounts, card titles, and the
balance figure on the dashboard.

- **Headline Display (28px / 500):** Reserved as the base for the dashboard
  balance figure's weight ladder (see `headline-display-strong` below).
- **Headline Large / Medium (22px/16px / 500):** Card and section titles.
- **Body Large / Medium / Small (16px/14px/12px / 400):** Paragraph and
  list-item copy.
- **Label Large / Medium / Small (14px/12px/11px / 500):** Buttons, chips,
  nav labels, captions.
- **Label XS (11px / 600, uppercase, +4% tracking):** Eyebrow-style section
  headers (e.g. the "OCTOBER 2026" month divider in the transactions list).
- **Strong variants**, one weight step above their base role, same size and
  tracking:
  - `body-md-strong` (600) - a touch heavier without reading as bold (links,
    row descriptions).
  - `body-md-bold` / `body-sm-bold` / `label-sm-bold` (700) - the common
    "this value matters" weight: form labels, button text, list-row
    emphasis. The most frequently used step in the app.
  - `label-lg-strong` (700) - transaction amounts, nav labels, confirm
    buttons.
  - `headline-md-strong` (600) - section headers within a screen ("Recent
    transactions", "Cash Flow").
  - `headline-lg-strong` (800) - the most common title weight: dialog
    titles, form sheet headers, card titles.
  - `headline-sm-bold` (800, 24px) - an alternate large title used by a
    handful of dialogs/cards instead of `headline-lg-strong`.
  - `amount-display-bold` (800, 28px) - the large numeric figure shown
    while editing an amount (transaction/wallet balance input).
  - `headline-display-strong` (900, 28px) - reserved for the single
    biggest number on a screen: the dashboard's total balance figure,
    specifically. Not general emphasis.

### Principles

- Weight only ever escalates along this named ladder (`body-md` →
  `body-md-strong`, `label-lg` → `label-lg-strong`, etc.) - never a bespoke
  `fontWeight: 650` picked by eye for one screen.
- Negative tracking scales with size: the biggest display text gets the most
  negative tracking (-2%), small labels get the least.
- Color carries emphasis for amounts (`primary-strong` positive,
  `error` negative) so weight and color are never both doing the same job on
  the same piece of text.

## Layout

Two spacing systems, intentionally: a **page scale**
(`xs` 8 / `sm` 16 / `md` 24 / `lg` 32 / `xl` 48) for gaps between
sections, cards, and list rows, and a **component scale**
(`xxs` 4 / `component` 12) for the internals of small, dense widgets - pill
toggles, filter chips, dialog action rows - where the page scale would read
as too loose. `page-margin` (24px) is the fixed side margin on every screen.

Every screen uses the same 24px outer gutter; nothing goes full-bleed except
photographic wallet-card textures and chart canvases.

## Elevation & Depth

Waldo is almost entirely flat - most surfaces sit directly on the page with
no shadow at all, separated only by the `surface` / `surface-container` color
step. Two levels of soft, large-spread shadow exist for content that truly
needs to lift off the page:

| Level | Treatment | Use |
|-------|-----------|-----|
| None | No shadow | Default - list rows, chips, inputs, the vast majority of surfaces |
| Low | `rgba(0,0,0,0.04)`, offset `(0, 4)`, blur `24` | Grouped list/transaction cards |
| High | `rgba(0,0,0,0.12)`, offset varies | Sheet/dialog shadowColor, drag handles |

There is no hard, tight shadow anywhere in the system - every shadow is a
large, low-opacity spread, closer to "the card is resting slightly above the
page" than a directional drop shadow.

## Shapes

Rounding is deliberately sparse - four steps, with a large gap between the
small and large tiers so the UI reads as either "a small control" or
"a soft card," never in between:

| Token | Value | Use |
|-------|-------|-----|
| `sm` | 12px | Chips, small badges |
| `md` | 20px | Buttons, text fields, segmented controls |
| `lg` | 28px | Cards, dialogs, sheets |
| `pill` | 9999px | Nav pill, FAB, toggle tracks, tags |

The middle ground most systems have (8-16px) is intentionally absent.

## Components

- **Buttons (primary):** `primary`-filled pill, `on-primary` text, `label-lg-strong`
  typography, `rounded.md`, 16px padding.
- **Cards:** `surface`-filled, `rounded.lg`, no elevation unless grouping
  list rows (see Elevation: Low).
- **Input fields:** `field-fill` background (never tinted toward the cream
  palette), `field-border` outline, `rounded.md`, `body-md` typography,
  2px `primary` border when focused, `error` border (1.5-2px) in an error
  state.
- **List rows (transactions/wallets):** leading icon in a circular tint of
  the row's semantic color (income/expense/wallet type), `label-lg-strong`
  title, `body-sm` muted caption, trailing amount in `label-lg-strong` colored
  by `primary-strong` (income) or `error` (expense).
- **Wallet cards:** a fixed `leather`/`on-leather` ink pair over a photographic
  metal texture (light mode) or a true dark-metal gradient (dark mode) -
  never a flat themed color.
- **List rows (secondary caption):** `surface` background, `on-surface-variant`
  caption/subtitle text, `body-sm` typography.
- **Amounts:** `primary-strong` text for income, `error` text for expense,
  both at `label-lg-strong`.
- **App bar:** transparent background - it never visually separates from the
  page.

## Do's and Don'ts

### Do
- Use `surface-container` as the page background and `surface` for anything
  that should lift off it by one step - never introduce a third surface
  level.
- Reserve `error` strictly for destructive actions and negative/expense
  amounts.
- Use `primary-strong` only on a plain surface for a single emphasized
  element (an amount, a link, a marker) - not as a button fill.
- Escalate text weight only along the named `-strong` ladder, never with an
  inline one-off `fontWeight`.
- Keep the wallet card's `leather`/`on-leather` pair fixed across themes.

### Don't
- Don't add a second accent hue - orange stays the only color in the system.
- Don't use `field-fill`/`field-border` anywhere except form inputs; they're
  deliberately the one cool-gray note against an otherwise warm palette.
- Don't round anything to a value between 12 and 20 - the gap between `sm`
  and `md` is intentional.
- Don't add a shadow to a surface that doesn't need to visually group or
  float - flat is the default, not the exception.

## Known Gaps

- **Color role scope:** Waldo's palette intentionally covers 14 roles and
  does not define Material 3's `secondary`, `tertiary`, `outline`, or the
  `surface-container-low/high/highest` tiers - the product has no use for a
  second or third accent hue, and only needs the one surface step documented
  above. If a future screen needs one of these roles, add it deliberately
  rather than letting it fall back to a Material default.
- **`on-error`:** resolved without a new token during Phase 2 - every
  filled-`error` surface (the destructive confirm button) uses
  `colors.onPrimary`, which already contrasts correctly against
  `error` in both themes (verified case by case, see
  `lib/core/widgets/confirmation_dialog.dart`). `ColorScheme.onError` is
  mapped the same way in `app_theme.dart`.
- **Strong-weight token reconciliation is done.** All ~90 hardcoded
  `fontWeight:` call sites now go through a
  named `context.*` getter (`lib/core/theme/app_theme.dart`). The original 4
  tokens only covered `bodyMedium`/`labelLarge`/`titleLarge`/`headlineLarge`
  bases; the real distribution skewed toward other Material roles
  (`titleMedium`, `headlineSmall`, `headlineMedium`, `bodySmall`,
  `labelSmall`) and toward `700` more than `600`, so the set grew to the
  13 tokens now in the front matter - `bodyMdBold`/`bodySmBold`/
  `labelSmBold` (the most common step, `700`), `headlineMdStrong`/
  `headlineSmBold`/`amountDisplayBold`, plus a correction:
  `headlineDisplayStrong` was originally defined against `headlineLarge`
  (32px, unused anywhere in the app) when the dashboard balance figure it's
  for actually uses `headlineMedium` (28px) - fixed to match the real call
  site rather than inflate the figure's size.
  4 sites remain intentionally raw, each documented inline: the wallet
  card's debossed ink-shadow label, one chart tooltip, one `TextSpan`
  inheriting ambient style (not a base-role override), and the wallet
  card's own titleMedium+800 balance figure (a real one-off step, not
  `headline-md-strong`'s 600).
- **Micro-text sizes (11-15px) stayed as documented one-offs, not
  `label-xs`.** The audit proposed one token for this whole cluster, but
  each site turned out to have its own real letter-spacing/weight pairing
  (the receipt header's 0.8 tracking, the chart axis label's fl_chart-owned
  styling, the month chip's selected/unselected size+weight pair) that
  `label-xs` (11px/600/0.4 tracking) doesn't match - forcing it in would
  have been a visual change, not just a naming change. Each site now has an
  inline comment explaining why it's an exception; see
  `scripts/design_guardrail.sh`'s `// one-off` convention.
- **Elevation has no numeric scale.** `Elevation.low`/`.high` (BoxShadow
  lists) and `.highShadowColor` are live, but the handful of raw Material
  `elevation: 1` / `elevation: 3` doubles (`circle_icon_button.dart`,
  `wallets_card_stack.dart`) aren't tied to a named constant yet.
- **Guardrail doesn't check `EdgeInsets`/`SizedBox` numbers yet.**
  `make design-guardrail` currently only checks `Color(0x...)` and raw
  `fontSize:` outside `lib/core/theme` (see
  `scripts/design_guardrail.sh`) - EdgeInsets/SizedBox snapping to
  `Spacing.xxs`/`.component` happened for the clearest cases but not
  exhaustively, so turning that
  check on now would fail on real, not-yet-reconciled call sites.
- **`_DashedCircleBadge` (confirmation_dialog.dart) vs. `PouchBorder`
  (pouch_shape.dart) vs. `transaction_edit_sheet.dart`'s own dashed
  painter.** Found via code-review during Phase 2, not in the original
  audit. All three paint a dashed stroke along a path, but for visually
  different shapes (a stitched pill border vs. a circular badge ring) -
  merging them risks a real visual regression without case-by-case
  verification, so this was logged rather than merged. A shared
  "dash-along-path" math helper (not a shared widget) is the likely right
  shape for a future fix.
- **Figma:** no Figma file yet (Phase 4 of the design-system spec).
