import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/data/database.dart';
import 'package:money_manager/data/daos.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

void main() {
  late AppDatabase db;
  late AppDao dao;
  late TransactionRepository repository;

  setUp(() async {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    dao = AppDao(db);
    repository = TransactionRepository(dao);
    
    // Seed a category for testing
    await dao.insertCategory(CategoriesCompanion.insert(
      name: 'Food',
      type: CategoryType.expense,
    ));
  });

  tearDown(() async {
    await db.close();
  });

  group('TransactionRepository', () {
    test('amount must be greater than 0', () async {
      final tx = TransactionsCompanion.insert(
        accountId: 1,
        type: TransactionType.expense,
        amount: 0.0,
        date: DateTime.now(),
        categoryId: const Value(1),
      );
      expect(() => repository.createTransaction(tx), throwsException);
    });

    test('no future dates allowed', () async {
      final tx = TransactionsCompanion.insert(
        accountId: 1,
        type: TransactionType.expense,
        amount: 10.0,
        date: DateTime.now().add(const Duration(days: 1)),
        categoryId: const Value(1),
      );
      expect(() => repository.createTransaction(tx), throwsException);
    });

    test('transfer requires toAccountId and it must be different', () async {
      final txSame = TransactionsCompanion.insert(
        accountId: 1,
        type: TransactionType.transfer,
        amount: 10.0,
        date: DateTime.now(),
        toAccountId: const Value(1),
      );
      expect(() => repository.createTransaction(txSame), throwsException);

      final txMissing = TransactionsCompanion.insert(
        accountId: 1,
        type: TransactionType.transfer,
        amount: 10.0,
        date: DateTime.now(),
      );
      expect(() => repository.createTransaction(txMissing), throwsException);
    });

    test('category type must match transaction type', () async {
      // Category 1 is Expense (seeded in setUp)
      final tx = TransactionsCompanion.insert(
        accountId: 1,
        type: TransactionType.income,
        amount: 10.0,
        date: DateTime.now(),
        categoryId: const Value(1),
      );
      expect(() => repository.createTransaction(tx), throwsException);
    });

    test('note length limit', () async {
      final tx = TransactionsCompanion.insert(
        accountId: 1,
        type: TransactionType.expense,
        amount: 10.0,
        date: DateTime.now(),
        categoryId: const Value(1),
        note: Value('a' * 151),
      );
      expect(() => repository.createTransaction(tx), throwsException);
    });
  });
}
