import 'package:equatable/equatable.dart';
import '../../../data/database.dart';

class DashboardState extends Equatable {
  final double netWorth;
  final double monthlyIncome;
  final double monthlyExpense;
  final List<Account> topAccounts;
  final List<Transaction> recentTransactions;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.netWorth = 0,
    this.monthlyIncome = 0,
    this.monthlyExpense = 0,
    this.topAccounts = const [],
    this.recentTransactions = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    double? netWorth,
    double? monthlyIncome,
    double? monthlyExpense,
    List<Account>? topAccounts,
    List<Transaction>? recentTransactions,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      netWorth: netWorth ?? this.netWorth,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      topAccounts: topAccounts ?? this.topAccounts,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        netWorth,
        monthlyIncome,
        monthlyExpense,
        topAccounts,
        recentTransactions,
        isLoading,
        error,
      ];
}
