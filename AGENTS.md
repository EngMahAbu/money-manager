# AGENTS.md

Agent guide for the Money Manager app. Read this first, every session — it tells you where to find
details and which conventions are non-negotiable.

## What this is

A Flutter (iOS/Android) money manager app. Manual transaction entry only (no bank sync), single
user, multiple accounts. Local-only storage via Drift/SQLite — no backend, no auth server.

## Companion documents

Read the relevant section before implementing anything it covers — don't guess at details these docs
already answer.

| Doc                                       | Covers                                                                                           |
|-------------------------------------------|--------------------------------------------------------------------------------------------------|
| `money-manager-app-spec.md`               | Architecture, tech stack rationale, Drift schema, default category seed data                     |
| `money-manager-design-system.md`          | Colors (exact hex), typography, spacing, every screen's layout and components                    |
| `money-manager-business-rules.md`         | Validation rules, constraints, edge cases — the source of truth for "what should happen when..." |
| `money-manager-implementation-roadmap.md` | The sequenced task breakdown — work through milestones in order                                  |

If a design or behavior question isn't answered in one of these docs, stop and ask rather than
guessing — don't invent a rule that contradicts what's already decided.

## Tech stack (do not substitute)

- **Flutter 3.44.x / Dart 3.12.x**
- **Drift** for local storage (not sqflite — see app spec doc for why)
- **Cubit** (`flutter_bloc` package) for state management — **not full Bloc**. Cubits expose plain
  methods that call `emit()` directly. Never introduce separate `Event` classes or `on<Event>()`
  mapping; that pattern was deliberately rejected in favor of Cubit's lower boilerplate. If a
  screen's interaction seems to need debouncing or double-submit guarding, handle it with a `Timer`
  or a boolean guard flag inside the Cubit method — don't reach for Bloc's event transformers as an
  excuse to switch patterns.
- **fl_chart** for the Reports charts
- **`flutter_lints`** (not `very_good_analysis`) for the lint set

## Folder structure (feature-first — do not reorganize)

```
lib/
  features/
    dashboard/        (cubit/, screen.dart)
    transactions/      (cubit/, screen.dart, widgets/)
    accounts/          (cubit/, list + detail screens, add/edit screen)
    categories/        (cubit/, screen.dart, add/edit screen)
    reports/           (cubit/, screen.dart)
    settings/          (cubit/, screen.dart)
  shared/
    widgets/           (cross-feature components only: transaction row, toggle switch, metric card, bottom nav)
    theme/             (AppColors, AppTextStyles, ThemeData)
  data/                (Drift tables, DAOs — flat, cross-cutting)
  repositories/        (flat — consumed by multiple features' cubits)
```

A widget belongs in `shared/widgets/` only if 2+ features actually use it. A picker sheet or filter
sheet that only Transactions uses belongs in `features/transactions/widgets/`, not `shared/`.

## Git conventions

- Trunk-based on `main`, short-lived branches per task when useful (e.g. `0.1-init-project`)
- Conventional commits: `feat:`, `fix:`, `chore:`, `refactor:`
- Drift's generated files (`*.g.dart`) are gitignored, not committed. *
  *Run `dart run build_runner build` after pulling or after any change to a Drift table** — the
  project won't compile without it, and a missing generated file is not a bug to "fix" by writing
  one by hand.

## Guardrails — decisions already made, do not silently re-open these

- Amounts are always stored positive; `type` (income/expense/transfer) is the sign source of truth.
  Never store negative amounts.
- `Categories` has **no `color` column** — badge color is derived from `type` at render time (green
  for income, red for expense). Don't add one back.
- Accounts and Categories use **soft delete** (`isArchived`), never hard delete. Transactions use
  hard delete (with a confirmation dialog — see business rules doc).
- No future-dated transactions in v1 — validate `date <= today` at the repository layer.
- The app must always have at least one active account — block archiving the last one.
- Category `type` and Account `currency` lock once the entity has at least one transaction — don't
  allow editing them freely.
- Reports category-breakdown percentages use largest-remainder rounding so they always sum to 100%.

## Working through the roadmap

Follow `money-manager-implementation-roadmap.md` in milestone order — later milestones assume
earlier ones are done (e.g. don't start on screens in Milestone 5 before the Cubits in Milestone 4
exist). Each task in that doc names which companion doc section to implement against; check it
before writing code, not after.

## Testing expectations

- Repository-layer tests are the highest priority — that's where every business rule in
  `money-manager-business-rules.md` gets enforced, and where a money-correctness bug would actually
  live.
- Cubit tests should cover Loading/Success/Error states independent of any widget.
- Widget tests are expected for Add/Edit Transaction (given its state complexity) and Transactions
  list filtering, per Milestone 7.

## When something is ambiguous

Prefer asking over guessing, especially for anything touching money math, validation rules, or a
screen's exact behavior in an edge case. A wrong guess here is a correctness bug, not just a style
nit.
