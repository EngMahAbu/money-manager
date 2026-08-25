# Money Manager App — Manual Test Scenarios (Milestones 0–5)

Covers everything through Milestone 5 (Screens). Explicitly **excludes** anything that depends on
Milestone 6 (Polish) — see the "Not yet testable" section at the bottom.

Work through this top to bottom in one sitting where possible — later sections' test data depends on
accounts/categories/transactions created in earlier sections.

---

## Part 1 — Onboarding & first launch

| #   | Steps                                                                                | Expected result                                                                                             |
|-----|--------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| 1.1 | Fresh install, open the app for the first time                                       | You're forced into an "add your first account" flow — Dashboard/Add Transaction should not be reachable yet |
| 1.2 | Try to back out of onboarding without creating an account                            | Should not be possible to skip — onboarding blocks until at least one account exists                        |
| 1.3 | Create your first account: **Main Bank**, type Bank, currency USD, balance `5000.00` | Onboarding completes, you land on the Dashboard, Main Bank shows $5,000                                     |

---

## Part 2 — Accounts

Create these additional accounts via Accounts → "+":

| Name        | Type        | Currency | Balance |
|-------------|-------------|----------|---------|
| Cash        | Cash        | USD      | 200.00  |
| Visa Card   | Credit card | USD      | -150.00 |
| Euro Travel | Bank        | EUR      | 300.00  |

**Expected after all 4 accounts exist:**

- Net worth on Dashboard/Accounts = **5,350** ($5,000 + $200 − $150 + 300 EUR, summed as raw numbers
  since v1 has no currency conversion — this is a known limitation being exercised on purpose by
  including a EUR account here). Confirm Visa Card's debt subtracts rather than adds; if the app
  instead shows EUR separately from the USD total, that's a deviation from the current spec worth
  flagging.
- All 4 appear in the Accounts list with correct type subtitles

### Validation checks

| #   | Steps                                                                                                                                     | Expected result                                          |
|-----|-------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------|
| 2.1 | Try creating an account named `cash` (lowercase)                                                                                          | **Blocked** — duplicate of "Cash", case-insensitive      |
| 2.2 | Try creating an account with an empty/whitespace-only name                                                                                | **Blocked**                                              |
| 2.3 | Edit "Cash" — try changing its currency before adding any transactions to it                                                              | **Allowed** — no transactions yet, currency isn't locked |
| 2.4 | Archive "Euro Travel," then archive "Visa Card," then archive "Cash" — now only "Main Bank" remains active. Try archiving "Main Bank" too | **Blocked** — can't archive the last active account      |
| 2.5 | Restore "Cash," "Visa Card," and "Euro Travel" from the Archived section                                                                  | All 4 active again, net worth recalculates correctly     |

---

## Part 3 — Categories

Confirm the 17 default categories seeded on first launch (12 expense, 5 income — see app spec doc's
Default Categories table) all appear, grouped correctly under Income/Expense.

Add one custom category: **Pet care**, type Expense, any icon.

### Validation checks

| #   | Steps                                                    | Expected result                                           |
|-----|----------------------------------------------------------|-----------------------------------------------------------|
| 3.1 | Try creating a category with an empty name               | **Blocked**                                               |
| 3.2 | Drag-reorder two Expense categories                      | Order persists after navigating away and back             |
| 3.3 | Try dragging an Expense category into the Income section | Should not be possible — reordering is scoped within type |
| 3.4 | Archive "Pet care" (before using it in any transaction)  | Moves to Archived, restorable                             |
| 3.5 | Restore "Pet care"                                       | Back in the active Expense list                           |

---

## Part 4 — Transactions

Enter these transactions in order (use **today's actual date** as the anchor; "T-1" = yesterday, "
T-30" = 30 days ago, etc.):

| #  | Type     | Account                 | Category / To-account | Amount  | Date  | Note                |
|----|----------|-------------------------|-----------------------|---------|-------|---------------------|
| 1  | Income   | Main Bank               | Salary                | 3000.00 | T-1   | —                   |
| 2  | Expense  | Main Bank               | Groceries             | 64.50   | Today | Weekly shop         |
| 3  | Expense  | Main Bank               | Rent & housing        | 1200.00 | T-15  | —                   |
| 4  | Expense  | Cash                    | Dining out            | 22.75   | T-1   | —                   |
| 5  | Transfer | Main Bank → Cash        | —                     | 500.00  | Today | —                   |
| 6  | Transfer | Main Bank → Euro Travel | —                     | 100.00  | Today | Cross-currency test |
| 7  | Expense  | Visa Card               | Entertainment         | 45.00   | T-3   | —                   |
| 8  | Income   | Main Bank               | Freelance             | 600.00  | T-20  | —                   |
| 9  | Expense  | Main Bank               | Utilities             | 88.20   | T-40  | —                   |
| 10 | Expense  | Cash                    | Transport             | 15.00   | T-45  | —                   |
| 11 | Income   | Main Bank               | Salary                | 3000.00 | T-31  | —                   |
| 12 | Expense  | Main Bank               | Groceries             | 58.10   | T-60  | —                   |
| 13 | Income   | Main Bank               | Salary                | 3000.00 | T-61  | —                   |
| 14 | Expense  | Main Bank               | Rent & housing        | 1200.00 | T-75  | —                   |

(Transactions 9–14 spread across roughly the last 3 months — needed for the Reports bar chart and
balance trend to show meaningful shape rather than one flat bar.)

### Expected balances after all 14 transactions

| Account     | Starting balance | Final balance  |
|-------------|------------------|----------------|
| Main Bank   | 5,000.00         | **11,389.20**  |
| Cash        | 200.00           | **662.25**     |
| Visa Card   | -150.00          | **-195.00**    |
| Euro Travel | 300.00 EUR       | **400.00 EUR** |

**Expected net worth: 12,256.45** — raw sum of all four balances (11,389.20 + 662.25 − 195.00 +
400.00), per v1's no-currency-conversion policy (see Part 2's net worth note). Use this as the
definitive check after entering all 14 transactions — if the app shows a different number, work
backward through Parts 2 and 4 to find where balances diverged.

### Happy-path checks while entering

| #   | Steps                                                                        | Expected result                                                                       |
|-----|------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| 4.1 | Transaction #5 (Transfer)                                                    | Category row is replaced by "To account," amount field neutral-colored, not red/green |
| 4.2 | Transaction #6 (cross-currency transfer, USD → EUR)                          | A warning/confirmation appears before it's allowed to save                            |
| 4.3 | Transaction #7 (Visa Card expense)                                           | Visa Card's balance becomes more negative afterward                                   |
| 4.4 | Use the **calculator toggle** on any transaction — try `12.50 + 8.30 + 4.20` | Resolves to `25.00` in the amount field                                               |

### Validation checks

| #    | Steps                                                                                                                       | Expected result                                                                                              |
|------|-----------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| 4.5  | Try entering amount `0`                                                                                                     | **Blocked**                                                                                                  |
| 4.6  | Try entering a negative amount directly                                                                                     | Should not be enterable (keypad has no minus key)                                                            |
| 4.7  | Try selecting a future date                                                                                                 | **Blocked** — date picker should not allow it, or save should reject it                                      |
| 4.8  | Start a Transfer, select the same account for both From and To                                                              | **Blocked**                                                                                                  |
| 4.9  | Try entering a note longer than 150 characters                                                                              | Input stops accepting more characters at 150, or save is blocked                                             |
| 4.10 | Switch an Income transaction's type to Expense mid-edit while a Category is already selected                                | Type switch is **blocked** until the Category is manually cleared first (per business rules — no auto-clear) |
| 4.11 | Create a transaction, then delete it                                                                                        | A confirmation dialog appears before it's actually removed                                                   |
| 4.12 | Edit transaction #4 (Cash, archived-eligible test): archive the "Dining out" category, then open transaction #4 for editing | The archived category still displays correctly on the existing transaction                                   |

---

## Part 5 — Dashboard

| #   | Check                              | Expected result                                                                                      |
|-----|------------------------------------|------------------------------------------------------------------------------------------------------|
| 5.1 | Net worth figure                   | Matches manual sum: (Main Bank + Cash + Euro Travel) − Visa Card debt, after all Part 4 transactions |
| 5.2 | This month's income/expense totals | Only counts transactions dated within the current calendar month                                     |
| 5.3 | Accounts preview                   | Shows up to 3 accounts, matches Accounts screen balances                                             |
| 5.4 | Recent transactions preview        | Shows the most recent entries, correct icons/colors by type                                          |

---

## Part 6 — Transactions List

| #   | Steps                                                                            | Expected result                                                                           |
|-----|----------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| 6.1 | Open Transactions, scroll                                                        | Sticky filter chips row stays pinned; date group headers show correct daily net subtotals |
| 6.2 | Search "groc"                                                                    | Both "Groceries" transactions appear, matched substring highlighted                       |
| 6.3 | Tap the "This month" chip → apply a custom date range covering only T-60 to T-45 | Only transactions #10 and #12 appear                                                      |
| 6.4 | Tap the Account chip → select only "Cash"                                        | Only Cash-account transactions appear (#4, #5 as destination, #10)                        |
| 6.5 | Combine an account filter (Main Bank) AND a category filter (Groceries)          | Only transactions matching **both** appear — confirms AND logic, not OR                   |
| 6.6 | Open the combined filter sheet (filter icon, not a chip)                         | All filter dimensions adjustable together, "Apply filters" commits them all at once       |

---

## Part 7 — Reports

| #   | Check                                                            | Expected result                                                                             |
|-----|------------------------------------------------------------------|---------------------------------------------------------------------------------------------|
| 7.1 | Income vs. expense bar chart                                     | Bars roughly match the monthly totals from the transactions entered across T-1 through T-75 |
| 7.2 | Category breakdown donut + legend                                | Percentages listed **sum to exactly 100%** (largest-remainder rounding)                     |
| 7.3 | Balance trend line                                               | Generally trends in the direction implied by the transaction dates/amounts entered          |
| 7.4 | Change the filter chips (e.g. "All accounts" → just "Main Bank") | All three charts update to reflect only Main Bank's data                                    |

---

## Part 8 — Settings

| #   | Check                 | Expected result                                                                                                       |
|-----|-----------------------|-----------------------------------------------------------------------------------------------------------------------|
| 8.1 | Settings → Categories | Pushes to the same Categories Management screen as Part 3                                                             |
| 8.2 | Settings → Accounts   | Pushes to the same Accounts screen as Part 2                                                                          |
| 8.3 | Default currency row  | Reflects/edits a global default (used for new accounts going forward, doesn't retroactively change existing accounts) |

---

## Not yet testable (depends on Milestone 6)

- **Receipt photo capture** — the "+" tile UI may render, but actual camera/gallery picking depends
  on `image_picker` wiring (task 6.2)
- **Biometric app lock** — the Settings toggle may exist, but `local_auth` isn't wired until 6.1
- **CSV export** — Settings → Export data (task 6.5)
- **Animations** — calculator expand/collapse, sheet transitions may currently be
  instant/unpolished (task 6.3)
- **Empty states** — zero-search-results, zero-transaction states beyond onboarding (task 6.4)

If any of these already work, great — just don't treat their absence as a bug at this stage.
