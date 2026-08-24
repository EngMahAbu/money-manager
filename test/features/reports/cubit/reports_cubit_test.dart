import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/data/database.dart';
import 'package:money_manager/features/reports/cubit/reports_cubit.dart';
import 'package:money_manager/features/reports/cubit/reports_state.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(TransactionType.income);
  });

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
        when(() => transactionRepository.watchPeriodTotal(any(), any(), any()))
            .thenAnswer((_) => Stream.value(100.0));
        when(() =>
            transactionRepository.watchCategoryBreakdown(
                any(), any(), any(), type: any(named: 'type'))).thenAnswer((
            _) =>
            Stream.value({
          1: 33.333,
          2: 33.333,
          3: 33.334,
        }));
        when(() => transactionRepository.watchBalanceTrend(any(), any(), any())).thenAnswer((_) => Stream.value([]));
        when(() =>
            transactionRepository.watchMonthlyTotals(any(), any(), any()))
            .thenAnswer((_) => Stream.value([]));
        return cubit;
      },
      act: (cubit) => cubit.loadReports(startDate: DateTime(2023, 1, 1), endDate: DateTime(2023, 1, 31)),
      expect: () => [
        isA<ReportsState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ReportsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.totalIncome, 'totalIncome', 100.0)
            .having((s) => s.incomePercentages, 'incomePercentages', {
          1: 33.0,
          2: 33.0,
          3: 34.0,
        }),
      ],
    );
  });
}
