# Money Manager App — Feature & Structure Documentation

## Overview

A mobile money manager app (iOS/Android) built with **Flutter**, using **manual transaction entry
** (no bank sync) for a **single user**, supporting **multiple accounts** from day one.

> **Companion document**: visual/UI design (colors, typography, components, and full
> screen-by-screen specs) lives separately in `money-manager-design-system.md`. This document covers
> architecture, data, and feature scope; the design doc covers how it looks and behaves on screen.

---

## Tech Stack

| Layer            | Choice                                 |
|------------------|----------------------------------------|
| Framework        | Flutter                                |
| Local database   | **Drift**                              |
| Charts           | fl_chart                               |
| State management | **Cubit** (part of the `bloc` package) |
| Security         | local_auth (biometric lock)            |

### Why Drift

- Type-safe queries in Dart, checked at compile time — important given the relational schema (
  accounts, categories, transactions, transfers referencing two accounts, budgets)
- Auto-generates data classes from schema, no manual SQL-to-Dart mapping
- Built-in reactive streams — a query can auto-update the UI when underlying data changes, useful
  for a dashboard/reports screen that reflects new transactions instantly
- More structured migrations (versioned schema, generated migration helpers) vs. sqflite's manual
  approach

### Why Cubit (over full Bloc)

- Much less boilerplate than Bloc — methods emit states directly, no separate Event classes or
  `on<Event>()` mapping, which keeps a solo-maintained codebase quicker to write and read
- Still part of the `bloc` package, so it shares the same `Loading` / `Success` / `Error`
  state-class pattern that maps naturally onto animated UI states (e.g., spinner → animated success
  checkmark on save)
- Full Bloc's event transformers (`droppable()`, `restartable()`, `sequential()`) aren't included in
  Cubit, but the two cases where they'd normally help — debouncing the transaction search field, and
  guarding the Add/Edit Transaction form against double-submit — can be handled manually inside a
  Cubit method (a `Timer` for debounce, a simple boolean guard for double-submit), so Cubit alone
  comfortably covers every screen in this app

### How they fit together

Drift exposes reactive streams (e.g., "all transactions for this month," "category totals for the
pie chart"). Each relevant Cubit subscribes to the corresponding Drift stream (via a
`StreamSubscription` set up in the Cubit's constructor, emitting a new state on each event) so
screens like the Dashboard and Reports rebuild automatically without manual refresh logic.

---

## Database Schema (Drift)

### Design decisions

- **Amount sign convention**: `amount` is always stored as a positive value; `type` (
  income/expense/transfer) is the source of truth for direction. Keeps aggregation queries (e.g.,
  category sums for the pie chart) simple, no conditional sign-flipping.
- **Soft delete for Accounts & Categories**: deleting either sets `isArchived = true` instead of
  removing the row. Archived items are hidden from pickers (Add Transaction, active Categories list)
  but remain fully joinable so historical transactions and reports stay intact. The UI should offer
  an "Archived" view to restore them.
- **Transfers**: a transaction with `type = transfer` uses `toAccountId` (moving money from
  `accountId` to `toAccountId`) and leaves `categoryId` null. Transfers are excluded from
  income/expense totals so they don't distort monthly reports.
- **Validation note**: SQLite `CHECK` constraints can't easily reference Dart enums, so the rule "
  transfers require `toAccountId`, income/expense require `categoryId`" is enforced in the
  repository/Cubit layer before insert, not in the DB schema itself.
- **Currency**: kept simple for v1 — one currency per `Account`, no per-transaction currency or
  conversion. All transactions on an account are assumed to be in that account's currency.
- **AccountType**: kept specifically for correct net worth math, not for icon/UI purposes (
  icon/color are freely chosen per account, independent of type). A `creditCard` account represents
  debt, so its balance should **subtract** from total net worth, while `cash` / `bank` / `savings`
  balances **add**. This is the one piece of logic that reads `type` — everything else about an
  account is user-customized.
- **Category ordering**: categories support manual drag-to-reorder in the UI (Accounts do not), so
  `Categories` needs a `sortOrder` integer column. Reordering is scoped within a category's own
  type (income categories only reorder among themselves, same for expense) — enforced at the
  repository/Cubit layer, not the schema.
- **Category color is derived, not stored**: a category's badge color is always determined by its
  `type` (Success green for income, Danger red for expense) — see the design system doc's Color
  Palette section for the resolution of this. No `color` column on `Categories`. The one place
  multiple categories need visually distinct colors (the Reports category-breakdown chart) assigns
  colors from a rotating ramp programmatically at render time, not from stored data.

### Tables

```dart
import 'package:drift/drift.dart';

enum AccountType { cash, bank, creditCard, savings }
enum CategoryType { income, expense }
enum TransactionType { income, expense, transfer }

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get type => intEnum<AccountType>()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  RealColumn get startingBalance => real().withDefault(const Constant(0))();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get type => intEnum<CategoryType>()();
  TextColumn get icon => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get type => intEnum<TransactionType>()();
  RealColumn get amount => real()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  IntColumn get toAccountId => integer().nullable().references(Accounts, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get receiptPhotoPath => text().nullable()();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  DateTimeColumn get month => dateTime()(); // stored as first-of-month
  RealColumn get limitAmount => real()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {categoryId, month}
  ];
}

@DriftDatabase(tables: [Accounts, Categories, Transactions, Budgets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}
```

### Schema summary

| Table        | Key columns                                                        | Notes                                                                                 |
|--------------|--------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| Accounts     | id, name, type, currency, startingBalance, isArchived              | soft-deletable                                                                        |
| Categories   | id, name, type (income/expense), isArchived, sortOrder             | soft-deletable, manually reorderable within type; color derived from type, not stored |
| Transactions | id, accountId, type, amount, categoryId?, toAccountId?, date, note | categoryId used for income/expense, toAccountId for transfers                         |
| Budgets      | id, categoryId, month, limitAmount                                 | unique per (categoryId, month)                                                        |

---

## Screens (v1)

> Full visual specs, layouts, and component details for each of these live in
`money-manager-design-system.md`.

1. **Dashboard** — net worth, this month's income/expense, accounts preview (top 3), recent
   transactions preview, quick-add access, bottom nav
2. **Add/Edit Transaction** — amount (with calculator toggle), account, category, date, note,
   receipts; Expense/Income/Transfer modes
    - Sub-screens: **Account picker**, **Category picker**, **Date picker** (bottom sheets)
3. **Transactions** — full history grouped by date, sticky filter chips (date/account/category),
   search, combined filter sheet
    - Sub-screens: **Date range picker**, **Account/Category multi-select filters**
4. **Accounts** — full account list, net worth card, archived accounts (collapsible, excluded from
   net worth)
    - Sub-screens: **Add/Edit Account**, **Account Detail** (per-account balance, this month's
      income/expense, filtered transaction history)
5. **Reports/Graphs** — income vs. expense (bar), spending by category (donut), balance trend (
   line); filter chips shared with Transactions screen (month/account)
6. **Categories Management** — income/expense sections, drag-to-reorder, archived (collapsible)
    - Sub-screen: **Add/Edit Category** (name, type toggle, icon/color — shorter form than accounts,
      no currency/balance)
7. **Settings** — grouped sections: General (currency, appearance), Manage (Categories, Accounts —
   secondary entry points), Security (app lock), Notifications (daily reminder), Data (export),
   About (version, feedback). Bottom-nav tab, not a pushed screen.

---

## Features by Release

### v1 — MVP

- Quick add transaction (amount, type, category, date, note) — target <10s to log
- Preset + custom categories with icons/colors
- Multiple accounts (cash, bank, card, savings)
- Dashboard with balances and quick-add
- Transaction list with filters
- Core graphs:
    - Income vs. expense (bar chart, monthly, swipeable across months)
    - Spending by category (pie/donut chart)
    - Balance trend over time (line chart)

### v2 — Budgeting & Habits

- Monthly budgets per category with progress bars and near-limit alerts
- Recurring transaction templates (rent, subscriptions, salary)
- Savings goals with progress tracking
- Calendar heatmap of spending days

### v3 — Polish & Retention

- Home screen widget (balance + quick add)
- Notification reminders to log expenses
- Receipt photo attachment (storage only, no OCR)
- CSV export for backup/analysis
- Biometric lock (Face ID / fingerprint)
- Dark mode

---

## Deferred / Under Consideration

- Automatic bank sync (explicitly out of scope for now — manual entry only)
- Multi-user/family sharing (explicitly out of scope — single user)
- AI-based spending insights
- Debt payoff tracker
- Receipt OCR (auto-fill from photo)

---

## Default Categories (seed data)

Seeded on first launch. Icons are Tabler icon names (outline style, per the design system doc);
color is not stored — always derived from `type` at render time (see Database Schema decisions
above). `sortOrder` follows the order listed here.

### Expense

| Name           | Icon              |
|----------------|-------------------|
| Groceries      | `shopping-cart`   |
| Rent & housing | `home`            |
| Utilities      | `bolt`            |
| Transport      | `car`             |
| Dining out     | `tools-kitchen-2` |
| Entertainment  | `movie`           |
| Health         | `heartbeat`       |
| Shopping       | `shopping-bag`    |
| Subscriptions  | `repeat`          |
| Travel         | `plane`           |
| Education      | `book`            |
| Other          | `dots`            |

### Income

| Name         | Icon          |
|--------------|---------------|
| Salary       | `briefcase`   |
| Freelance    | `laptop`      |
| Gifts        | `gift`        |
| Investments  | `trending-up` |
| Other income | `dots`        |

---
