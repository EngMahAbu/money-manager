import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/data/database.dart';
import 'package:money_manager/data/daos.dart';

void main() {
  late AppDatabase db;
  late AppDao dao;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    dao = AppDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Database Seed Data', () {
    test('Categories are seeded on first launch', () async {
      final allCategories = await dao.watchAllCategories().first;
      
      // Based on app spec, we should have 12 expense + 5 income = 17 categories
      expect(allCategories.length, 17);
      
      final expenseCategories = allCategories.where((c) => c.type == CategoryType.expense).toList();
      final incomeCategories = allCategories.where((c) => c.type == CategoryType.income).toList();
      
      expect(expenseCategories.length, 12);
      expect(incomeCategories.length, 5);
      
      expect(expenseCategories.first.name, 'Groceries');
      expect(incomeCategories.first.name, 'Salary');
    });
  });

  group('Accounts Table', () {
    test('Can insert and query account', () async {
      final id = await dao.insertAccount(AccountsCompanion.insert(
        name: 'Test Bank',
        type: AccountType.bank,
        currency: const Value('USD'),
        startingBalance: const Value(1000.0),
      ));

      final account = await dao.getAccountById(id);
      expect(account.name, 'Test Bank');
      expect(account.startingBalance, 1000.0);
    });

    test('watchActiveAccounts only returns non-archived accounts', () async {
      await dao.insertAccount(AccountsCompanion.insert(name: 'Active', type: AccountType.cash));
      await dao.insertAccount(AccountsCompanion.insert(name: 'Archived', type: AccountType.cash, isArchived: const Value(true)));

      final activeAccounts = await dao.watchActiveAccounts().first;
      expect(activeAccounts.length, 1);
      expect(activeAccounts.first.name, 'Active');
    });
  });

  group('Transactions Table', () {
    test('Can insert and delete transaction', () async {
      final accountId = await dao.insertAccount(AccountsCompanion.insert(name: 'Bank', type: AccountType.bank));
      
      await dao.insertTransaction(TransactionsCompanion.insert(
        accountId: accountId,
        type: TransactionType.expense,
        amount: 50.0,
        date: DateTime.now(),
        categoryId: const Value(1),
      ));

      var txs = await dao.watchAccountTransactions(accountId).first;
      expect(txs.length, 1);

      await dao.deleteTransaction(txs.first);
      txs = await dao.watchAccountTransactions(accountId).first;
      expect(txs.isEmpty, true);
    });
  });

  group('Budgets Table', () {
    test('Can insert and query budget', () async {
      final month = DateTime(2023, 1, 1);
      await db.into(db.budgets).insert(BudgetsCompanion.insert(
        categoryId: 1,
        month: month,
        limitAmount: 500.0,
      ));

      final allBudgets = await db.select(db.budgets).get();
      expect(allBudgets.length, 1);
      expect(allBudgets.first.limitAmount, 500.0);
    });

    test('Budget unique key constraint (categoryId, month)', () async {
      final month = DateTime(2023, 1, 1);
      await db.into(db.budgets).insert(BudgetsCompanion.insert(
        categoryId: 1,
        month: month,
        limitAmount: 500.0,
      ));

      expect(
        () => db.into(db.budgets).insert(BudgetsCompanion.insert(
          categoryId: 1,
          month: month,
          limitAmount: 600.0,
        )),
        throwsException,
      );
    });
  });
}
