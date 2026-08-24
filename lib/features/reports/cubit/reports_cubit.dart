import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/daos.dart';
import '../../../data/database.dart';
import '../../../repositories/transaction_repository.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final TransactionRepository _transactionRepository;
  StreamSubscription? _subscription;

  DateTime? _currentStartDate;
  DateTime? _currentEndDate;
  List<int>? _currentAccountIds;

  ReportsCubit(this._transactionRepository) : super(const ReportsState(isLoading: true));

  void loadReports({
    required DateTime startDate,
    required DateTime endDate,
    List<int>? accountIds,
  }) {
    _currentStartDate = startDate;
    _currentEndDate = endDate;
    _currentAccountIds = accountIds;
    
    emit(state.copyWith(
      isLoading: true,
      startDate: startDate,
      endDate: endDate,
      accountIds: accountIds,
    ));
    _subscription?.cancel();

    _subscription = Rx.combineLatest7(
      _transactionRepository.watchPeriodTotal(startDate, endDate, TransactionType.income),
      _transactionRepository.watchPeriodTotal(startDate, endDate, TransactionType.expense),
      _transactionRepository.watchCategoryBreakdown(
          startDate, endDate, accountIds, type: TransactionType.income),
      _transactionRepository.watchCategoryBreakdown(
          startDate, endDate, accountIds, type: TransactionType.expense),
      _transactionRepository.watchBalanceTrend(startDate, endDate, accountIds),
      _transactionRepository.watchMonthlyTotals(startDate, endDate, TransactionType.income),
      _transactionRepository.watchMonthlyTotals(startDate, endDate, TransactionType.expense),
          (double income, double expense, Map<int, double> incomeBreakdown,
          Map<int, double> expenseBreakdown,
          List<DateTimeDouble> trend, List<DateTimeDouble> incomeSeries,
          List<DateTimeDouble> expenseSeries) {
        return ReportsState(
          totalIncome: income,
          totalExpense: expense,
          incomeBreakdown: incomeBreakdown,
          incomePercentages: _calculateLargestRemainderPercentages(
              incomeBreakdown),
          expenseBreakdown: expenseBreakdown,
          expensePercentages: _calculateLargestRemainderPercentages(
              expenseBreakdown),
          balanceTrend: trend,
          monthlyIncomeSeries: incomeSeries,
          monthlyExpenseSeries: expenseSeries,
          isLoading: false,
          startDate: startDate,
          endDate: endDate,
          accountIds: accountIds,
        );
      },
    ).listen(
      (state) => emit(state),
      onError: (error) => emit(state.copyWith(error: error.toString(), isLoading: false)),
    );
  }

  void updateDateRange(DateTime startDate, DateTime endDate) {
    loadReports(
      startDate: startDate,
      endDate: endDate,
      accountIds: _currentAccountIds,
    );
  }

  void updateAccountIds(List<int> accountIds) {
    loadReports(
      startDate: _currentStartDate ?? DateTime.now().subtract(const Duration(days: 180)),
      endDate: _currentEndDate ?? DateTime.now(),
      accountIds: accountIds.isEmpty ? null : accountIds,
    );
  }

  Map<int, double> _calculateLargestRemainderPercentages(Map<int, double> breakdown) {
    if (breakdown.isEmpty) return {};

    final total = breakdown.values.fold(0.0, (sum, v) => sum + v);
    if (total == 0) return breakdown.map((k, v) => MapEntry(k, 0.0));

    final items = breakdown.entries.map((e) {
      final exact = (e.value / total) * 100;
      return _PercentageItem(
        id: e.key,
        exact: exact,
        floor: exact.floor(),
        remainder: exact - exact.floor(),
      );
    }).toList();

    int currentSum = items.fold(0, (sum, item) => sum + item.floor);
    int remainderToDistribute = 100 - currentSum;

    // Sort by remainder descending
    items.sort((a, b) => b.remainder.compareTo(a.remainder));

    for (var i = 0; i < remainderToDistribute; i++) {
      items[i].rounded = items[i].floor + 1;
    }
    for (var i = remainderToDistribute; i < items.length; i++) {
      items[i].rounded = items[i].floor;
    }

    return {for (var item in items) item.id: item.rounded.toDouble()};
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _PercentageItem {
  final int id;
  final double exact;
  final int floor;
  final double remainder;
  int rounded = 0;

  _PercentageItem({
    required this.id,
    required this.exact,
    required this.floor,
    required this.remainder,
  });
}
