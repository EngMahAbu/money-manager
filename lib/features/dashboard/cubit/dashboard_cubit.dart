import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../../repositories/account_repository.dart';
import '../../../repositories/transaction_repository.dart';
import '../../../data/database.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final AccountRepository _accountRepository;
  final TransactionRepository _transactionRepository;
  StreamSubscription? _subscription;

  DashboardCubit(this._accountRepository, this._transactionRepository)
      : super(const DashboardState(isLoading: true));

  void loadDashboard() {
    _subscription?.cancel();

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    _subscription = Rx.combineLatest5(
      _accountRepository.watchNetWorth(),
      _transactionRepository.watchPeriodTotal(monthStart, monthEnd, TransactionType.income),
      _transactionRepository.watchPeriodTotal(monthStart, monthEnd, TransactionType.expense),
      _accountRepository.watchActiveAccounts(),
      _transactionRepository.watchFilteredTransactions(limit: 3),
      (double netWorth, double income, double expense, List<Account> accounts, List<Transaction> txs) {
        return DashboardState(
          netWorth: netWorth,
          monthlyIncome: income,
          monthlyExpense: expense,
          topAccounts: accounts.take(3).toList(),
          recentTransactions: txs,
          isLoading: false,
        );
      },
    ).listen(
      (state) => emit(state),
      onError: (error) => emit(state.copyWith(error: error.toString(), isLoading: false)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
