# Money Manager App — Test Tracking

> Companion to `money-manager-test-scenarios.md` (defines *what* to check) and
`money-manager-business-rules.md` (defines *correct* behavior). This doc tracks *status*: what's
> confirmed working, what's still pending, and what's broken.

**How to use this**: check off items in Tested as you confirm them. If you stop mid-session,
whatever's still unchecked across all three sections is where to resume. If a screen's underlying
logic changes later (e.g. a Cubit gets refactored, a business rule changes), uncheck the relevant
items and move them back to "To Test Next" rather than trusting a stale pass.

---

## Tested (Passed)

### Part 1 — Onboarding

- [D] 1.1 — Fresh install forces "add first account" flow
- [D] 1.2 — Cannot skip/back out of onboarding without creating an account
- [D] 1.3 — Creating Main Bank completes onboarding, lands on Dashboard

### Part 2 — Accounts

- [D] Cash, Visa Card, Euro Travel created successfully
- [D] Net worth reflects all 4 accounts correctly (Visa Card debt subtracts)
- [D] All 4 accounts appear in Accounts list with correct type subtitles
- [D] 2.1 — Duplicate name "cash" (case-insensitive) blocked
- [D] 2.2 — Empty/whitespace-only account name blocked
- [D] 2.3 — Currency editable before any transactions exist
- [D] 2.4 — Archiving the last active account is blocked
- [D] 2.5 — Restoring archived accounts works, net worth recalculates

### Part 3 — Categories

- [D] All 17 default categories seeded, grouped correctly (Income/Expense)
- [D] Custom category "Pet care" created successfully
- [D] 3.1 — Empty category name blocked
- [D] 3.2 — Drag-reorder persists after navigating away and back
- [D] 3.3 — Cannot drag a category across Income/Expense sections
- [D] 3.4 — Archiving "Pet care" (unused) works
- [D] 3.5 — Restoring "Pet care" works

### Part 4 — Transactions

- [D] All 14 test transactions entered successfully
- [D] 4.1 — Transfer mode shows "To account" instead of Category, amount neutral-colored
- [D] 4.2 — Cross-currency transfer (USD→EUR) shows warning before saving
- [D] 4.3 — Visa Card balance becomes more negative after its expense
- [D] 4.4 — Calculator toggle resolves an expression correctly
- [D] 4.5 — Amount `0` blocked
- [D] 4.6 — Negative amount not enterable
- [D] 4.7 — Future date blocked
- [D] 4.8 — Transfer to same account blocked
- [D] 4.9 — Note over 150 characters blocked/truncated
- [D] 4.10 — Type switch blocked while a type-specific field is filled (no auto-clear)
- [D] 4.11 — Delete requires confirmation dialog
- [D] 4.12 — Editing a transaction with an archived category still displays correctly
- [D] Final balances match expected (Main Bank 11,389.20 / Cash 662.25 / Visa Card -195.00 / Euro
  Travel 400.00 EUR)
- [D] Net worth matches expected total (12,256.45)

### Part 5 — Dashboard

- [D] 5.1 — Net worth figure matches manual calculation
- [D] 5.2 — This month's income/expense totals only count current calendar month
- [D] 5.3 — Accounts preview shows up to 3, matches Accounts screen
- [D] 5.4 — Recent transactions preview shows correct icons/colors by type

### Part 6 — Transactions List

- [D] 6.1 — Sticky filter chips stay pinned while scrolling; daily net subtotals correct
- [ ] 6.2 — Search "groc" matches and highlights correctly
- [D] 6.3 — Custom date range filter returns only matching transactions
- [D] 6.4 — Account filter (Cash only) returns only matching transactions
- [D] 6.5 — Combined account + category filter uses AND logic, not OR
- [D] 6.6 — Combined filter sheet applies all dimensions together

### Part 7 — Reports

- [D] 7.1 — Income vs. expense bar chart roughly matches monthly totals
- [D] 7.2 — Category breakdown percentages sum to exactly 100%
- [D] 7.3 — Balance trend line direction matches transaction dates/amounts
- [D] 7.4 — Changing account filter updates all three charts

### Part 8 — Settings

- [D] 8.1 — Settings → Categories pushes to the same Categories screen
- [D] 8.2 — Settings → Accounts pushes to the same Accounts screen
- [D] 8.3 — Default currency row behaves as a global default, not retroactive

---

## To Test Next

*(Move items here from Tested if their underlying logic changes and needs re-verification. Add
anything from Milestone 6 once that work lands — receipts, biometric lock, export, animations, empty
states.)*

-

---

## Issues Found

*(Log anything that fails here. Move the corresponding item back out of Tested if it's currently
checked there.)*

| # | Area / Test ref | Expected | Actual | Status       |
|---|-----------------|----------|--------|--------------|
|   |                 |          |        | Open / Fixed |
