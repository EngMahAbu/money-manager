import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/daos.dart';
import 'data/database.dart';
import 'features/accounts/cubit/accounts_cubit.dart';
import 'features/accounts/cubit/accounts_state.dart';
import 'features/categories/cubit/categories_cubit.dart';
import 'features/dashboard/cubit/dashboard_cubit.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/reports/cubit/reports_cubit.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'features/transactions/cubit/transactions_cubit.dart';
import 'l10n/app_localizations.dart';
import 'repositories/account_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/settings_repository.dart';
import 'repositories/transaction_repository.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  final dao = AppDao(database);
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(
    accountRepository: AccountRepository(dao),
    categoryRepository: CategoryRepository(dao),
    transactionRepository: TransactionRepository(dao),
    settingsRepository: SettingsRepository(prefs),
  ));
}

class MyApp extends StatelessWidget {
  final AccountRepository accountRepository;
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;
  final SettingsRepository settingsRepository;

  const MyApp({
    super.key,
    required this.accountRepository,
    required this.categoryRepository,
    required this.transactionRepository,
    required this.settingsRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: accountRepository),
        RepositoryProvider.value(value: categoryRepository),
        RepositoryProvider.value(value: transactionRepository),
        RepositoryProvider.value(value: settingsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AccountsCubit(accountRepository)..loadAccounts(),
          ),
          BlocProvider(
            create: (context) => CategoriesCubit(categoryRepository)..loadCategories(),
          ),
          BlocProvider(
            create: (context) => TransactionsCubit(transactionRepository),
          ),
          BlocProvider(
            create: (context) => DashboardCubit(accountRepository, transactionRepository),
          ),
          BlocProvider(
            create: (context) => ReportsCubit(transactionRepository),
          ),
          BlocProvider(
            create: (context) =>
            SettingsCubit(settingsRepository)
              ..loadSettings(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
          theme: AppTheme.light,
          home: const AppGate(),
        ),
      ),
    );
  }
}

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        if (state is AccountsLoading || state is AccountsInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AccountsLoaded) {
          if (state.activeAccounts.isEmpty) {
            return const OnboardingScreen();
          } else {
            return const HomeScreen();
          }
        }

        if (state is AccountsError) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
