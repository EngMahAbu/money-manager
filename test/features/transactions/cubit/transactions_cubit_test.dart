import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/features/transactions/cubit/transactions_cubit.dart';
import 'package:money_manager/features/transactions/cubit/transactions_state.dart';
import 'package:money_manager/repositories/transaction_repository.dart';
import 'package:money_manager/data/database.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late TransactionRepository repository;
  late TransactionsCubit cubit;

  setUp(() {
    repository = MockTransactionRepository();
    cubit = TransactionsCubit(repository);
  });

  final mockTransactions = [
    Transaction(id: 1, accountId: 1, type: TransactionType.expense, amount: 10, date: DateTime(2023, 1, 1)),
  ];

  group('TransactionsCubit', () {
    blocTest<TransactionsCubit, TransactionsState>(
      'loadTransactions emits [TransactionsLoading, TransactionsLoaded] on success',
      build: () {
        when(() => repository.watchFilteredTransactions(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              accountIds: any(named: 'accountIds'),
              categoryIds: any(named: 'categoryIds'),
              searchQuery: any(named: 'searchQuery'),
            )).thenAnswer((_) => Stream.value(mockTransactions));
        return cubit;
      },
      act: (cubit) => cubit.loadTransactions(),
      expect: () => [
        TransactionsLoading(),
        TransactionsLoaded(transactions: mockTransactions),
      ],
    );
  });
}
