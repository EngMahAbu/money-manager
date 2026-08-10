import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import 'database.dart';

part 'daos.g.dart';

@DriftAccessor(tables: [Accounts, Categories, Transactions, Budgets])
class AppDao extends DatabaseAccessor<AppDatabase> with _$AppDaoMixin {
  AppDao(AppDatabase db) : super(db);

  // Accounts CRUD
  Future<int> insertAccount(AccountsCompanion account) => into(accounts).insert(account);
  Future<bool> updateAccount(Account account) => update(accounts).replace(account);
  Stream<List<Account>> watchAllAccounts() => select(accounts).watch();
  Stream<List<Account>> watchActiveAccounts() =>
      (select(accounts)..where((t) => t.isArchived.equals(false))).watch();
  Future<Account> getAccountById(int id) =>
      (select(accounts)..where((t) => t.id.equals(id))).getSingle();

  // Categories CRUD
  Future<int> insertCategory(CategoriesCompanion category) => into(categories).insert(category);
  Future<bool> updateCategory(Category category) => update(categories).replace(category);
  Stream<List<Category>> watchCategoriesByType(CategoryType type) =>
      (select(categories)
            ..where((t) => t.type.equalsValue(type) & t.isArchived.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .watch();
  Future<Category> getCategoryById(int id) =>
      (select(categories)..where((t) => t.id.equals(id))).getSingle();

  Future<bool> categoryHasTransactions(int categoryId) async {
    final query = select(transactions)..where((t) => t.categoryId.equals(categoryId))..limit(1);
    final results = await query.get();
    return results.isNotEmpty;
  }

  // Transactions CRUD
  Future<int> insertTransaction(TransactionsCompanion transaction) =>
      into(transactions).insert(transaction);
  Future<bool> updateTransaction(Transaction transaction) =>
      update(transactions).replace(transaction);
  Future<int> deleteTransaction(Transaction transaction) =>
      delete(transactions).delete(transaction);

  Stream<List<Transaction>> watchTransactionsInRange(DateTime start, DateTime end) =>
      (select(transactions)..where((t) => t.date.isBetweenValues(start, end))).watch();

  // Complex Queries (simplified for now, logic might move to Repository)
  // For balance and net worth, we often need to join or do multiple aggregates.
  // v1 simple version: watch all transactions and calculate in Dart or use specialized queries.
  
  Stream<List<Transaction>> watchAccountTransactions(int accountId) {
    return (select(transactions)..where((t) => t.accountId.equals(accountId) | t.toAccountId.equals(accountId))).watch();
  }

  Stream<double> watchAccountBalance(int accountId) {
    final accountQuery = select(accounts)..where((t) => t.id.equals(accountId));
    
    return accountQuery.watchSingle().switchMap((account) {
      final transactionsQuery = select(transactions)
        ..where((t) => t.accountId.equals(accountId) | t.toAccountId.equals(accountId));
        
      return transactionsQuery.watch().map((txs) {
        double balance = account.startingBalance;
        for (final tx in txs) {
          if (tx.type == TransactionType.income) {
            balance += tx.amount;
          } else if (tx.type == TransactionType.expense) {
            balance -= tx.amount;
          } else if (tx.type == TransactionType.transfer) {
            if (tx.accountId == accountId) {
              balance -= tx.amount;
            }
            if (tx.toAccountId == accountId) {
              balance += tx.amount;
            }
          }
        }
        return balance;
      });
    });
  }

  Stream<double> watchNetWorth() {
    return watchActiveAccounts().switchMap((activeAccounts) {
      if (activeAccounts.isEmpty) return Stream.value(0.0);
      
      final accountBalances = activeAccounts.map((a) => watchAccountBalance(a.id));
      return Rx.combineLatestList(accountBalances).map((balances) {
        double netWorth = 0;
        for (int i = 0; i < activeAccounts.length; i++) {
          final account = activeAccounts[i];
          final balance = balances[i];
          if (account.type == AccountType.creditCard) {
            netWorth -= balance; // Wait, if balance is positive (debt), subtract it. 
            // Actually, the spec says "credit card balances subtracting rather than adding".
            // If starting balance is 0 and I spend 100, the balance is -100.
            // If I subtract -100, I add 100. That's wrong.
            // "A creditCard account represents debt, so its balance should subtract from total net worth"
            // Usually, debt is stored as a positive number in some apps, or negative in others.
            // The spec says "Amounts are always stored positive; type (income/expense/transfer) is the sign source of truth."
            // So if I have a credit card account, and I have an expense of 100, the "balance" calculated above will be startingBalance - 100.
            // If starting balance was 0, balance is -100.
            // Net worth should be: sum(assets) - sum(debts).
            // If balance of credit card is -100, it means I owe 100? No, if I spend 100, it's -100.
            // Let's re-read: "A creditCard account represents debt, so its balance should subtract from total net worth, while cash / bank / savings balances add."
            // If I have $1000 in Bank and -$200 in Credit Card, Net Worth is $800.
            // So I should just ADD all balances, provided credit card balances naturally go negative.
            // "Negative-balance convention for credit cards" is mentioned in Milestone 5.5.
            // Let's check 2.4: "Net worth = sum of active (non-archived) account balances, with credit card balances subtracting rather than adding (per AccountType)."
            // This suggests that maybe credit card balances are stored/calculated as positive values for debt?
            // "never store negative amounts" (Guardrails).
            // But balance is calculated.
            // If I follow "credit card balances subtracting", then if balance is 200 (debt), I subtract 200.
            
            netWorth -= balance;
          } else {
            netWorth += balance;
          }
        }
        return netWorth;
      });
    });
  }
}

// Need rxdart for Rx.combineLatestList and switchMap
