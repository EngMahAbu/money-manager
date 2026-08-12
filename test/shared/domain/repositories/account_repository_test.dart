import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/shared/data/daos.dart';
import 'package:money_manager/shared/data/database.dart';
import 'package:money_manager/shared/domain/repositories/account_repository.dart';

void main() {
  late AppDatabase db;
  late AppDao dao;
  late AccountRepository repository;

  setUp(() async {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    dao = AppDao(db);
    repository = AccountRepository(dao);
  });

  tearDown(() async {
    await db.close();
  });

  group('AccountRepository', () {
    test('createAccount throws exception for empty name', () async {
      final companion = AccountsCompanion.insert(
        name: ' ',
        type: AccountType.bank,
      );
      expect(() => repository.createAccount(companion), throwsException);
    });

    test('createAccount throws exception for duplicate name', () async {
      await repository.createAccount(
        AccountsCompanion.insert(name: 'Savings', type: AccountType.savings),
      );

      final duplicate = AccountsCompanion.insert(
        name: 'savings',
        type: AccountType.bank,
      );
      expect(() => repository.createAccount(duplicate), throwsException);
    });

    test('updateAccount locks currency if transactions exist', () async {
      await repository.createAccount(
        AccountsCompanion.insert(
          name: 'Bank',
          type: AccountType.bank,
          currency: const Value('USD'),
        ),
      );

      final account = (await repository.watchAllAccounts().first).first;

      // Add a transaction
      await dao.insertTransaction(
        TransactionsCompanion.insert(
          accountId: account.id,
          type: TransactionType.expense,
          amount: 100.0,
          date: DateTime.now(),
          categoryId: const Value(1), // Dummy ID
        ),
      );

      final updatedAccount = account.copyWith(currency: 'EUR');
      expect(() => repository.updateAccount(updatedAccount), throwsException);
    });

    test('archiveAccount blocks archiving the last account', () async {
      await repository.createAccount(
        AccountsCompanion.insert(name: 'Only Account', type: AccountType.cash),
      );

      final account = (await repository.watchActiveAccounts().first).first;
      expect(() => repository.archiveAccount(account.id), throwsException);
    });
  });
}
