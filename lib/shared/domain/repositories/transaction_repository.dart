import 'package:drift/drift.dart';
import 'package:money_manager/shared/data/daos.dart';
import 'package:money_manager/shared/data/database.dart';

class TransactionRepository {
  final AppDao _dao;

  TransactionRepository(this._dao);

  Stream<List<Transaction>> watchTransactionsInRange(
    DateTime start,
    DateTime end,
  ) => _dao.watchTransactionsInRange(start, end);

  Future<void> createTransaction(TransactionsCompanion tx) async {
    final validated = await _validateAndFormat(tx);
    await _dao.insertTransaction(validated);
  }

  Future<void> updateTransaction(Transaction tx) async {
    final companion = tx.toCompanion(true);
    await _validateAndFormat(companion);
    await _dao.updateTransaction(tx);
  }

  Future<void> deleteTransaction(Transaction tx) async {
    await _dao.deleteTransaction(tx);
  }

  Future<TransactionsCompanion> _validateAndFormat(
    TransactionsCompanion tx,
  ) async {
    // Amount validation and rounding
    double amount = tx.amount.value;
    amount = (amount * 100).roundToDouble() / 100.0;
    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    // Date validation
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    if (tx.date.value.isAfter(todayEnd)) {
      throw Exception('Future dates are not allowed');
    }

    // Type-specific validation
    final type = tx.type.value;
    if (type == TransactionType.transfer) {
      if (tx.categoryId.value != null) {
        throw Exception('Transfers cannot have a category');
      }
      if (tx.toAccountId.value == null) {
        throw Exception('Transfer requires a destination account');
      }
      if (tx.toAccountId.value == tx.accountId.value) {
        throw Exception('Cannot transfer to the same account');
      }
    } else {
      if (tx.categoryId.value == null) {
        throw Exception('Category is required for income/expense');
      }
      if (tx.toAccountId.value != null) {
        throw Exception('Only transfers can have a destination account');
      }

      // Check category type matches transaction type
      final category = await _dao.getCategoryById(tx.categoryId.value!);
      if (type == TransactionType.income &&
          category.type != CategoryType.income) {
        throw Exception('Income transaction must use an income category');
      }
      if (type == TransactionType.expense &&
          category.type != CategoryType.expense) {
        throw Exception('Expense transaction must use an expense category');
      }
    }

    // Note validation
    if (tx.note.value != null && tx.note.value!.length > 150) {
      throw Exception('Note cannot exceed 150 characters');
    }

    // Receipts validation
    if (tx.receipts.value != null) {
      final receiptList = tx.receipts.value!
          .split('|')
          .where((s) => s.isNotEmpty)
          .toList();
      if (receiptList.length > 5) {
        throw Exception('Maximum 5 receipts allowed');
      }
    }

    return tx.copyWith(amount: Value(amount));
  }
}
