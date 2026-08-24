import 'package:equatable/equatable.dart';

import '../../../data/daos.dart';

class ReportsState extends Equatable {
  final Map<int, double> expenseBreakdown;
  final Map<int, double> expensePercentages;
  final Map<int, double> incomeBreakdown;
  final Map<int, double> incomePercentages;
  final List<DateTimeDouble> balanceTrend;
  final List<DateTimeDouble> monthlyIncomeSeries;
  final List<DateTimeDouble> monthlyExpenseSeries;
  final double totalIncome;
  final double totalExpense;
  final bool isLoading;
  final String? error;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<int>? accountIds;

  const ReportsState({
    this.expenseBreakdown = const {},
    this.expensePercentages = const {},
    this.incomeBreakdown = const {},
    this.incomePercentages = const {},
    this.balanceTrend = const [],
    this.monthlyIncomeSeries = const [],
    this.monthlyExpenseSeries = const [],
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.isLoading = false,
    this.error,
    this.startDate,
    this.endDate,
    this.accountIds,
  });

  ReportsState copyWith({
    Map<int, double>? expenseBreakdown,
    Map<int, double>? expensePercentages,
    Map<int, double>? incomeBreakdown,
    Map<int, double>? incomePercentages,
    List<DateTimeDouble>? balanceTrend,
    List<DateTimeDouble>? monthlyIncomeSeries,
    List<DateTimeDouble>? monthlyExpenseSeries,
    double? totalIncome,
    double? totalExpense,
    bool? isLoading,
    String? error,
    DateTime? startDate,
    DateTime? endDate,
    List<int>? accountIds,
  }) {
    return ReportsState(
      expenseBreakdown: expenseBreakdown ?? this.expenseBreakdown,
      expensePercentages: expensePercentages ?? this.expensePercentages,
      incomeBreakdown: incomeBreakdown ?? this.incomeBreakdown,
      incomePercentages: incomePercentages ?? this.incomePercentages,
      balanceTrend: balanceTrend ?? this.balanceTrend,
      monthlyIncomeSeries: monthlyIncomeSeries ?? this.monthlyIncomeSeries,
      monthlyExpenseSeries: monthlyExpenseSeries ?? this.monthlyExpenseSeries,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      accountIds: accountIds ?? this.accountIds,
    );
  }

  @override
  List<Object?> get props => [
    expenseBreakdown,
    expensePercentages,
    incomeBreakdown,
    incomePercentages,
    balanceTrend,
        monthlyIncomeSeries,
        monthlyExpenseSeries,
        totalIncome,
        totalExpense,
        isLoading,
        error,
        startDate,
        endDate,
        accountIds,
      ];
}
