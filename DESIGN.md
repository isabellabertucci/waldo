---
version: alpha
name: Waldo
description: >
  Waldo is a personal finance app where money lives in leather wallets. Every
  screen has two zones: on top, over the beige page, what is "now" (the
  balance and the actions); below, on a white sheet, the detail. Colour is
  sparse and functional - ink text, a yellow for the one main action, a soft
  green for good news, green and red only for gains and losses - and there
  are no shadows: surfaces separate by colour (`bg` -> `sheet` -> `card`) and
  a 1px `line` outline. Type is the platform's system font (SF Pro on iOS),
  its hierarchy from size and weight alone.
colors:
  transparent: "transparent"
  bg-light: "#EFEEEA"
  bg-dark: "#141414"
  sheet-light: "#FFFFFF"
  sheet-dark: "#1C1C1E"
  card-light: "#F4F2EC"
  card-dark: "#26262A"
  line-light: "#E3DED4"
  line-dark: "#38383C"
  ink-light: "#141414"
  ink-dark: "#FFFFFF"
  ink-muted-light: "#6B6B70"
  ink-muted-dark: "#A3A3A8"
  positive-light: "#2E7D4F"
  positive-dark: "#8FD3A5"
  negative-light: "#C62828"
  negative-dark: "#FF9B8F"
  leather: "#141414"
  on-leather: "#FFFFFF"
  bg-top-light: "#E6E1D8"
  bg-top-dark: "#1E1E20"
  chip-light: "#FFFFFF"
  chip-dark: "#323236"
  primary: "#F3D33F"
  on-primary: "#141414"
  accent: "#BFE0B4"
  on-accent: "#141414"
  divider-light: "#EFEEEA"
  divider-dark: "#2A2A2D"
  nav-active-light: "#141414"
  nav-active-dark: "#F3D33F"
  on-nav-active-light: "#FFFFFF"
  on-nav-active-dark: "#141414"
typography:
  amount-hero:
    fontFamily: system-ui
    fontSize: 32px
    fontWeight: 700
    lineHeight: 38px
    letterSpacing: -0.03em
  amount-wallet:
    fontFamily: system-ui
    fontSize: 20px
    fontWeight: 700
    lineHeight: 26px
    letterSpacing: -0.02em
  amount-row:
    fontFamily: system-ui
    fontSize: 15px
    fontWeight: 600
    lineHeight: 20px
    letterSpacing: 0em
  title-page:
    fontFamily: system-ui
    fontSize: 28px
    fontWeight: 700
    lineHeight: 34px
    letterSpacing: -0.02em
  title-section:
    fontFamily: system-ui
    fontSize: 20px
    fontWeight: 700
    lineHeight: 26px
    letterSpacing: -0.01em
  title-card:
    fontFamily: system-ui
    fontSize: 16px
    fontWeight: 600
    lineHeight: 22px
    letterSpacing: 0em
  body:
    fontFamily: system-ui
    fontSize: 15px
    fontWeight: 500
    lineHeight: 20px
    letterSpacing: 0em
  body-strong:
    fontFamily: system-ui
    fontSize: 15px
    fontWeight: 600
    lineHeight: 20px
    letterSpacing: 0em
  label:
    fontFamily: system-ui
    fontSize: 13px
    fontWeight: 500
    lineHeight: 18px
    letterSpacing: 0em
  caption:
    fontFamily: system-ui
    fontSize: 12px
    fontWeight: 500
    lineHeight: 16px
    letterSpacing: 0em
  overline:
    fontFamily: system-ui
    fontSize: 11px
    fontWeight: 700
    lineHeight: 14px
    letterSpacing: 0.1em
rounded:
  sm: 14px
  md: 22px
  lg: 24px
  sheet: 32px
  pill: 9999px
spacing:
  xxs: 4px
  xs: 8px
  component: 12px
  sm: 16px
  md: 24px
  lg: 32px
  xl: 56px
  page-margin: 16px
components:
  button-primary-light:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.body-strong}"
    rounded: "{rounded.pill}"
    padding: 16px
  button-primary-dark:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.body-strong}"
    rounded: "{rounded.pill}"
    padding: 16px
  card-light:
    backgroundColor: "{colors.sheet-light}"
    rounded: "{rounded.lg}"
  card-dark:
    backgroundColor: "{colors.sheet-dark}"
    rounded: "{rounded.lg}"
  input-field-light:
    backgroundColor: "{colors.card-light}"
    textColor: "{colors.ink-light}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    padding: 16px
  input-field-dark:
    backgroundColor: "{colors.card-dark}"
    textColor: "{colors.ink-dark}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    padding: 16px
  list-item-light:
    backgroundColor: "{colors.sheet-light}"
    textColor: "{colors.ink-muted-light}"
    typography: "{typography.label}"
    rounded: "{rounded.lg}"
  list-item-dark:
    backgroundColor: "{colors.sheet-dark}"
    textColor: "{colors.ink-muted-dark}"
    typography: "{typography.label}"
    rounded: "{rounded.lg}"
  amount-positive-light:
    textColor: "{colors.positive-light}"
    typography: "{typography.amount-row}"
  amount-positive-dark:
    textColor: "{colors.positive-dark}"
    typography: "{typography.amount-row}"
  amount-negative-light:
    textColor: "{colors.negative-light}"
    typography: "{typography.amount-row}"
  amount-negative-dark:
    textColor: "{colors.negative-dark}"
    typography: "{typography.amount-row}"
  app-bar:
    backgroundColor: "{colors.transparent}"
---

# Waldo Design System

## Overview

Waldo is a personal finance tracker: wallets, transactions, categories, a
dashboard. Money lives in **leather wallets**, and every screen has two
zones: on top, over the beige page (`bg`), what is "now" - the balance and
the actions; below, on a white sheet (`sheet`), the detail - wallets, the
month's summary, transactions. One idea per section; nothing decorative.

The source of truth for the tokens is the Waldo design system (the "Waldo"
Design System artifact, `tokens.json`); this file mirrors it for the code.
The undo bar keeps `leather` with `on-leather`
text in both themes, the way a real wallet doesn't change colour when the
room gets darker.

## Colors

`AppColors` (`lib/core/theme/app_colors.dart`) uses the design system's
token names, so `colors.inkMuted` is `ink-muted`. The one name the system
doesn't have is `onInk`, the text on an ink fill.

| Code | Light | Dark | Use |
|---|---|---|---|
| `bg` | `#EFEEEA` | `#141414` | The page, under everything |
| `bgTop` | `#E6E1D8` | `#1E1E20` | Where the page's beige top starts, fading into `bg` |
| `sheet` | `#FFFFFF` | `#1C1C1E` | The sheet content sits on; cards on the page |
| `card` | `#F4F2EC` | `#26262A` | Blocks inside a sheet, fields, segmented controls, icon discs |
| `chip` | `#FFFFFF` | `#323236` | Round buttons on the page, secondary action circles, outlined in `line` |
| `line` | `#E3DED4` | `#38383C` | 1px outlines (round buttons, navbar, menus) and the hairlines inside a `card` block |
| `divider` | `#EFEEEA` | `#2A2A2D` | Hairlines between rows of a list on the white sheet (transactions, ghost rows) |
| `ink` | `#141414` | `#FFFFFF` | Text and icons (4.5:1+ on `bg`, `sheet` and `card`); as a fill, the picked segment or pill and ink buttons |
| `onInk` | `#FFFFFF` | `#141414` | Text and icons on an `ink` fill |
| `inkMuted` | `#6B6B70` | `#A3A3A8` | Secondary text; 4.5:1+ on `bg`, `sheet` and `card` |
| `primary` / `onPrimary` | `#F3D33F` / `#141414` | same | The yellow: the one main action on a screen, rightmost; never text |
| `accent` / `onAccent` | `#BFE0B4` / `#141414` | same | Details and good news: the month's change pill, an active filter, a picked option's disc |
| `positive` | `#2E7D4F` | `#8FD3A5` | A gain: the sign and the figure together |
| `negative` | `#C62828` | `#FF9B8F` | A loss, errors, destructive actions |
| `navActive` / `onNavActive` | `#141414` / `#FFFFFF` | `#F3D33F` / `#141414` | The navbar's chosen tab: ink in light, yellow in dark |
| `leather` / `onLeather` | `#141414` / `#FFFFFF` | same | The undo bar |

- **Amounts are coloured whole:** sign and figure in `positive` or
  `negative`, never the sign alone. Zero stays `ink`.
- The wallet leathers live in `LeatherColors` (`lib/core/theme`), the same
  in both themes, since a wallet is an object: black `#2E2E30`→`#121213`,
  yellow `#FAEDB4`→`#F2DE82` (soft, in the green's tone, never the main action's yellow), green `#CDE8C3`→`#A9D29B`, white
  `#FFFFFF`→`#ECEAE5`, each with a strap a tone off the same leather (black `#56565B`, yellow `#EFD670`, green `#9CCB8C`, white `#E3DED4`), as in the design system.

## Typography

Everything is set in the **platform's system font** (SF Pro on iOS), so
nothing is bundled. The hierarchy comes from size and weight alone, on the
design system's scale (`_applyTypeScale` in `app_theme.dart`, named getters
on `context`):

| Style | Size / line / weight | Use |
|---|---|---|
| `amountHero` | 32 / 38 / 700, -3% | The total balance only |
| `amountWallet` | 20 / 26 / 700, -2% | A balance inside a wallet - never larger |
| `amountRow` | 15 / 20 / 600 | An amount in a list row |
| `titlePage` | 28 / 34 / 700, -2% | A page without a balance on top (Settings) |
| `titleSection` | 20 / 26 / 700, -1% | Every section title; never mixed |
| `titleCard` | 16 / 22 / 600 | A title inside a card |
| `bodyMedium` (`body`) | 15 / 20 / 500 | List rows, copy |
| `bodyStrong` | 15 / 20 / 600 | A row's name, buttons |
| `label` | 13 / 18 / 500 | Labels and secondary text |
| `caption` | 12 / 16 / 500 | Small print |
| `overline` | 11 / 14 / 700, +10% | Group headers ("TODAY"), upper-cased by the caller |

Every amount style uses tabular figures, so digits line up and don't jiggle
as they change.

Every screen uses only the scale above (`context.amountRow`,
`context.titleSection`, `context.body`, `context.label`, ...); there is
no other text style.

### Principles

- Emphasis is a step on the scale (`body` → `body-strong`), never a
  bespoke `fontWeight` picked by eye for one screen. The scale tops out at
  700.
- Negative tracking scales with size: the total balance gets the most
  (-3%), body text none; only the `overline` is tracked out (+10%).
- Color carries emphasis for amounts (`positive` gains, `negative`
  losses) so weight and color are never both doing the same job on the same
  piece of text.

### Large text

Waldo follows the phone's text size up to iOS's largest (AX5), the way
Apple's own apps do: everything gets big, but stays in order.

- **Titles grow less than body text.** iOS gives Flutter one factor for
  every size; `DynamicTypeScaler` applies Apple's per-style table instead,
  so at AX5 a title is only a little bigger than the text under it. Android
  14+ already scales this way itself.
- **Bars and segmented controls stop at xxxLarge** (`barMaxScale`), as
  iOS's tab bar and segmented control do: the navbar, the Expense/Income
  toggles, the undo countdown.
- **At the accessibility sizes (AX1 and up) layouts stack.** A badge moves
  above its text (`BadgeRow`), a value or button moves under its label,
  the wallet type tiles become one column, dialog buttons stack, and the
  wallet cards grow while the part under the next card stays the same.
- **No word is ever broken or cut.** One-line text wraps at accessibility
  sizes (`WholeWordsText.singleLine`), and a word wider than its line
  shrinks just enough to fit, like UIKit's `adjustsFontSizeToFitWidth`.
- **Amounts are never cut.** A balance or amount shrinks to fit its line
  instead.

## Layout

Two spacing systems, intentionally: a **page scale**
(`xs` 8 / `sm` 16 / `md` 24 / `lg` 32 / `xl` 56) for gaps between
sections, cards, and list rows, and a **component scale**
(`xxs` 4 / `component` 12) for the internals of small, dense widgets - pill
toggles, filter chips, dialog action rows - where the page scale would read
as too loose. Each is one of the design system's `space-1`…`space-7`
(4 / 8 / 12 / 16 / 24 / 32 / 56); `xl` is the room under the floating
navbar at the end of a page. `page-margin` (16px, `space-4`) is the fixed side margin on every screen.

Every screen uses the same 16px outer gutter; nothing goes full-bleed except
photographic wallet-card textures and chart canvases.

Round icon discs (badges) beside a label come in three sizes, `BadgeSize`
in `core/theme/badge_size.dart`: `sm` 28 (category chips in the
transaction form), `md` 36 (form fields, option tiles, category and list
rows) and `lg` 40 (settings rows, option-sheet rows, transaction rows).
A divider that starts under a row's title indents by row padding +
badge + gap, so it moves with the badge.

A badge's disc shows what is behind its card, as if cut out of it: the page
(`bg`) for a card on the page, the sheet (`sheet`) for a
field or option row inside a sheet. The icon carries the meaning and stays
at 3:1 or more against the disc; the disc itself is decoration. A light
green (`StateStyle.pickedFill`) disc is kept for a picked option.

### Compact bar

A long page keeps its few top actions in reach (NN/g "Sticky headers"; the
iOS large title that shrinks to a bar). On `SheetPage`, pass a `bar`
(`SheetPageBar`): once the beige top has scrolled away, a slim `sheet`
bar with a 1px `line` underneath stays pinned under the status bar: back,
the page's name with its amount in `label`, and the `HideAmountsButton`.
It fades in and out in `Motion.toggle`, never slides, and is gone (not
just clear) while the top shows, so no button is ever there twice. Used on
Home (total balance), Wallets (all wallets' total) and a wallet's screen
(with back); a tab has no back, so an equal gap keeps the title centred.
Before the first wallet it still shows, without the eye: there's
nothing to hide. All transactions, Settings and Categories have one too.

## Elevation & Depth

**No shadows.** Surfaces separate by colour - `bg` → `sheet` → `card` - and,
where something floats (the navbar, round header buttons, the ⋮ menu), by a
1px `line` outline. The only "shadow" is the metal button's rim on a
leather wallet.

## Shapes

| Token | Value | Use |
|-------|-------|-----|
| `sm` | 14px | A wallet's strap, mini wallets, month chips |
| `md` | 22px | Cards inside a sheet (charts, in/out, alerts) |
| `lg` | 24px | Leather wallets, dialogs; a sheet when the screen is square |
| `sheet` | 32px | The top corners of the white sheet |
| `pill` | 9999px | Buttons, pills, the navbar; circles (width = height) |

## Borders

**Stitch only on leather.** The dashed stitch is the leather's own seam: the
wallets and the undo bar. Everywhere else a state is a solid colour, never a
dashed line. A stitched shape cuts its dashes with `dashPath`
(`core/utils/dash_path.dart`), so none carries its own loop.

The thread and its patterns are tokens in `Stitch` (`core/theme/stitch.dart`):
one width (1.5px), one dash/gap pattern (`regular` 4/3) and the wallet's
inset (`walletInset`, 9px).

- **States come from one place,** `StateStyle` (`core/theme/state_style.dart`),
  so they change together. The line is `ink`: it's in the
  palette and far past the 3:1 a state's outline needs (WCAG 1.4.11),
  where `accent` on cream has 1.3:1. The filled marks are `accent`. `StateStyle.picked` is a
  solid 2px line round the picked option in a list
  (option sheets), with its disc and tick in
  `StateStyle.pickedFill`; `StateStyle.focused` the same line round the
  field being typed in; at rest the line is clear (no stroke), and the
  label over the field says where it is. A segmented pill (type, Expense/Income, the navbar
  tab) is filled ink instead; an active filter tile is filled `accent`.
- **Placeholders** may still use a faint stitch (`ink-muted` at low
  alpha).
- Nothing has a border at rest unless it is a placeholder.
- **Sheets and dialogs have no frame.** A frame would compete with the line
  that marks what's picked inside them.
- **Errors show in words, under the field** (`negative` text), never as the
  field's border: the solid `accent` line means only focus.
- **A screen that fails to load is never a dead end:** `LoadError` says what
  failed and offers "Try again" (a `SecondaryButton`), which reloads it.
- **Deleting says what goes with it:** a wallet's confirmation counts the
  transactions deleted along with it.

## Motion

Durations are Material 3's own steps, named for what they move, in `Motion`
(`core/theme/motion.dart`). A new animation picks one of these instead of a
number of its own.

| Token | Duration | Use |
|---|---|---|
| `toggle` | 150ms (`short3`) | A segment or toggle filling in |
| `scroll` | 300ms (`medium2`), ease-out | A row scrolling to a picked item |
| `enter` | 350ms (`medium3`), fast then settling | Something arriving, like the undo bar |
| `hint` | 1400ms, out and back | The nudge hinting that a row scrolls |
| `pillStretch` | 450ms (`long1`), `emphasizedCurve` | The month and navbar pills stretching to a new pick like ink: the front edge arrives in the first `pillStretchLead`, then the back catches up |
| `chartMorph` | 600ms (`long4`), `emphasizedCurve` | The line reshaping between expense and income, colour and all |
| `chartLabel` | 250ms (`medium1`) | The month's total fading `chartLabelRise` in over the line's end point |
| `sheetExit` | 200ms (`short4`) | The new-wallet sheet sliding away; a card made in it waits this out before it lands |

Curves come from `Motion` too. Simple chains (fade, slide, shake) use
`flutter_animate`, with every duration from `Motion`, never a `300.ms` of its
own; the design guardrail catches a raw `.ms`, `Duration(milliseconds:` or
`Curves.`.

**Reduce motion:** every animation takes its duration through
`context.motion(Motion.x)`, which is zero when the phone asks for reduced
motion (iOS "Reduce Motion", Android "Remove animations"), so it jumps to its
end. A `flutter_animate` effect would still draw its first frame, so with
reduced motion it isn't built at all (`context.reduceMotion`). Anything that
moves on its own, like the scroll hint, is skipped.

Animate position, opacity, scale and paint only - never width, height or
padding, which lay the screen out again on every frame. A moving selection
is painted (`StretchPill`), not a resized box.

**Haptics** aren't motion, so they stay on with reduce motion:
`HapticFeedback.selectionClick()` when a choice moves (a month, a tab, the
cash-flow series), and only when it actually changes; `lightImpact()` when
something opens or lands (a ⋮ menu, a new card); `mediumImpact()` when
something goes away (a deleted card).

## Other tokens

Every design value a widget uses comes from `lib/core/theme`; there is no
`// one-off` escape hatch.

- **`Alpha`** (`alpha.dart`): opacity steps - `tint` 0.08,
  `soft` 0.12, `medium` 0.18, `stitch` 0.3, `line` 0.4, `muted` 0.6,
  `strong` 0.8.
- **`ComponentSize`** (`component_size.dart`): dimensions that belong to one
  component - the leather wallet, the chart, the undo ring, the
  navbar's selected tab, the grabber.
- **`LeatherColors`** (`leather_colors.dart`): the leathers, their text and
  the metal button, which imitate real objects and so don't follow the
  themes.
- **`Fades`** (`fades.dart`): alpha masks that fade a row's edges.

Two kinds of number stay in code: the shape of a drawing inside its painter
(the eye's path, the undo ring's arc), and behaviour
constants such as counts and time windows (five category rows, the 10-second
undo window).

## Components

- **Leather wallet:** `LeatherWallet` (`core/widgets`) - a 150° gradient
  with the leather's grain (`leather-grain.png`, colourless, at 12%), a
  1.5px dashed stitch 9px in, and a 46px strap with a 15px metal button on
  the right edge. The finish is picked in the wallet's form and stored with it
  (`Wallet.finish`): black, yellow, green or white. A new wallet suggests
  the one the fewest wallets wear (`suggestedFinish`), so the first is
  black. Home stacks up to four,
  the ones behind `walletStackStep` (40, 8) further and 16px shorter. A
  wallet shown alone (its own screen) is at most `walletAloneWidth` (264)
  wide and centred, so it keeps a wallet's shape. In a list row it's a
  `LeatherWalletThumb`: the same wallet drawn `walletThumbScale` (2.5x)
  larger and scaled down to `walletThumb` (64 x 48).
- **Wallet face:** `WalletFace` (`features/wallets`) - what the leather
  shows: the type on a disc of the leather's ink at the top, the name and
  the signed balance (green/red on the leather) at the bottom. Home's
  stack and the wallet's screen share it.
- **Tab page:** `SheetPage` (`core/widgets`) - the beige top (`bgTop` to
  `bg`) with the balance or wallet and the action circles,
  then the white sheet (`rounded.sheet` top corners) with the detail,
  scrolling as one. It runs under the status bar and the navbar and pads
  for both. Home, Wallets and a wallet's screen use it. `HeroBalance` is
  the top's "Total balance" over `amount-hero` with the cents muted, one
  stop for screen readers.
- **Action circles:** `ActionCircle` - 58px, label underneath in `label`,
  three in a row on the beige top, the main one last and in `primary`;
  presses to `pressScale` (0.95) over `press` (200ms). A toggle (Filter)
  is `accent` while on, and a 14px `primary` dot ringed in `sheet`
  (`actionMark`) says it's changing something.
- **Filter tiles:** `FilterTiles` (`core/widgets`) - a filter's choices on
  the page, not in a sheet: three to a row (one at accessibility sizes),
  each on `card` with a 36px `sheet` disc, the name in `body-strong` and
  how many it leaves in `label`. The chosen one is `accent` at
  `Alpha.stitch` with an `accent` disc, no border. The
  wallets list filters by type with them, a wallet's transactions by
  Expense/Income, so filtering looks and works the same everywhere: the
  tiles wait behind a Filter action circle, which is `accent` while they
  show and carries the yellow dot while a choice other than All is on.
- **Month stepper:** `MonthStepper` (`core/widgets`) - "‹ November ›", a
  year back up to this month; the way forward is in ink, either end dimmed
  and out of the tab order. On a wallet's screen it's part of the filter,
  above the type tiles, behind Filter; the dot is on while the filter
  shows anything but this month's everything.
- **Segmented:** `Segmented` (`core/widgets`) - two or three short
  labels on a `card` track as wide as the sheet, the picked one in ink;
  48px touches. The content below swaps with a fade and a `segmentSlide`
  slide towards the picked side over `segmentSwap` (320ms). A wallet's
  screen uses it for Transactions | Analysis.
- **Wallet form:** a preview of the wallet as it will be
  (`walletPreview`, the wallet alone scaled down), then the name, the type
  as `ChoiceChips`, the leather as 52px swatches (`swatch`) with an
  ink ring 3px out around the chosen one, and the starting balance.
  Section titles are `body-strong` in `ink-muted`, not capitals.
- **Choice chips:** `ChoiceChips` - icon-and-name pills, ink when
  picked, `card` when not, in a row that scrolls sideways (wrapping at
  accessibility sizes). A wallet's type, and the new transaction's recent
  categories.
- **Empty states** (`core/widgets/ghost.dart`): a faint ghost of what
  will be there, fading back (`GhostWalletStack` on Home, `GhostRows` of
  wallet thumbnails or transaction discs in lists), then a `title-card`
  title, a `label` line saying what it is for, and on Home the yellow
  "Create your first wallet" (text only). Sections that come later are a
  `PlaceholderCard` (a faint stitch: the one place outside leather) saying
  when they show up. Ghosts are decoration, hidden from screen readers.
  The action circles keep their places: what can't be done yet is greyed
  out (`ActionCircle` with no `onPressed`: `card` fill, `ink-muted`
  icon and label, read as disabled), and the yellow moves to the one that
  can (New wallet).
- **Settings:** a tab like Home and Wallets (`SheetPage`): the beige top
  holds the page title (`title-page`), the white sheet holds sections - an
  `overline` title ("PREFERENCES", "ORGANIZE") over one `card` block
  (`Rounded.md`) whose rows are divided by `line` hairlines indented to
  the title. A row: a `sheet` disc (cut out of the card) with its icon,
  the name in `body-strong`, the value in `label` `ink-muted` and
  a `›`.
- **All transactions:** a `SheetPage` like Categories: back over the
  title (`title-page`) and the eye on the beige top; the days on the white
  sheet, part of the page's one scroll. Once the title scrolls away the
  compact bar keeps back, the title and the eye.
- **Sheet page:** the white sheet always runs to the bottom of the screen,
  however short the page (its least height is the screen less the
  measured top), with the navbar's clearance inside it.
  Every page has a compact bar, so nothing scrolls under the clock:
  Settings with its title only, Categories with back and the title.
- **App icon shortcuts:** pressing and holding the icon on the phone's
  home screen offers "New expense" and "New income" (`TransactionShortcuts`,
  `quick_actions`); each opens Home with the new-transaction sheet on that
  type. Their icons (a circle with a minus, with a plus) are native assets:
  `ios/Runner/Assets.xcassets/shortcut_*` and
  `android/app/src/main/res/drawable/shortcut_*.xml`. The recent-category
  chips follow the sheet's type: an income offers the categories used for
  incomes.
- **New transaction:** the amount (keyboard open at once), then up to 4
  recent categories as `ChoiceChips` under "Recent" (a second tap unpicks;
  "Others" never shows, it's what no pick means), then Wallet, Category
  and Date - the wallet prefilled with the one used last, or the only one.
  All above the keyboard, so the usual expense is Transaction, the amount,
  Add.
- **Wallet rows:** `WalletListRow` - the leather thumbnail, the name in
  `body-strong` over how it stands ("In the red", "Empty", "29% of your
  money") - not its type, which the group heading already says - the signed balance in `amount-row` and a `›`.
  Grouped by type under an `overline` header with the count and the
  group's total on the right ("CASH · 4 ... 224.00 £"), richest wallet
  first. Each row is its own `card` (`Rounded.md`, `sm` padding, `xs`
  apart), with no chevron; an empty wallet's amount is
  `ink-muted`, so the ones with money stand out. No sideways
  carousel: Home's stack is the highlight. A tap opens
  the wallet; a long press offers Edit and Delete.
- **Transaction rows:** `TransactionRow` - the same shape as a wallet row,
  straight on the sheet with no card: the category in a `card` disc, the
  description in `body-strong` over the category in `label`, the signed
  amount in `amount-row` (`positive` or `negative`) and a `›`. `TransactionRows`
  puts `line` hairlines between them; by day, each day heads its rows in an
  `overline`, as wallet types do. A tap opens it read-only; a long press
  offers Edit and Delete.
- **Spending by category:** `CategorySpendingCard` - the month's expense
  per category on `card`, dearest first, five lines then "Others", each
  with an ink bar against the dearest; amounts in ink, not red.

- **Buttons (primary):** `PillButton` - a solid `primary` (yellow)
  pill (`rounded.pill`) with no stitch, `on-primary` text in
  `body-strong`, like the main action circle. The hierarchy: yellow
  (`primary`) is the main action; `ink` is second - the picked
  side of a segmented choice (type, Expense/Income, the navbar tab in
  light - `nav-active`, yellow in dark - the
  chosen leather's ring); light green
  (`accent`) is for details - a focused field's line, an active filter,
  good news. No variant has a stitch; 24px x 16px padding. Plain
  `FilledButton`s get the same
  pill and type from the theme.
- **Buttons (secondary):** `SecondaryButton` - a `rounded.pill` filled with
  `accent` (light green), on the page and on sheets alike; `on-accent` text
  in `body-strong`, 12px x 4px padding. For small actions inside a card
  or beside a title ("See all", the filter's "Reset"). "Cancel" is not one:
  it backs out rather than acts, so it stays the neutral
  `PillButtonVariant.secondary`.
- **Rows card:** `RowsCard` (`core/widgets/rows_card.dart`), on the white
  sheet: an optional `overline` title, then the rows on one `card` block
  (`Rounded.md`, flat), divided by `line` hairlines that start under the
  name. Its rows sit 16px (`sm`) from the sides around a 40px
  (`BadgeSize.lg`) `RowDisc` - `sheet`, cut out of the card. Settings
  and Categories use it; Categories puts the built-ins under "BUILT-IN"
  and the user's own, with their ×, under "YOURS".
- **Sheets:** every bottom sheet opens with `showAppSheet` and floats: a
  `sheet` card 12px (`component`) in from the screen's sides and bottom (just
  above the keyboard when it's up). Its corners are concentric with the
  screen's: the phone's own corner radius, read at start by
  `corner_radius_plugin`, less those 12px; `rounded.lg` when the phone doesn't
  say. Inside, content keeps a 24px (`md`) side margin, form or list alike
  (the page itself uses 16px).
- **Input fields:** `FormPillField` - the label above in `body-strong`
  `ink-muted` (like a form's section titles), then a `card` box,
  `rounded.lg`, `Spacing.sm` inside, with only the input and, at the end, a
  short unit such as the currency symbol. No icon or disc. No line at rest, a solid 2px ink line while typing (`StateStyle.focused`)
  marks it as focused; the error message sits under the box.
- **Required fields:** the label ends in " *" (`FieldLabel(required: true)`),
  in `ink` rather than `negative` - nothing is wrong yet. Screen readers
  hear "required". Optional fields carry no mark, and neither do the hero amount
  and single-field forms.
- **Sheet errors:** a failed save shows its message inside the sheet, centered
  just above the button, in `body-strong` `negative` - never a SnackBar, which
  would land behind the sheet. It names the cause (storage full, try again)
  when it is known.
- **List rows (transactions/wallets):** leading icon in a circular tint of
  the row's semantic color (income/expense/wallet type), `body-strong`
  title, `label` muted caption, trailing amount in `amount-row` colored
  by `positive` (income) or `negative` (expense).
- **List rows (secondary caption):** `sheet` background, `ink-muted`
  caption/subtitle text, `label` typography.
- **Amounts:** `positive` text for income, `negative` for
  expense, sign and figure together.
- **Page top:** no app bar - every page is a `SheetPage`, with its title on
  the beige top and its compact bar once that scrolls away.
- **One pattern per input:** the same field looks and works the same on
  every screen. The amount is always `TransactionAmountCard`: the
  Expense/Income toggle (the picked side a solid ink pill with
  `on-ink` text) over a `FormPillField`, sign before the number, currency symbol at the
  end, typed with the system keyboard. A choice from a list
  (wallet, category, date) is always an `EditFieldRow` - name at the start,
  value at the end - grouped in one `card` block by
  `EditFieldRow.group`, opening `showOptionSheet` - the same tiles as the
  Settings pickers, picked with one tap. A picker that can grow puts its
  "New ..." tile first, so making one never means leaving the sheet. A
  sheet of things to do (the dashboard's "Add") is `showActionSheet`: the
  same title, close button and tiles, without the rings.

## Do's and Don'ts

### Do
- Use `bg` as the page background and `sheet` for anything
  that should lift off it by one step - never introduce a third surface
  level.
- Reserve `negative` strictly for destructive actions and negative/expense
  amounts.
- Use only the design system's text scale, never an inline `fontWeight`.
- Keep the undo bar `leather`/`on-leather` in both themes.
- Reuse the input a screen already has before building another: a new form
  uses the same amount card and pickers as the existing ones.

### Don't
- Don't use colour as decoration: green and red are only gains and losses,
  the yellow only the one main action.
- Don't round to a value off the scale (14 / 22 / 24 / 32 / pill).
- Don't add a shadow - separate by colour, or a 1px `line` where something
  floats.

## Known Gaps

- **Color names:** `AppColors` has the design system's token names (table
  under Colors); every colour token of the design system is in it or in
  `LeatherColors`. Only `onInk` is the code's own.
- **On `negative`:** every filled-`negative` surface uses `colors.onInk`
  (white on `#C62828` is 5.6:1; dark `#141414` on `#FF9B8F` is 9.6:1).
- **Guardrail doesn't check `EdgeInsets`/`SizedBox` numbers.**
  `make design-guardrail` fails on a raw `Color(0x...)`, `Colors.*`,
  `fontSize:`, `fontWeight:`, `Duration(milliseconds: ...)` or fractional
  `alpha:` outside `lib/core/theme`, with no exception marker. Spacing and
  sizes come from `Spacing`, `BadgeSize`, `IconSize` and `ComponentSize`
  today, but a numeric check would also flag painter geometry, so it isn't
  on.
- **Figma:** no Figma file yet (Phase 4 of the design-system spec).
