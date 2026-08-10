import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/transaction_repository.dart';
import '../../../data/database.dart';
import 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionRepository _repository;
  StreamSubscription? _subscription;

  DateTime? _startDate;
  DateTime? _endDate;
  List<int>? _accountIds;
  List<int>? _categoryIds;
  String? _searchQuery;

  TransactionsCubit(this._repository) : super(TransactionsInitial()) {
    // Load current month by default
    final now = DateTime.now();
    loadTransactions(
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999),
    );
  }

  void loadTransactions({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? accountIds,
    List<int>? categoryIds,
    String? searchQuery,
  }) {
    _startDate = startDate;
    _endDate = endDate;
    _accountIds = accountIds;
    _categoryIds = categoryIds;
    _searchQuery = searchQuery;

    emit(TransactionsLoading());
    _subscription?.cancel();
    _subscription = _repository
        .watchFilteredTransactions(
          startDate: _startDate,
          endDate: _endDate,
          accountIds: _accountIds,
          categoryIds: _categoryIds,
          searchQuery: _searchQuery,
        )
        .listen(
      (transactions) {
        emit(TransactionsLoaded(
          transactions: transactions,
          startDate: _startDate,
          endDate: _endDate,
          accountIds: _accountIds,
          categoryIds: _categoryIds,
          searchQuery: _searchQuery,
        ));
      },
      onError: (error) {
        emit(TransactionsError(error.toString()));
      },
    );
  }

  Future<void> addTransaction(TransactionsCompanion tx) async {
    try {
      await _repository.createTransaction(tx);
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> updateTransaction(Transaction tx) async {
    try {
      await _repository.updateTransaction(tx);
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> deleteTransaction(Transaction tx) async {
    try {
      await _repository.deleteTransaction(tx);
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  void updateSearch(String query) {
    loadTransactions(
      startDate: _startDate,
      endDate: _endDate,
      accountIds: _accountIds,
      categoryIds: _categoryIds,
      searchQuery: query,
    );
  }

  void updateFilters({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? accountIds,
    List<int>? categoryIds,
  }) {
    loadTransactions(
      startDate: startDate,
      endDate: endDate,
      accountIds: accountIds,
      categoryIds: categoryIds,
      searchQuery: _searchQuery,
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
