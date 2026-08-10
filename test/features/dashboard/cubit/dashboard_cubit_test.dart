import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:money_manager/features/dashboard/cubit/dashboard_state.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';
import 'package:money_manager/data/database.dart';

class MockAccountRepository extends Mock implements AccountRepository {}
class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late AccountRepository accountRepository;
  late TransactionRepository transactionRepository;
  late DashboardCubit cubit;

  setUp(() {
    accountRepository = MockAccountRepository();
    transactionRepository = MockTransactionRepository();
    cubit = DashboardCubit(accountRepository, transactionRepository);
  });

  group('DashboardCubit', () {
    blocTest<DashboardCubit, DashboardState>(
      'loadDashboard emits correct state on success',
      build: () {
        when(() => accountRepository.watchNetWorth()).thenAnswer((_) => Stream.value(1000.0));
        when(() => transactionRepository.watchPeriodTotal(any(), any(), TransactionType.income)).thenAnswer((_) => Stream.value(500.0));
        when(() => transactionRepository.watchPeriodTotal(any(), any(), TransactionType.expense)).thenAnswer((_) => Stream.value(200.0));
        when(() => accountRepository.watchActiveAccounts()).thenAnswer((_) => Stream.value([]));
        when(() => transactionRepository.watchFilteredTransactions(limit: 3)).thenAnswer((_) => Stream.value([]));
        return cubit;
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const DashboardState(
          netWorth: 1000.0,
          monthlyIncome: 500.0,
          monthlyExpense: 200.0,
          topAccounts: [],
          recentTransactions: [],
          isLoading: false,
        ),
      ],
    );
  });
}
