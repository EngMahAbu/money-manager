import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/data/database.dart';
import 'package:money_manager/features/accounts/accounts_screen.dart';
import 'package:money_manager/features/accounts/cubit/accounts_cubit.dart';
import 'package:money_manager/features/categories/cubit/categories_cubit.dart';
import 'package:money_manager/features/settings/cubit/settings_cubit.dart';
import 'package:money_manager/features/transactions/cubit/transactions_cubit.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/repositories/settings_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockAccountRepository accountRepository;
  late MockCategoryRepository categoryRepository;
  late MockTransactionRepository transactionRepository;
  late MockSettingsRepository settingsRepository;

  setUp(() {
    accountRepository = MockAccountRepository();
    categoryRepository = MockCategoryRepository();
    transactionRepository = MockTransactionRepository();
    settingsRepository = MockSettingsRepository();

    when(() => settingsRepository.getDefaultCurrency()).thenReturn('USD');
    when(() => settingsRepository.getAppearance()).thenReturn(null);
    when(() => settingsRepository.getAppLockEnabled()).thenReturn(false);
    when(() => settingsRepository.getDailyReminderEnabled()).thenReturn(false);

    when(() => accountRepository.watchAllAccounts()).thenAnswer(
      (_) => Stream.value([
        Account(
          id: 1,
          name: 'EUR Account',
          type: AccountType.bank,
          currency: 'EUR',
          startingBalance: 100,
          isArchived: false,
        ),
      ]),
    );
    when(
      () => accountRepository.watchAccountBalance(any()),
    ).thenAnswer((_) => Stream.value(100.0));
    when(
      () => accountRepository.watchNetWorth(),
    ).thenAnswer((_) => Stream.value(100.0));
  });

  Widget createWidgetUnderTest() {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AccountRepository>.value(value: accountRepository),
        RepositoryProvider<CategoryRepository>.value(value: categoryRepository),
        RepositoryProvider<TransactionRepository>.value(
          value: transactionRepository,
        ),
        RepositoryProvider<SettingsRepository>.value(value: settingsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AccountsCubit(accountRepository)..loadAccounts(),
          ),
          BlocProvider(
            create: (context) => CategoriesCubit(categoryRepository),
          ),
          BlocProvider(
            create: (context) =>
                TransactionsCubit(transactionRepository, loadInitial: false),
          ),
          BlocProvider(create: (context) => SettingsCubit(settingsRepository)),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: AccountsScreen(),
        ),
      ),
    );
  }

  testWidgets('AccountsScreen displays EUR account with € symbol', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.textContaining('€'), findsOneWidget);
    expect(find.textContaining('EUR Account'), findsOneWidget);
    expect(find.textContaining('Bank account · EUR'), findsOneWidget);
  });
}
