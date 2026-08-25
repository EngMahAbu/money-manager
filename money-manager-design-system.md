# Money Manager App — Design System

## Design Philosophy

- **Flat & minimal** — no gradients, no drop shadows, no decorative effects. Clean flat surfaces
  only.
- **Glanceable** — this is an app people check for 2-3 seconds at a time. Key numbers (balances,
  totals) get large, bold treatment; everything else stays quiet.
- **Consistent color coding** — the same color always means the same thing, across dashboard,
  transaction list, and charts. Users should learn the code once and never have to re-decode it per
  screen.
- **One-thumb reachable** — primary action (quick-add transaction) sits in the most reachable
  position on screen.

---

## Color Palette

All values below are light mode, exact and implementation-ready (hex). Dark mode is deferred — see
Open Design Questions in the app spec doc.

### Surfaces

| Token           | Hex       | Usage                                                                                                                                 |
|-----------------|-----------|---------------------------------------------------------------------------------------------------------------------------------------|
| `surface.page`  | `#F1EEE6` | App background behind cards                                                                                                           |
| `surface.card`  | `#FFFFFF` | Raised card background                                                                                                                |
| `surface.inner` | `#F1EEE6` | Nested rows inside a card (list rows, chips, keypad keys) — same tone as page background, distinct from the white card it sits inside |

### Text

| Token            | Hex       | Usage                           |
|------------------|-----------|---------------------------------|
| `text.primary`   | `#1C1B18` | Main content, big numbers       |
| `text.secondary` | `#716F65` | Supporting labels               |
| `text.muted`     | `#A6A399` | Hints, timestamps, placeholders |

### Borders

| Token            | Hex       | Usage                               |
|------------------|-----------|-------------------------------------|
| `border.default` | `#E6E2D6` | 0.5px hairline dividers             |
| `border.strong`  | `#CFCBBB` | Dashed "+" tiles, stronger dividers |

### Semantic roles

| Role               | Fill      | Background tint | Text      |
|--------------------|-----------|-----------------|-----------|
| Success (green)    | `#1F9D63` | `#E4F6EC`       | `#167A4C` |
| Danger (coral/red) | `#E15241` | `#FBEAE7`       | `#C2432F` |
| Accent (blue)      | `#3E7CB8` | `#E8F1F9`       | `#2E5F8D` |

Used for: income/expense direction (amounts, metric cards, transaction row badges), credit card debt
display, active nav/interactive elements.

### Category color rule (revised)

**Category icon badges use the rotating ramp, assigned deterministically per category — not
type-tinted.** This was revised from the original type-tinted approach: with many categories sharing
one type, a long list of same-type transactions (e.g. several different expenses) all rendered as
the same red circle with no visual way to tell them apart at a glance. The ramp solves that — each
category gets a consistent, distinct color everywhere it appears (Categories Management, transaction
row badges, Reports donut/legend).

- **Assignment is deterministic, not stored**: a category's ramp color is computed the same way
  everywhere (e.g. its position among all categories, cycling through the ramp), so "Groceries" is
  always the same color across every screen without needing a `color` column on the Categories
  table — consistent with the earlier decision that category color is derived, never independently
  chosen.
- **Direction (income/expense/transfer) is now carried separately** by a vertical colored bar on the
  left edge of each transaction row (Success green / Danger red / Accent blue) — see the Transaction
  row component below. This keeps both signals available at once: the bar answers "money in or out,"
  the badge answers "what was it for."
- **Exception — Transaction Detail screen's header badge stays pure type-colored** (not
  ramp-colored), since that screen already shows one specific transaction in isolation; the category
  is named in text right below it, so the badge's job there is reinforcing direction at a glance,
  not distinguishing among many rows.

| Ramp   | Fill      | Background tint | Text      |
|--------|-----------|-----------------|-----------|
| Purple | `#8B7FD9` | `#EFEDFB`       | `#6C5FC0` |
| Teal   | `#2FA88C` | `#E3F5F0`       | `#237E68` |
| Coral  | `#E77A5D` | `#FBEEE8`       | `#C15F44` |
| Pink   | `#D96B95` | `#FBEBF1`       | `#B84E76` |
| Blue   | `#5B8FCC` | `#EAF1FA`       | `#3F6FA8` |
| Amber  | `#E0A63E` | `#FCF2E0`       | `#B3811F` |

---

## Typography

Two weights only: **400 (regular)** and **500 (medium/bold)**. Never heavier.

| Element                                             | Size    | Weight |
|-----------------------------------------------------|---------|--------|
| Large balance figure (net worth)                    | 28px    | 500    |
| Secondary balance figures (income/expense cards)    | 18px    | 500    |
| Section headers ("Accounts", "Recent transactions") | 14px    | 500    |
| Body / row text (account names, transaction names)  | 14px    | 400    |
| Small labels (badges, "Income"/"Expense" tags)      | 12-13px | 400    |
| Muted metadata (dates, timestamps)                  | 12px    | 400    |

All text: **sentence case** (never Title Case or ALL CAPS).

---

## Spacing & Layout

| Element                                        | Value                          |
|------------------------------------------------|--------------------------------|
| Outer card padding                             | 1.25rem (20px)                 |
| Gap between stat cards (income/expense grid)   | 12px                           |
| Gap between list rows (accounts, transactions) | 8px                            |
| Row internal padding                           | 10px vertical, 12px horizontal |
| Section spacing (between major blocks)         | 1.25rem (20px)                 |

## Corner Radius

| Element                        | Radius                           |
|--------------------------------|----------------------------------|
| Outer/main cards               | 16px                             |
| Inner rows, badges, stat tiles | 8px (`var(--radius)` equivalent) |
| Avatar/icon circles            | 50% (fully round)                |

## Borders

- Default hairline: 0.5px solid, light gray
- Used for card outlines and row dividers only — never a heavy 1px+ border

---

## Iconography

- **Icon set**: Tabler Icons, **outline style only** (not filled)
- Icon size: 16-20px inline (list rows, labels), up to 22px for nav bar icons
- Icons inherit text color from context — muted gray for inactive states, semantic color (green/red)
  inside success/danger badges
- Common icons used:
    - `wallet` — cash account
    - `building-bank` — bank account
    - `credit-card` — credit card account
    - `shopping-cart` — groceries/shopping category
    - `briefcase` — salary/income category
    - `home` / `list` / `chart-pie` / `settings` / `plus` — bottom nav

---

## Components

### Metric card (income/expense summary)

- Background: tinted role color (success/danger bg tint)
- Padding: 12px
- Label: 12px, role-colored text, icon prefix
- Value: 18px/500, role-colored text
- Layout: 2-column grid, 12px gap

### List row (accounts, transactions)

- Background: inner surface tone (light gray, distinct from card white)
- Padding: 10px vertical / 12px horizontal
- Layout: leading icon (18-20px) + label (left-aligned) + value (right-aligned, bold)
- Corner radius: 8px

### Transaction row (with icon avatar)

- **Vertical colored bar** on the left edge of the row (3px wide, full row height, rounded), colored
  by direction: Success green (income) / Danger red (expense) / Accent blue (transfer) — carries
  the "money in or out" signal
- 32px circular icon avatar, background/icon colored from the category's **ramp color** (
  deterministic per category — see Category color rule), not tinted by type — carries the "what was
  it for" signal
- Two-line text block: name (14px/400) + timestamp (12px, muted)
- Right-aligned amount, colored by direction (same Success/Danger/Accent as the bar), prefixed
  with +/-
- Bottom divider: 0.5px hairline (omit on last row in a group)

### Bottom navigation bar

- 5 items: Home, Transactions (list), Quick-add (center, elevated), Reports (chart-pie), Settings
- Inactive icons: muted gray, 22px
- Active icon: accent blue, 22px
- Center quick-add: 44px filled circle, primary fill color, white plus icon — visually elevated
  above the other 4 flat icons

### Toggle switch

- 38×22px pill track, 18px circular thumb
- Off: `--surface-2` track with a `--border-strong` outline, thumb muted gray, positioned left
- On: accent-filled track (`--fill-accent`), thumb white (`--on-accent`), positioned right
- Used for boolean settings only (e.g. "App lock," "Daily reminder") — never for navigation or
  selection, which use chevrons/checkmarks instead

---

## Screen Spec: Dashboard (v1 reference)

Top to bottom:

1. **Net worth block** — label (13px, muted) + large figure (28px/500)
2. **Income/Expense grid** — 2 metric cards side by side, role-tinted
3. **Accounts section** — header row with "see all" chevron, then up to 3 account rows (icon, name,
   balance; credit card balance shown in red/negative)
4. **Recent transactions section** — header row with "see all" chevron, then 2-3 transaction rows
   with icon avatar, name, date, amount
5. **Bottom navigation** — fixed, 5 icons as described above

This structure (metric summary → grouped list → grouped list → nav) is the pattern to reuse for
consistency: Accounts screen and Transactions screen should follow the same "header + row list"
visual grammar established here.

---

## Notes for Rebuilding in Figma

- Recreate the color roles as Figma **color styles** (Success/Danger/Accent/Neutral ×
  background-tint/text/border variants) so they can be reused across every screen and updated
  globally later
- Recreate spacing values as **Figma variables** (or at minimum, consistent auto-layout gap
  settings) rather than eyeballing pixel gaps per screen
- Tabler Icons has a community Figma plugin — search "Tabler Icons" in the Figma plugin browser to
  get matching outline icons rather than redrawing them
- Set up two text styles per size (400 and 500 weight) and reuse them everywhere — avoid introducing
  a third weight

---

## Screen Spec: Add Transaction

### Field order (deliberate choice)

**Account → Category → Date → Note.** Account is placed first, not Category, specifically so that
switching to Transfer mode doesn't reshuffle the form:

- **Expense/Income mode**: row 1 = Account, row 2 = Category, row 3 = Date
- **Transfer mode**: row 1 relabels to "From" (same account field), row 2 relabels to "To" (an
  account picker replacing Category, highlighted in accent color since it's the field unique to
  transfers), row 3 = Date

Only the *content and label* of rows 1-2 change between modes — their position never does. This
avoids a layout jump/reflow when the user taps between the Expense/Income/Transfer segmented
control, and mirrors the "from → to" mental model of a transfer.

### Layout, top to bottom

1. Top bar — close (X) left, title center, save (check) right
2. Segmented control — Expense / Income / Transfer (3-way toggle)
3. Large amount display — 36px/500, color-coded to match selected type (red for expense, green for
   income, neutral/accent for transfer)
4. Field rows (see ordering above): Account, Category/To-account, Date, Note
5. Custom numeric keypad (not system keyboard) — keeps the whole flow inside the app's visual
   language, avoids OS keyboard covering the screen

### Component: field row (tappable)

- Padding: 12px, background: inner surface tone, radius: `var(--radius)` (8px)
- Leading icon (18px, muted) + label (14px, muted) on the left
- Current value (14px, primary text) + chevron-right (16px, muted) on the right, when the row opens
  a picker
- **Transfer "To" row exception**: background tints to accent color, label and value both use accent
  text color, to visually flag it as the field that's different/required for this mode

### Component: custom numeric keypad

- Default state: 3-column grid, digits 0-9, decimal point, backspace
- Each key: inner surface background, 8px radius, ~14px vertical padding for a comfortable tap
  target
- No system keyboard — everything stays visually consistent with the app

### Component: calculator toggle

- A calculator icon sits next to the large amount display, muted gray by default
- Tapping it: (1) turns the icon accent-colored, (2) expands the keypad from 3 to 4 columns by
  adding an operator column (÷, ×, −, +, each accent-tinted to stand apart from digits), (3) reveals
  a small expression preview line (12px, muted) above the amount that live-updates as the user
  builds an expression (e.g. "12.50 + 8.30 + 4.20")
- Field rows compress slightly (12px → 10px padding) in this state to keep the full keypad visible
  without scrolling
- **No equals key** — the 4th column is fully occupied by the four operators (one per row), with no
  room left for "=". This is intentional, not an oversight: **the big amount figure is always
  live-resolved**, continuously reflecting the computed value of whatever's complete in the
  expression so far (a trailing operator with nothing after it is simply ignored until a number
  follows). There is no separate "confirm the calculation" step — the number on screen at any moment
  already is the amount.
- The user exits calculator mode by tapping the calculator icon again (returns to the plain 3-column
  keypad, expression preview disappears, the last resolved value is kept as the amount) — or simply
  by moving on to another field or hitting save directly, since the amount is already valid at every
  point, nothing blocks progressing without an explicit "done" action.
- Default state stays minimal (just a number pad) since most entries are a single value — the
  calculator is opt-in, not the default, to protect the fast path

### Component: receipts field

- Unified pattern across all states — a horizontal strip of 48px thumbnail tiles, always ending in a
  dashed "+" tile as the add affordance, whether zero, one, or several images are attached
- Empty state: strip contains only the "+" tile
- Attached state: each photo renders as an actual image thumbnail (not a generic icon) so multiple
  receipts remain visually distinguishable at a glance; each has a small circular X badge (top-right
  corner) to remove it individually
- The "+" tile always stays at the end of the strip, so "how do I add another" never requires a
  different action than "how do I add the first"
- Positioned as the last field, after Note

---

## Screen Spec: Picker Sheets (Account, Category, Date, Currency)

All four pickers use the same bottom-sheet grammar rather than pushing to a new page — keeps the
user anchored to the form underneath (Add Transaction for Account/Category/Date; Add/Edit Account or
Settings for Currency).

### Shared sheet structure

- Slides up from the bottom, rounded top corners only (20px), full width
- Drag handle: small pill (36×4px, `--border-strong`) centered at top
- Title (16px/500) below the handle
- Selected item is marked with accent-tinted background + a checkmark icon (not a chevron — chevrons
  imply further navigation, checkmarks imply "this is chosen")

### Account picker

- List of accounts: leading icon, name (14px), balance (12px, muted or danger-colored if negative)
- Selected account row: full accent tint background, accent-colored icon/text/checkmark
- "Add account" row below a divider at the bottom — lets the user create a new account without
  leaving the transaction flow

### Category picker

- Search field at top (categories can grow long over time; a searchable list scales better than a
  fixed icon grid)
- Single-column list: circular icon badge (32px) + name (14px)
- Selected category row: tinted background matching its semantic role (danger tint for expense
  categories, success tint for income categories), with checkmark
- "Add category" row below a divider at the bottom, same pattern as accounts
- Note: category list should filter to only show expense-type or income-type categories depending on
  which is selected on the Add Transaction segmented control

### Date picker

- Two quick-shortcut buttons at top: "Today" and "Yesterday" (most transactions are logged same-day
  or next-day, so this skips calendar navigation for the common case)
- Month navigation header (chevron-left, month/year label, chevron-right)
- 7-column calendar grid, weekday initials as column headers
- Selected date: filled accent circle (not just tinted background, since it's a single cell rather
  than a full-width row)

### Currency picker

- Search field at top — a full currency list runs to 150+ entries, same reasoning as the Category
  picker
- **"Common" section** pinned above the full list (USD, EUR, GBP) so the most-used currencies aren't
  buried in an alphabetical scroll — same selected-row treatment (accent tint + checkmark) as the
  rest of the list
- **"All currencies"** section below, alphabetized
- Each row: small circular symbol badge (28px — $, €, £, etc.), currency code (14px) + full name (
  12px, muted) — deliberately a symbol badge, not a flag icon, since flags map to countries and some
  currencies (like EUR) span many countries, which a flag would misrepresent
- No "Add currency" row — unlike Account/Category, this is a fixed reference list, not something the
  user creates entries for
- Used from: Add/Edit Account's Currency row, and Settings' Default currency row

---

## Screen Spec: Transactions List

### Default layout, top to bottom

1. Top bar — "Transactions" title, search icon, filter icon (top-right)
2. **Sticky filter chips row** — pill-shaped, horizontally scrollable: Date range / Account /
   Category. Stays pinned below the top bar while the list scrolls beneath it. Once scrolled (not at
   the very top), the row gains a hairline `border-bottom` (`--border-strong`) to visually separate
   fixed chrome from moving content
3. Transaction list, **grouped by date** ("Today," "Yesterday," "Aug 5," etc.)
4. Bottom navigation — same 5-icon bar, "Transactions" tab active (accent-colored)

### Component: date group header

- Group label (12px/500, muted) on the left
- Net subtotal for that day (12px, role-colored — green if net positive, red if net negative) on the
  right
- Rows below use the same transaction row component as the Dashboard (icon avatar, name, subtitle,
  amount)

### Component: filter chip

- Pill shape, 20px radius, 6px/12px padding, horizontally scrollable row
- Inactive: `--surface-1` background, muted text, chevron-down
- Active (a filter is applied): `--bg-accent` background, accent text/chevron — gives a persistent
  visual cue that filtering is in effect even after its picker sheet closes

### Interaction: search icon tapped

- Top bar transforms: title and both icons are replaced by a back arrow, an active text input, and a
  clear (X) icon
- Filter chips row disappears — search and filter are treated as separate modes, not combined
- A result count appears (e.g. "2 results") above the list
- Matched substrings within transaction names are highlighted in accent color

### Interaction: filter icon tapped (combined filter sheet)

- Opens one bottom sheet covering **all filter dimensions at once**: Date range, Type (
  Expense/Income segmented), Accounts (multi-select chips), Categories (multi-select chips)
- Each section is adjustable before a single "Apply filters" button commits everything together
- This is distinct from tapping an individual chip, which jumps directly to just that one filter's
  picker

### Interaction: date chip tapped → date range picker

- Adapts the Add Transaction date picker into a *range* variant:
- Preset shortcuts are period-based ("This month," "Last month," "Last 7 days," "Last 30 days")
  rather than "Today"/"Yesterday"
- Calendar shows a connected range: start and end dates as filled accent circles, days between them
  as a tinted connecting band
- "Apply" button confirms the range

### Interaction: account chip tapped → account multi-select

- Same list structure as the Add Transaction account picker, but rows use **checkboxes instead of a
  single checkmark**, since multiple accounts can be selected for filtering at once
- No "Add account" row — creating a new account doesn't belong in a filter context
- "Apply" button confirms the selection
- Category chip follows this identical checkbox pattern, substituting category items for accounts

---

## Screen Spec: Transaction Detail & Edit Transaction

Reached by tapping a row on the Transactions list (or the Dashboard's recent transactions preview).
Two separate screens, not one:

- **Transaction Detail** — read-only, what you land on first. Safer than jumping straight into an
  editable form on tap (no risk of accidentally nudging a value while just glancing at a
  transaction), and gives receipts a proper view-only mode.
- **Edit Transaction** — reached via the pencil icon on Detail. This is the *same* Add Transaction
  screen and form already specified above, just pre-filled with the transaction's existing values
  and its top-bar title changed to "Edit transaction." No new design needed for this screen.

**Transactions cannot be archived.** Unlike Accounts and Categories, nothing else in the schema
references a transaction, so there's no "keep it around so other records stay valid" reason to
soft-delete one. Deletion is a hard delete only, behind the confirmation dialog specified in the
business rules doc.

### Layout, top to bottom

1. Top bar — back arrow (left); edit (pencil) and delete (trash, danger-colored) icons (right)
2. **Header block**, centered: circular icon badge (48px, tinted to type — Success green / Danger
   red / Accent blue), large amount (32px/500, **no +/− sign** — color alone carries the direction,
   consistent with removing signs everywhere else redundant with color), category name below (or "
   Transfer" for transfer-type transactions, which have no category)
3. Field rows: Account (or From/To for transfers), Date, Note
4. Receipts section

### Amount and type color (no sign)

| Type     | Icon badge / amount color                                     | Label under amount |
|----------|---------------------------------------------------------------|--------------------|
| Expense  | Danger red                                                    | Category name      |
| Income   | Success green                                                 | Category name      |
| Transfer | Accent blue, generic `arrow-right` icon (not a category icon) | "Transfer"         |

### Transfer variant

- No category icon/name — the header badge is a neutral accent-colored transfer arrow, label reads "
  Transfer"
- The Account row splits into **From** and **To** rows, mirroring the exact relabeling logic from
  the Add Transaction form
- Everything else (Date, Note, Receipts) stays the same as Expense/Income

### Component: Note and Receipts rows (always shown, never hidden)

Both rows render unconditionally, even when empty — showing a muted italic placeholder rather than
omitting the section entirely. This keeps the screen reading as complete and intentional rather than
sparse or unfinished:

- Note row, empty: `No note added` (muted, italic) in place of the value
- Receipts section, empty: a muted italic `No receipts attached` line instead of the thumbnail strip

### Component: Receipts (view-only)

- When receipts exist, shown as a horizontal strip of thumbnails (same 48-52px tile size as the Add
  Transaction form) — **no "+" tile**, since this isn't an editing context
- Tapping a thumbnail opens it full-screen for review (with swipe between multiple, if more than one
  is attached)

---

### Navigation note

Accounts is not a bottom-nav tab — it's pushed from the Dashboard's "Accounts" section (which only
previews up to 3). This screen therefore uses a **back arrow** in the top bar instead of the bottom
nav.

### Layout, top to bottom

1. Top bar — back arrow + "Accounts" title (left), "+" add icon (right)
2. **Net worth card** — reuses the Dashboard's net worth block styling (label + large figure),
   giving visual continuity between the two screens
3. Full list of active accounts — each row: icon, name, type subtitle (e.g. "Bank account"),
   balance (red if negative, e.g. credit card debt), chevron-right (pushes into Account Detail)
4. **Archived section** — collapsed by default, header shows "Archived (n)" with a chevron-down

### Interaction: archived section tapped

- Expands **inline** (accordion), not a navigation — this is a low-frequency, low-stakes action that
  doesn't need its own screen
- Chevron flips from down to up
- Each archived row: muted/desaturated icon and text (60% opacity), balance shown but muted, and a *
  *"Restore" text action** (accent-colored) in place of the chevron — a chevron implies "go deeper,"
  which isn't the action here
- **Archived accounts are excluded from the net worth total** — matches the intent of archiving (no
  longer active), so restoring one will change the net worth figure

---

## Screen Spec: Accounts List

### Navigation note

Accounts is not a bottom-nav tab — it's pushed from the Dashboard's "Accounts" section (which only
previews up to 3). This screen therefore uses a **back arrow** in the top bar instead of the bottom
nav.

### Layout, top to bottom

1. Top bar — back arrow + "Accounts" title (left), "+" add icon (right)
2. **Net worth card** — reuses the Dashboard's net worth block styling (label + large figure),
   giving visual continuity between the two screens. A small muted note sits below the figure: "Raw
   sum across currencies — no conversion applied" — flags the known v1 limitation right where
   someone would first notice USD and EUR balances being added together, rather than leaving it
   silently confusing.
3. Full list of active accounts — each row: icon, name, **type subtitle plus currency code** (e.g. "
   Bank account · USD"), balance (formatted using the account's actual currency symbol — never a
   hardcoded `$` — and colored red if negative, e.g. credit card debt), chevron-right (pushes into
   Account Detail)
4. **Archived section** — collapsed by default, header shows "Archived (n)" with a chevron-down

### Interaction: archived section tapped

- Expands **inline** (accordion), not a navigation — this is a low-frequency, low-stakes action that
  doesn't need its own screen
- Chevron flips from down to up
- Each archived row: muted/desaturated icon and text (60% opacity), balance shown but muted, and a *
  *"Restore" text action** (accent-colored) in place of the chevron — a chevron implies "go deeper,"
  which isn't the action here
- **Archived accounts are excluded from the net worth total** — matches the intent of archiving (no
  longer active), so restoring one will change the net worth figure

---

## Screen Spec: Add / Edit Account

Full-screen modal, same X/check top-bar pattern as Add Transaction.

### Fields, top to bottom

1. **Name** — plain text input
2. **Type** — 2×2 grid (Cash / Bank / Credit card / Savings), selected option accent-tinted
3. **Currency** — tappable row (reuses the Add Transaction field-row style), opens a simple currency
   picker
4. **Balance** — numeric input. Labeled just "Balance" (not "Starting balance") and *
   *entered/displayed using the same sign convention as everywhere else in the app**: negative for
   money owed (e.g. a credit card shows `-200.00`, in red text, matching how it appears on the
   Accounts list and Dashboard). A small muted hint line clarifies this once: "Negative means money
   owed — matches how it's shown across the app."
5. **Icon and color** — horizontal row of circular swatches (40px), selected swatch gets an accent
   border ring; last swatch is a dashed "+" to add a custom one

### Edit-mode addition

- All fields pre-filled with the account's current values
- **"Archive account"** action at the very bottom, below a divider — muted gray icon and text (not
  red/destructive styling), since archiving is reversible and low-stakes, unlike a hard delete

---

## Screen Spec: Categories Management

### How this differs from Accounts (same shell, different specifics)

- **No summary card at top** — there's no aggregate figure equivalent to net worth for categories,
  so the screen starts straight into the list
- **Split into Income and Expense sections** with colored headers (green/red, matching semantic
  roles), rather than one flat list — category type is the primary way people scan this list
- **Drag-to-reorder** — each row has a grip handle; dragging reorders within its own section only (a
  category can't be dragged across the Income/Expense boundary, since that would silently change its
  type). Order matters more here than for Accounts because category order affects how fast someone
  finds the right one in the category picker while logging a transaction
- **Rows have no chevron** — tapping the row body opens Edit Category directly; there's no deeper
  drill-down screen the way Account rows push to Account Detail

### Layout, top to bottom

1. Top bar — back arrow + "Categories" title (left), "+" add icon (right)
2. **Income** section header (green), list of income category rows
3. **Expense** section header (red), list of expense category rows
4. **Archived** section — same collapsed accordion, muted rows, "Restore" action pattern as Accounts

### Component: category row

- Grip-vertical icon (drag handle, muted) on the left
- Circular icon badge (30px, tinted to role color) + name (14px)
- No trailing chevron or value — tap anywhere on the row (outside the grip) to edit

### Add/Edit Category modal

Same X/check full-screen modal pattern as Add/Edit Account, but notably shorter:

1. **Name** — plain text input
2. **Type** — simple 2-way Expense/Income toggle (not a 2×2 grid — only two options here)
3. **Icon** — horizontal swatch strip, but unlike Accounts this is icon choice only — every swatch
   is pre-tinted to the category's selected type (Success green if Income is toggled, Danger red if
   Expense is toggled), since color is always derived from type, never chosen independently.
   Switching the type toggle re-tints all the swatches live.
4. No currency, no balance field — categories don't carry either

Edit mode adds **"Archive category"** at the bottom, below a divider, in the same muted (
non-destructive-looking) styling as "Archive account" — archiving is reversible, so it never gets
alarming red treatment.

---

## Screen Spec: Account Detail

Pushed from tapping an account row on the Accounts list. Built almost entirely from components
already established elsewhere — no new visual patterns introduced.

### Layout, top to bottom

1. Top bar — back arrow + account name as title (left), edit (pencil) icon (right) → opens Edit
   Account pre-filled
2. **Balance block** — same styling as the net worth card, scoped to this one account; small type
   subtitle with icon above the balance, now including currency code (e.g. "Bank account · USD");
   balance formatted with the account's actual currency symbol, same as the Accounts List row
3. **This month income/expense grid** — identical 2-column metric card component from the Dashboard,
   just filtered to this account's transactions
4. **Transactions** section header with a "See all" link (accent-colored) that pushes to the full
   Transactions screen with this account pre-applied as a filter chip
5. Transaction list below, grouped by date — same row and date-group components as the Transactions
   list screen

No charts on this screen — trend visualization is reserved for the Reports screen to avoid
duplicating that responsibility across multiple places.

---

## Screen Spec: Reports

### Layout, top to bottom

1. Top bar — "Reports" title (not pushed with a back arrow — accessible via the bottom nav's
   chart-pie tab)
2. **Filter chips row** — "Last 6 months" / "All accounts," same pill-chip component as the
   Transactions screen, so the underlying filter interaction and likely the Cubit query logic can be
   shared between the two screens
3. **Income vs expense** card — paired bar chart, one bar pair per month
4. **By category** card — donut chart with legend, toggle between Expense/Income
5. **Balance trend** card — line chart

Each chart lives in its own section, separated by hairline dividers, all within a single scrollable
screen rather than tabs — this is a read-only overview for v1, so there's no need to hide any of the
three behind navigation.

### Component: income vs expense bar chart

- Small paired bars per month: income (success green) and expense (danger red) side by side, both
  anchored to the same baseline
- Same semantic colors used everywhere else in the app — no new color meaning introduced for this
  chart
- Current/selected month's x-axis label is accent-colored to distinguish it from the trailing months
- A 2-item legend (color swatch + label) sits below the chart
- **Scale reference (revised)**: small muted value labels (10px, `text.muted`) sit at the top-left
  and bottom-left corners of the chart area, showing `$0` and the chart's current max value — always
  visible, giving an immediate sense of scale without a full gridline grid
- **Tap for exact value**: tapping any bar highlights it (border ring in `text.primary`) and shows a
  small floating tooltip with its exact amount above it; the bar's x-axis month label also turns
  accent-colored while selected

### Component: category breakdown donut ("By category")

- Card title is "By category" (not "Spending by category") since it now covers both directions, not
  just expenses
- **Segmented toggle** (Expense / Income) sits below the title, above the donut — reuses the same
  2-way segmented control pattern used elsewhere in the app (Add Transaction's type selector,
  Category's type toggle). Defaults to Expense.
- Switching the toggle swaps the donut's segments, center total figure, and legend to match the
  selected direction — mixing income and expense percentages in one donut was rejected, since
  they're opposite directions and don't meaningfully share a "whole" to divide into percentages
- Donut (not full pie) so the total figure can sit in the hollow center — reads as a single
  glanceable number even before parsing the segments
- Segment colors pull from the category color rotation defined in the Color Palette section (coral,
  teal, amber, purple, etc.) — the same colors a category's icon badge already uses elsewhere (
  transaction rows, Categories Management), so a segment and its real-world category stay visually
  linked regardless of which screen you're looking at
- Legend sits beside the donut (not below), one row per category: color swatch, name, percentage
- Holds up fine even with sparse data — an Income donut with just 2 categories (e.g. Salary 84%,
  Freelance 16%) still reads cleanly, so the toggle approach doesn't look broken for the common case
  of very few income categories

### Component: balance trend line

- Line and end-point dot in accent color, no gridlines — the chart's primary job is still showing
  direction/shape, not a precise reading at every point
- **Scale reference (revised)**: the first and last x-axis labels now include their actual value
  alongside the month (e.g. "Mar · $5,350" … "Aug · $11,389") instead of just the month name — gives
  real start/end scale context with no additional visual elements added to the chart itself
- **Tap for exact value**: tapping anywhere along the line shows a small floating tooltip with the
  exact balance at that point

### Resolved: chart scale reference & interactivity

Both charts above use the same **hybrid** approach — a lightweight always-visible scale hint (
min/max labels) paired with tap-to-reveal precision (tooltip on touch) — rather than either a full
static gridline system (too much visual weight for the flat/minimal aesthetic) or interactivity
alone (first glance would give no scale hint at all). This resolves the earlier open question about
whether these charts needed any reference values; they do, and this is the lightest-weight way to
provide them without abandoning the minimal chart style.

### Open question (still deferred)

Whether tapping into a chart should **navigate**, not just show a tooltip — for instance tapping a
category slice on the donut jumping to the Transactions screen pre-filtered to that category — or
whether Reports stays purely read-only/in-place for v1. This is separate from the tap-for-tooltip
behavior resolved above (which just reveals a value in place, no navigation) and is still not yet
decided.

---

## Screen Spec: Settings

### Navigation note

Unlike Accounts/Categories (pushed screens with a back arrow), Settings **is** a bottom-nav tab — no
back arrow, top bar is just the "Settings" title. Active tab icon is accent-colored in the bottom
nav, same convention as Transactions/Reports.

### Layout — grouped sections

Rather than one flat list, settings are grouped under section headers (12px/500, muted), each group
in its own set of rows:

1. **General** — Default currency (row, opens a picker, current value shown muted before the
   chevron), Appearance (row, opens Light/Dark/System picker)
2. **Manage** — Categories (row, pushes to Categories Management), Accounts (row, pushes to Accounts
   List) — a secondary entry point into screens already reachable elsewhere (Categories via the
   picker's "Add category," Accounts via the Dashboard), giving the user more than one path to the
   same destination, which is a normal and expected pattern
3. **Security** — App lock (row with a toggle switch, not a chevron — this is a boolean, not a
   navigation)
4. **Notifications** — Daily reminder (row with a toggle switch)
5. **Data** — Export data (row, chevron)
6. **About** — Version (row, static value, no chevron — not tappable), Send feedback (row, chevron)

### Component: settings row

- Two variants depending on what the row does:
    - **Navigation row**: icon + label (left), current value in muted text + chevron-right (right) —
      for rows that open a picker or push to another screen
    - **Toggle row**: icon + label (left), toggle switch (right) — for boolean settings, no chevron
- Both variants share the same background/padding/radius as every other list row in the app (
  `--surface-1`, 12px padding, `var(--radius)`)

---

## Screens Still To Design

None — all v1 screens have been designed. Multi-currency and Budgets remain deferred to v2, per the
app spec doc.




