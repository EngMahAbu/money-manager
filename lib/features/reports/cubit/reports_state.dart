import 'package:equatable/equatable.dart';
import '../../../data/daos.dart';
import '../../../data/database.dart';

class ReportsState extends Equatable {
  final Map<int, double> categoryBreakdown;
  final Map<int, double> categoryPercentages; // Largest-remainder rounded
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
    this.categoryBreakdown = const {},
    this.categoryPercentages = const {},
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
    Map<int, double>? categoryBreakdown,
    Map<int, double>? categoryPercentages,
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
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      categoryPercentages: categoryPercentages ?? this.categoryPercentages,
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
        categoryBreakdown,
        categoryPercentages,
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
