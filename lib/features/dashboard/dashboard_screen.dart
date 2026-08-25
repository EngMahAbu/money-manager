import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../repositories/account_repository.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/theme/theme_constants.dart';
import '../../shared/utils/category_colors.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/utils/icon_mapper.dart';
import '../../shared/widgets/list_row.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/transaction_row.dart';
import '../accounts/account_detail_screen.dart';
import '../accounts/accounts_screen.dart';
import '../categories/cubit/categories_cubit.dart';
import '../categories/cubit/categories_state.dart';
import '../transactions/transaction_detail_screen.dart';
import '../transactions/transactions_screen.dart';
import 'cubit/dashboard_cubit.dart';
import 'cubit/dashboard_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accountRepository = context.read<AccountRepository>();

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeConstants.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Net Worth Block
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalNetWorth,
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${state.netWorth.toStringAsFixed(2).replaceAllMapped(
                            RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (
                            Match m) => "${m[1]},")}',
                        style: AppTextStyles.netWorth,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Raw sum across currencies — no conversion applied',
                        style: AppTextStyles.muted,
                      ),
                    ],
                  ),
                  const SizedBox(height: ThemeConstants.sectionSpacing),

                  // Income/Expense Grid
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          label: l10n.income,
                          value: '\$${state.monthlyIncome
                              .toStringAsFixed(2)
                              .replaceAllMapped(
                              RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (
                              Match m) => "${m[1]},")}',
                          icon: TablerIcons.arrow_down,
                          isSuccess: true,
                        ),
                      ),
                      const SizedBox(width: ThemeConstants.statCardGap),
                      Expanded(
                        child: MetricCard(
                          label: l10n.expense,
                          value: '\$${state.monthlyExpense
                              .toStringAsFixed(2)
                              .replaceAllMapped(
                              RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (
                              Match m) => "${m[1]},")}',
                          icon: TablerIcons.arrow_up,
                          isSuccess: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ThemeConstants.sectionSpacing),

                  // Accounts Section
                  SectionHeader(
                    title: l10n.accounts,
                    onActionPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const AccountsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(ThemeConstants.cardRadius),
                      border: Border.all(color: AppColors.borderDefault, width: 0.5),
                    ),
                    child: Column(
                      children: List.generate(state.topAccounts.length, (index) {
                        final account = state.topAccounts[index];
                        IconData accountIcon;
                        switch (account.type) {
                          case AccountType.cash:
                            accountIcon = TablerIcons.wallet;
                            break;
                          case AccountType.bank:
                          case AccountType.savings:
                            accountIcon = TablerIcons.building_bank;
                            break;
                          case AccountType.creditCard:
                            accountIcon = TablerIcons.credit_card;
                            break;
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: index == state.topAccounts.length - 1 ? 0 : 8),
                          child: StreamBuilder<double>(
                            stream: accountRepository.watchAccountBalance(account.id),
                            initialData: account.startingBalance,
                            builder: (context, snapshot) {
                              final balance = snapshot.data ?? account.startingBalance;
                              return ListRow(
                                leading: Icon(accountIcon, size: 18, color: AppColors.textSecondary),
                                label: account.name,
                                subtitle: '${_getAccountTypeLabel(
                                    account.type, l10n)} · ${account.currency}',
                                value: CurrencyFormatter.format(
                                    balance, account.currency),
                                valueColor: balance < 0 ? AppColors.dangerText : null,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => AccountDetailScreen(account: account)),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: ThemeConstants.sectionSpacing),

                  // Recent Transactions Section
                  SectionHeader(
                    title: l10n.recentTransactions,
                    onActionPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TransactionsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(ThemeConstants.cardRadius),
                      border: Border.all(color: AppColors.borderDefault, width: 0.5),
                    ),
                    child: BlocBuilder<CategoriesCubit, CategoriesState>(
                      builder: (context, categoriesState) {
                        final allCategories = categoriesState is CategoriesLoaded 
                            ? [...categoriesState.incomeCategories, ...categoriesState.expenseCategories] 
                            : <Category>[];
                        
                        return Column(
                          children: List.generate(state.recentTransactions.length, (index) {
                            final tx = state.recentTransactions[index];
                            final account = state.topAccounts
                                .where((a) => a.id == tx.accountId)
                                .firstOrNull;

                            // Get category information
                            final category = allCategories.where((c) => c.id == tx.categoryId).firstOrNull;
                            final categoryName = category?.name ?? tx.note ??
                                (tx.type == TransactionType.transfer
                                    ? "Transfer"
                                    : (tx.type == TransactionType.income
                                    ? "Income"
                                    : "Expense"));
                            final categoryIcon = getTablerIcon(category?.icon);
                            final isTransfer = tx.type == TransactionType.transfer;
                            final isIncome = tx.type == TransactionType.income;
                            
                            // Get ramp color for category
                            final rampColor = getCategoryRampColor(tx.categoryId, allCategories);
                            
                            // For transfers without a category, use accent color
                            final avatarBgColor = isTransfer && category == null 
                                ? AppColors.accentContainer 
                                : rampColor.container;
                            final avatarIconColor = isTransfer && category == null 
                                ? AppColors.accentText 
                                : rampColor.text;
                            
                            // Bar color based on transaction type
                            final barColor = isTransfer 
                                ? AppColors.accent 
                                : (isIncome ? AppColors.success : AppColors.danger);

                            return TransactionRow(
                              icon: categoryIcon,
                              name: categoryName,
                              timestamp: DateFormat("MMM d").format(tx.date),
                              amount: tx.amount,
                              currencyCode: account?.currency,
                              isIncome: isIncome,
                              isTransfer: isTransfer,
                              showDivider: index != state.recentTransactions.length - 1,
                              barColor: barColor,
                              avatarBackgroundColor: avatarBgColor,
                              avatarIconColor: avatarIconColor,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => TransactionDetailScreen(transaction: tx),
                                  ),
                                );
                              },
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getAccountTypeLabel(AccountType type, AppLocalizations l10n) {
    switch (type) {
      case AccountType.cash:
        return l10n.cashAccount;
      case AccountType.bank:
        return l10n.bankAccount;
      case AccountType.creditCard:
        return l10n.creditCardAccount;
      case AccountType.savings:
        return l10n.savingsAccount;
    }
  }
}
