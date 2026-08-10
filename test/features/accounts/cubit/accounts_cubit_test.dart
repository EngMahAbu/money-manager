import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/features/accounts/cubit/accounts_cubit.dart';
import 'package:money_manager/features/accounts/cubit/accounts_state.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/data/database.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

void main() {
  late AccountRepository repository;
  late AccountsCubit cubit;

  setUp(() {
    repository = MockAccountRepository();
    cubit = AccountsCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  final mockAccounts = [
    Account(id: 1, name: 'Active', type: AccountType.bank, isArchived: false, currency: 'USD', startingBalance: 0),
    Account(id: 2, name: 'Archived', type: AccountType.cash, isArchived: true, currency: 'USD', startingBalance: 0),
  ];

  group('AccountsCubit', () {
    blocTest<AccountsCubit, AccountsState>(
      'loadAccounts emits [AccountsLoading, AccountsLoaded] on success',
      build: () {
        when(() => repository.watchAllAccounts()).thenAnswer((_) => Stream.value(mockAccounts));
        return cubit;
      },
      act: (cubit) => cubit.loadAccounts(),
      expect: () => [
        AccountsLoading(),
        AccountsLoaded(
          activeAccounts: [mockAccounts[0]],
          archivedAccounts: [mockAccounts[1]],
        ),
      ],
    );

    blocTest<AccountsCubit, AccountsState>(
      'loadAccounts emits [AccountsLoading, AccountsError] on error',
      build: () {
        when(() => repository.watchAllAccounts()).thenAnswer((_) => Stream.error('Error'));
        return cubit;
      },
      act: (cubit) => cubit.loadAccounts(),
      expect: () => [
        AccountsLoading(),
        const AccountsError('Error'),
      ],
    );
  });
}
