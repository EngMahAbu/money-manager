import 'package:drift/drift.dart';
import 'package:money_manager/shared/data/daos.dart';
import 'package:money_manager/shared/data/database.dart';

class AccountRepository {
  final AppDao _dao;

  AccountRepository(this._dao);

  Stream<List<Account>> watchActiveAccounts() => _dao.watchActiveAccounts();

  Stream<List<Account>> watchAllAccounts() => _dao.watchAllAccounts();

  Future<Account> getAccountById(int id) => _dao.getAccountById(id);

  Future<void> createAccount(AccountsCompanion account) async {
    final name = account.name.value.trim();
    if (name.isEmpty) {
      throw Exception('Account name cannot be empty');
    }

    final allAccounts = await _dao.watchAllAccounts().first;
    final nameExists = allAccounts.any(
      (a) => a.name.toLowerCase() == name.toLowerCase(),
    );
    if (nameExists) {
      throw Exception('Account name must be unique');
    }

    await _dao.insertAccount(account.copyWith(name: Value(name)));
  }

  Future<void> updateAccount(Account account) async {
    final name = account.name.trim();
    if (name.isEmpty) {
      throw Exception('Account name cannot be empty');
    }

    final allAccounts = await _dao.watchAllAccounts().first;
    final nameExists = allAccounts.any(
      (a) => a.id != account.id && a.name.toLowerCase() == name.toLowerCase(),
    );
    if (nameExists) {
      throw Exception('Account name must be unique');
    }

    final existingAccount = await _dao.getAccountById(account.id);

    // Currency lock check
    if (existingAccount.currency != account.currency) {
      final hasTransactions = await _hasTransactions(account.id);
      if (hasTransactions) {
        throw Exception(
          'Currency is locked because this account has transactions',
        );
      }
    }

    await _dao.updateAccount(account.copyWith(name: name));
  }

  Future<void> archiveAccount(int id) async {
    final activeAccounts = await _dao.watchActiveAccounts().first;
    if (activeAccounts.length <= 1 && activeAccounts.any((a) => a.id == id)) {
      throw Exception('Cannot archive the last active account');
    }

    final account = await _dao.getAccountById(id);
    await _dao.updateAccount(account.copyWith(isArchived: true));
  }

  Future<void> restoreAccount(int id) async {
    final account = await _dao.getAccountById(id);
    await _dao.updateAccount(account.copyWith(isArchived: false));
  }

  Future<bool> _hasTransactions(int accountId) async {
    // We check both accountId and toAccountId for transfers
    final txs = await _dao.watchAccountTransactions(accountId).first;
    return txs.isNotEmpty;
  }

  Stream<double> watchAccountBalance(int accountId) =>
      _dao.watchAccountBalance(accountId);

  Stream<double> watchNetWorth() => _dao.watchNetWorth();
}
