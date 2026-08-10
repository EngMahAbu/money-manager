import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/features/reports/cubit/reports_cubit.dart';
import 'package:money_manager/features/reports/cubit/reports_state.dart';
import 'package:money_manager/repositories/transaction_repository.dart';
import 'package:money_manager/data/database.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late TransactionRepository transactionRepository;
  late ReportsCubit cubit;

  setUp(() {
    transactionRepository = MockTransactionRepository();
    cubit = ReportsCubit(transactionRepository);
  });

  group('ReportsCubit', () {
    blocTest<ReportsCubit, ReportsState>(
      'loadReports emits correct state with rounded percentages',
      build: () {
        when(() => transactionRepository.watchPeriodTotal(any(), any(), TransactionType.income)).thenAnswer((_) => Stream.value(100.0));
        when(() => transactionRepository.watchPeriodTotal(any(), any(), TransactionType.expense)).thenAnswer((_) => Stream.value(100.0));
        when(() => transactionRepository.watchCategoryBreakdown(any(), any(), any())).thenAnswer((_) => Stream.value({
          1: 33.333,
          2: 33.333,
          3: 33.334,
        }));
        when(() => transactionRepository.watchBalanceTrend(any(), any(), any())).thenAnswer((_) => Stream.value([]));
        return cubit;
      },
      act: (cubit) => cubit.loadReports(startDate: DateTime(2023, 1, 1), endDate: DateTime(2023, 1, 31)),
      expect: () => [
        const ReportsState(isLoading: true),
        const ReportsState(
          totalIncome: 100.0,
          totalExpense: 100.0,
          categoryBreakdown: {1: 33.333, 2: 33.333, 3: 33.334},
          categoryPercentages: {1: 33.0, 2: 33.0, 3: 34.0}, // Largest remainder rounding
          balanceTrend: [],
          isLoading: false,
        ),
      ],
    );
  });
}
