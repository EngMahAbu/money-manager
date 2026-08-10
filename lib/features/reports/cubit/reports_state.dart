import 'package:equatable/equatable.dart';
import '../../../data/daos.dart';

class ReportsState extends Equatable {
  final Map<int, double> categoryBreakdown;
  final Map<int, double> categoryPercentages; // Largest-remainder rounded
  final List<DateTimeDouble> balanceTrend;
  final double totalIncome;
  final double totalExpense;
  final bool isLoading;
  final String? error;

  const ReportsState({
    this.categoryBreakdown = const {},
    this.categoryPercentages = const {},
    this.balanceTrend = const [],
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.isLoading = false,
    this.error,
  });

  ReportsState copyWith({
    Map<int, double>? categoryBreakdown,
    Map<int, double>? categoryPercentages,
    List<DateTimeDouble>? balanceTrend,
    double? totalIncome,
    double? totalExpense,
    bool? isLoading,
    String? error,
  }) {
    return ReportsState(
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      categoryPercentages: categoryPercentages ?? this.categoryPercentages,
      balanceTrend: balanceTrend ?? this.balanceTrend,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        categoryBreakdown,
        categoryPercentages,
        balanceTrend,
        totalIncome,
        totalExpense,
        isLoading,
        error,
      ];
}
