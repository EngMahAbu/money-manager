import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import 'database.dart';

part 'daos.g.dart';

class DateTimeDouble {
  final DateTime date;
  final double value;
  DateTimeDouble(this.date, this.value);
}

@DriftAccessor(tables: [Accounts, Categories, Transactions, Budgets])
class AppDao extends DatabaseAccessor<AppDatabase> with _$AppDaoMixin {
  AppDao(super.db);

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
  Stream<List<Category>> watchAllCategories() =>
      (select(categories)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).watch();
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

  Stream<List<Transaction>> watchFilteredTransactions({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? accountIds,
    List<int>? categoryIds,
    String? searchQuery,
    int? limit,
  }) {
    final query = select(transactions);
    
    query.where((t) {
      Expression<bool> predicate = const Constant(true);

      if (startDate != null && endDate != null) {
        predicate = predicate & t.date.isBetweenValues(startDate, endDate);
      }
      
      if (accountIds != null && accountIds.isNotEmpty) {
        predicate = predicate & (t.accountId.isIn(accountIds) | t.toAccountId.isIn(accountIds));
      }
      
      if (categoryIds != null && categoryIds.isNotEmpty) {
        predicate = predicate & t.categoryId.isIn(categoryIds);
      }
      
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        predicate = predicate & t.note.like('%${searchQuery.trim()}%');
      }

      return predicate;
    });

    query.orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]);
    
    if (limit != null) {
      query.limit(limit);
    }
    
    return query.watch();
  }

  Stream<double> watchPeriodTotal(DateTime start, DateTime end, TransactionType type) {
    final query = select(transactions)
      ..where((t) => t.date.isBetweenValues(start, end) & t.type.equalsValue(type));
    
    return query.watch().map((list) => list.fold(0.0, (sum, t) => sum + t.amount));
  }

  Stream<Map<int, double>> watchCategoryBreakdown(DateTime start, DateTime end, List<int>? accountIds) {
    final query = select(transactions)
      ..where((t) {
        Expression<bool> predicate = t.date.isBetweenValues(start, end) & t.categoryId.isNotNull();
        if (accountIds != null && accountIds.isNotEmpty) {
          predicate = predicate & t.accountId.isIn(accountIds);
        }
        return predicate;
      });
    
    return query.watch().map((list) {
      final map = <int, double>{};
      for (final tx in list) {
        map[tx.categoryId!] = (map[tx.categoryId!] ?? 0) + tx.amount;
      }
      return map;
    });
  }
  
  Stream<List<DateTimeDouble>> watchBalanceTrend(DateTime start, DateTime end, List<int>? accountIds) {
    final query = select(transactions)
      ..where((t) {
        Expression<bool> predicate = t.date.isSmallerOrEqualValue(end);
        if (accountIds != null && accountIds.isNotEmpty) {
          predicate = predicate & (t.accountId.isIn(accountIds) | t.toAccountId.isIn(accountIds));
        }
        return predicate;
      })
      ..orderBy([(t) => OrderingTerm(expression: t.date)]);
      
    final accountsQuery = select(accounts);
    if (accountIds != null && accountIds.isNotEmpty) {
      accountsQuery.where((t) => t.id.isIn(accountIds));
    }

    return Rx.combineLatest2(query.watch(), accountsQuery.watch(), (List<Transaction> txs, List<Account> selectedAccounts) {
      double currentBalance = selectedAccounts.fold(0.0, (sum, a) => sum + a.startingBalance);
      
      final trend = <DateTimeDouble>[];
      
      for (final tx in txs) {
        if (tx.type == TransactionType.income) {
          currentBalance += tx.amount;
        } else if (tx.type == TransactionType.expense) {
          currentBalance -= tx.amount;
        } else if (tx.type == TransactionType.transfer) {
          final fromIn = accountIds == null || accountIds.contains(tx.accountId);
          final toIn = tx.toAccountId != null && (accountIds == null || accountIds.contains(tx.toAccountId!));
          
          if (fromIn && !toIn) currentBalance -= tx.amount;
          if (!fromIn && toIn) currentBalance += tx.amount;
        }
        
        if (tx.date.isAfter(start) || tx.date.isAtSameMomentAs(start)) {
          trend.add(DateTimeDouble(tx.date, currentBalance));
        }
      }
      
      return trend;
    });
  }

  Stream<List<DateTimeDouble>> watchMonthlyTotals(DateTime start, DateTime end, TransactionType type) {
    final query = select(transactions)
      ..where((t) => t.date.isBetweenValues(start, end) & t.type.equalsValue(type));

    return query.watch().map((txs) {
      final totals = <DateTime, double>{};
      for (final tx in txs) {
        final monthKey = DateTime(tx.date.year, tx.date.month);
        totals[monthKey] = (totals[monthKey] ?? 0) + tx.amount;
      }

      // Ensure all months in range are present
      final result = <DateTimeDouble>[];
      DateTime current = DateTime(start.year, start.month);
      DateTime last = DateTime(end.year, end.month);

      while (current.isBefore(last) || current.isAtSameMomentAs(last)) {
        result.add(DateTimeDouble(current, totals[current] ?? 0.0));
        current = DateTime(current.year, current.month + 1);
      }

      return result;
    });
  }

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
        final isCreditCard = account.type == AccountType.creditCard;
        
        for (final tx in txs) {
          if (isCreditCard) {
            // Credit cards: track debt as positive, so expenses increase debt
            if (tx.type == TransactionType.income) {
              balance -= tx.amount;
            } else if (tx.type == TransactionType.expense) {
              balance += tx.amount;
            } else if (tx.type == TransactionType.transfer) {
              if (tx.accountId == accountId) {
                // Transfer out = paying off debt
                balance -= tx.amount;
              }
              if (tx.toAccountId == accountId) {
                // Transfer in = adding to debt
                balance += tx.amount;
              }
            }
          } else {
            // Regular accounts
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
          final balance = balances[i];
          // Get the account to check its type
          final account = activeAccounts[i];
          final accountBalance = balance;
          if (account.type == AccountType.creditCard) {
            // Credit card balances are positive (representing debt)
            // Subtract the debt from net worth
            netWorth -= accountBalance;
          } else {
            netWorth += accountBalance;
          }
        }
        return netWorth;
      });
    });
  }
}
