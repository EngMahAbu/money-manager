# Money Manager App — Implementation Roadmap

> **Companion documents**: `money-manager-app-spec.md` (architecture/data),
`money-manager-design-system.md` (visual/UI), `money-manager-business-rules.md` (validation/edge
> cases). This document sequences the actual build into ordered, agent-sized tasks.

## How to use this doc

Each task is scoped to be small enough for a single agent session to complete and review (roughly
one PR's worth of work). Tasks within a milestone can sometimes be parallelized; milestones are
meant to be done in order, since later ones depend on earlier ones. Each task lists which companion
doc(s) it should be implemented against.

---

## Milestone 0 — Project setup

- [ ] **0.1 — Initialize Flutter project.** Target **Flutter 3.x.x / Dart 3.x.x** (current stable as
  of this writing — confirm latest patch at actual setup time). `flutter create` with iOS/Android
  platforms only (no web/desktop). Set up `analysis_options.yaml` using **`flutter_lints`** (the
  standard set).
- [ ] **0.2 — Add dependencies.** `drift` + `drift_dev` + `sqlite3_flutter_libs`, `flutter_bloc` (
  for Cubit), `fl_chart`, `image_picker`, `local_auth`, `path_provider`, `intl`, an icon package
  matching Tabler Icons. Resolve to latest-compatible versions at setup time rather than hardcoding
  version numbers now, since they'll be stale by the time this is actually run.
    - [ ] **0.3 — Folder structure (feature-first).**
      ```
      lib/
        core/
          ui/
            theme/             (ThemeData)
            widgets/           (cross-feature components: transaction row, toggle switch, metric card, bottom nav)
          constants/
        config/                (AppColors, AppStyles, AppDimens)
        features/
          [feature]/
            data/
              data_sources/
              models/
              repositories/
            domain/
              use_cases/
              entities/
              repositories/
            presentation/
              view/
                widgets/       (optional for view-specific components)
                view_model/    (Cubits)
          transactions/
          accounts/
          categories/
          reports/
          settings/
        shared/
          data/                (Drift tables, DAOs — stays flat, genuinely cross-cutting)
          repositories/        (stays flat — consumed by multiple features' cubits)
      ```
      Each feature owns its own screen-specific widgets (e.g. Transactions' picker sheets live
      inside `features/transactions/widgets/`, not in the shared folder) — only things used by 2+
      features belong in `shared/`.
- [ ] **0.4 — Git setup.** Trunk-based workflow on `main`, short-lived branches per task where
  useful (e.g. `0.1-init-project`), no long-lived feature branches. **Conventional commits** (
  `feat:`, `fix:`, `chore:`, `refactor:`). `.gitignore` covers standard Flutter ignores (`build/`,
  `.dart_tool/`) plus Drift's generated files (`*.g.dart`) — these are regenerated via
  `dart run build_runner build`, not hand-written or committed. Every fresh session needs to run
  that command once before the project compiles.

**Done when**: `flutter run` launches an empty scaffolded app with no errors.

---

## Milestone 1 — Data layer (Drift)

*Reference: `money-manager-app-spec.md` § Database Schema*

- [ ] **1.1 — Define tables.** `Accounts`, `Categories`, `Transactions`, `Budgets` exactly as
  specified (including `sortOrder` on Categories, no `color` column on Categories).
- [ ] **1.2 — Define enums.** `AccountType`, `CategoryType`, `TransactionType`.
- [ ] **1.3 — Wire up `AppDatabase`.** Connection setup, `schemaVersion`.
- [ ] **1.4 — Seed data migration.** On first launch, insert the finalized default categories (see
  app spec doc § Default Categories) with correct `sortOrder`.
- [ ] **1.5 — Write DAOs / queries.** At minimum: CRUD for each table, reactive streams for "all
  active accounts," "all active categories by type," "transactions in date range," "account
  balance," "net worth."

**Done when**: unit tests can insert/query/stream from every table, seed categories appear on a
fresh DB.

---

## Milestone 2 — Repository layer

*Reference: `money-manager-business-rules.md` (this is where most rules get enforced)*

- [ ] **2.1 — `AccountRepository`.** Enforce: unique case-insensitive name, non-empty name, currency
  lock after first transaction, block archiving the last active account.
- [ ] **2.2 — `CategoryRepository`.** Enforce: non-empty name, type lock after first transaction
  use, reorder scoped within type.
- [ ] **2.3 — `TransactionRepository`.** Enforce: amount > 0 with 2 decimal places, category
  required/null per type, category type must match transaction type, transfer `toAccountId` required
  and ≠ `accountId`, no future dates, note ≤ 150 chars, ≤ 5 receipts.
- [ ] **2.4 — Balance/net worth calculation logic.** Per-account balance = starting balance + all
  transactions affecting it. Net worth = sum of active (non-archived) account balances, with credit
  card balances subtracting rather than adding (per `AccountType`).
- [ ] **2.5 — Repository-level tests.** One test per validation rule above — this is the
  highest-value test coverage in the app, since it's where money-correctness bugs would live.

**Done when**: every rule in the business rules doc has a corresponding enforced check and a passing
test.

---

## Milestone 3 — Theme & shared components

*Reference: `money-manager-design-system.md` § Color Palette, Typography, Components*

- [ ] **3.1 — Design tokens.** `AppColors` (exact hex values from the design doc), `AppTextStyles`,
  spacing constants, corner radius constants.
- [ ] **3.2 — `ThemeData`.** Wire tokens into a Flutter theme.
- [ ] **3.3 — Shared widgets.** Metric card, list row (generic), transaction row (with icon avatar),
  bottom nav bar, toggle switch, filter chip, section header — every component documented in the
  design doc's Components section, built once and reused everywhere.

**Done when**: a throwaway "component gallery" screen can render every shared widget from
token-driven styles, no screen-specific one-off styling.

---

## Milestone 4 — Core Cubits

*Reference: `money-manager-app-spec.md` § Why Cubit*

- [ ] **4.1 — `AccountsCubit`.** List, add, edit, archive/restore, reorder is N/A (accounts don't
  reorder).
- [ ] **4.2 — `CategoriesCubit`.** List (grouped by type), add, edit, archive/restore, reorder.
- [ ] **4.3 — `TransactionsCubit`.** Add, edit, delete (with confirmation), list with filters (
  date/account/category, AND logic), search.
- [ ] **4.4 — `DashboardCubit`.** Net worth, this month's income/expense, accounts preview, recent
  transactions preview — composed from streams exposed by the repositories above.
- [ ] **4.5 — `ReportsCubit`.** Income vs. expense by month, category breakdown with
  largest-remainder percentage rounding, balance trend — filterable by period/account.
- [ ] **4.6 — `SettingsCubit`.** Currency, appearance, app lock toggle, daily reminder toggle (
  stub — notification wiring can be a later milestone).

**Done when**: each Cubit has unit tests covering its Loading/Success/Error states independent of
any UI.

---

## Milestone 5 — Screens

*Reference: `money-manager-design-system.md` — one section per screen*

Build in this order, since later screens reuse components/pickers from earlier ones:

- [ ] **5.1 — Onboarding.** First-launch "add your first account" flow (per business rules doc),
  gates access to the rest of the app until at least one account exists.
- [ ] **5.2 — Add/Edit Transaction + pickers.** The most complex single screen — amount entry,
  calculator toggle, type segmented control (with the blocked-switch behavior),
  Account/Category/Date picker sheets, note, receipts (max 5, unified "+"-tile pattern).
- [ ] **5.3 — Dashboard.** Depends on 5.2's components (transaction row) and the
  Accounts/Transactions preview patterns.
- [ ] **5.4 — Transactions list.** Sticky filter chips, date grouping, search, combined filter
  sheet, date-range and multi-select picker variants.
- [ ] **5.5 — Accounts list + Account Detail + Add/Edit Account.** Archived accordion, net worth
  exclusion, negative-balance convention for credit cards.
- [ ] **5.6 — Categories Management + Add/Edit Category.** Income/Expense sections, drag-to-reorder,
  type-tinted badges.
- [ ] **5.7 — Reports.** Bar/donut/line charts (fl_chart), shares filter chips with 5.4.
- [ ] **5.8 — Settings.** Grouped rows, toggle switches, secondary entry points to 5.5/5.6.

**Done when**: every screen in the design doc is implemented and navigable end-to-end (can add an
account → add a transaction → see it on the dashboard → see it in reports).

---

## Milestone 6 — Polish

- [ ] **6.1 — Biometric app lock.** Wire `local_auth` to the Settings toggle.
- [ ] **6.2 — Receipt photo capture/storage.** `image_picker` integration, thumbnail
  generation/caching for the receipts strip (flagged as a performance detail in the design doc).
- [ ] **6.3 — Animations.** Loading/Success/Error transitions, the calculator expand/collapse, sheet
  slide-ups.
- [ ] **6.4 — Empty states.** Zero transactions, zero accounts (beyond onboarding), zero
  search/filter results.
- [ ] **6.5 — Data export.** CSV export from Settings.

**Done when**: the app feels finished, not just functionally complete.

---

## Deferred (v2+, not part of this roadmap)

- Budgets (schema already exists, UI not designed)
- Recurring transactions (will need to revisit the "no future dates" rule)
- Multi-currency conversion
- Dark mode (Settings' Appearance toggle exists in v1, but only "System" theme wiring is required
  for v1 — actual dark-mode color values are not yet finalized)
