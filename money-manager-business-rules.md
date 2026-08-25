# Money Manager App — Business Rules & Validation

> **Companion document**: architecture and data model live in `money-manager-app-spec.md`; visual/UI
> design lives in `money-manager-design-system.md`. This document covers validation rules,
> constraints, and edge-case behavior that an implementation needs to enforce but that aren't purely
> visual or purely structural.

---

## Transactions

### Amount

- Must be greater than 0 — zero-amount transactions are not allowed
- No maximum value
- Exactly 2 decimal places (standard currency precision), rounded using standard rounding
- Always stored as a positive value; `type` is the sign source of truth (see app spec doc)

### Account

- Always required

### Category

- Required for Income and Expense transactions
- Must be `null` for Transfer transactions
- A category's `type` must match the transaction's `type` — an Expense transaction cannot point to
  an Income-type category, and vice versa. Enforced at the repository layer, since the DB schema
  can't express this as a `CHECK` constraint against a Dart enum.
- **Changing a transaction's type while editing** (e.g. Expense → Transfer): the type switch itself
  is **blocked** while a type-specific field (Category, or the To-account) already has a value
  selected. The user must manually clear that field first — the app does not auto-clear it on their
  behalf.

### Transfer

- `toAccountId` is required
- `toAccountId` must differ from `accountId` — an account cannot transfer to itself
- Cross-currency transfers between accounts with different currencies are **allowed**. The amount
  moves as-is with no conversion applied (consistent with no multi-currency support in v1). A small
  warning/confirmation is shown before completing the transfer, since moving "$500" from a USD
  account into a EUR account as if it were the same 500 units is easy to do by accident.

### Date

- **No future dates allowed** — a transaction's date must be today or earlier
- This is a v1-only restriction. It will need revisiting once recurring transactions (v2) are
  introduced, since generating forward-dated entries will require relaxing this rule at that time.

### Note

- Optional
- Maximum 150 characters

### Receipts

- Optional
- Maximum 5 images per transaction

### Deleting a transaction

- Hard delete (no soft-delete/undo) — Transactions are the one entity in the schema without an
  `isArchived` flag, unlike Accounts and Categories
- Requires a confirmation dialog before deleting, since there's no undo
- A Transfer is stored as a single row (`accountId` + `toAccountId`), so deleting it removes both
  sides of the movement atomically — no special dual-delete logic needed

### Editing an existing transaction that references an archived account or category

- Still displays normally — archived only means "hidden from pickers when creating something *new*,"
  not "invalid in historical data." The account/category name and icon still render as they did.

---

## Accounts

### Name

- Required, cannot be empty or whitespace-only after trimming
- Must be unique, **case-insensitive** ("Cash" and "cash" cannot coexist)

### Balance

- Can go negative for any account type (real-world overdrafts, or a credit card's existing debt at
  creation time) — no floor restriction

### Currency

- Free to choose at creation
- **Locked once the account has at least one transaction** — since there's no currency conversion in
  v1, changing currency after transactions exist would silently misrepresent historical data

### Type (Cash / Bank / Credit card / Savings)

- Not locked after use — unlike currency, changing an account's type doesn't corrupt any stored
  transaction data. It only affects how the account's balance is treated in net worth math (credit
  card subtracts, others add) going forward.

### Minimum account requirement

- The app must always have **at least one active (non-archived) account**
- Archiving the last remaining active account is blocked

---

## Categories

### Name

- Required, cannot be empty or whitespace-only after trimming

### Type (Income / Expense)

- **Locked once the category has at least one transaction** — same reasoning as account currency:
  changing type after use would make existing transactions mismatched (an expense transaction
  suddenly pointing to an "income" category)

### Color

- Not stored — always derived from `type` at render time (Success green for Income, Danger red for
  Expense). See design system doc's Color Palette section.

### Icon

- If no icon is explicitly selected, fall back to a generic default icon (e.g. a plain tag/circle)
  rather than allowing a null/broken icon state

### Reordering

- Manual drag-to-reorder is scoped within a category's own type — an Income category can't be
  dragged into the Expense group (that would silently change its type)

---

## Filters (Transactions & Reports screens)

### Combination logic

- All active filter dimensions combine with **AND** logic — e.g. a date range + an account filter +
  a category filter shows only transactions matching all three simultaneously, not any one of them

### Archived items in filter pickers

- Archived accounts and categories still appear in filter option lists (visually marked as
  archived), since historical transactions may reference them. Excluding them would make old
  transactions unreachable via filtering.

### "This month" / period definitions

- "This month" means the **calendar month** (1st through the last day), not a rolling 30-day window

### Reports category-breakdown percentages

- Rounding uses the **largest-remainder method**, so displayed percentages always sum to exactly
  100% rather than drifting to 99% or 101%. (Round every percentage down first, then distribute the
  leftover percentage points to whichever categories had the largest fractional remainder — the same
  technique used for seat apportionment in elections. Simple independent rounding was considered but
  rejected since it can visibly fail to sum to 100%, which looks like a bug to anyone mentally
  adding up the legend.)

---

## Onboarding / First Launch

- A brand-new install has zero accounts, but every transaction requires one
- The app must force an "add your first account" step before the Dashboard or Add Transaction flow
  becomes usable
