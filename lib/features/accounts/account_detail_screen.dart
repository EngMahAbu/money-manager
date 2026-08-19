import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/theme/theme_constants.dart';
import '../../shared/utils/category_colors.dart';
import '../../shared/utils/icon_mapper.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/transaction_row.dart';
import '../../shared/widgets/section_header.dart';
import '../categories/cubit/categories_cubit.dart';
import '../categories/cubit/categories_state.dart';
import '../transactions/cubit/transactions_cubit.dart';
import '../transactions/cubit/transactions_state.dart';
import '../transactions/transaction_detail_screen.dart';
import '../transactions/transactions_screen.dart';
import 'add_edit_account_screen.dart';
import '../../repositories/account_repository.dart';

class AccountDetailScreen extends StatefulWidget {
  final Account account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionsCubit>().loadTransactions(
      accountIds: [widget.account.id],
    );
  }

  // Calculate monthly income and expense from transactions
  Map<String, double> _calculateMonthlyTotals(List<Transaction> transactions) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    double income = 0.0;
    double expense = 0.0;

    for (final tx in transactions) {
      if (tx.date.isAfter(monthStart) || tx.date.isAtSameMomentAs(monthStart)) {
        if (tx.date.isBefore(monthEnd) || tx.date.isAtSameMomentAs(monthEnd)) {
          if (tx.type == TransactionType.income) {
            income += tx.amount;
          } else if (tx.type == TransactionType.expense) {
            expense += tx.amount;
          }
        }
      }
    }

    return {'income': income, 'expense': expense};
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accountRepository = context.read<AccountRepository>();

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(TablerIcons.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.account.name),
        actions: [
          IconButton(
            icon: const Icon(TablerIcons.pencil, size: 18),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditAccountScreen(account: widget.account),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeConstants.cardPadding),
        child: Column(
          children: [
            // Balance Card
            StreamBuilder<double>(
              stream: accountRepository.watchAccountBalance(widget.account.id),
              initialData: widget.account.startingBalance,
              builder: (context, snapshot) {
                final balance = snapshot.data ?? widget.account.startingBalance;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(ThemeConstants.cardRadius),
                    border: Border.all(color: AppColors.borderDefault, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_getAccountIcon(widget.account.type), size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(_getAccountTypeLabel(widget.account.type, l10n), style: AppTextStyles.label),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${balance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: AppTextStyles.netWorth,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Monthly Summary
            BlocBuilder<TransactionsCubit, TransactionsState>(
              builder: (context, state) {
                double monthlyIncome = 0.0;
                double monthlyExpense = 0.0;

                if (state is TransactionsLoaded) {
                  final totals = _calculateMonthlyTotals(state.transactions);
                  monthlyIncome = totals['income'] ?? 0.0;
                  monthlyExpense = totals['expense'] ?? 0.0;
                }

                return Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: 'This month',
                        value: '+\$${monthlyIncome.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        icon: TablerIcons.arrow_down,
                        isSuccess: true,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        label: 'This month',
                        value: '-\$${monthlyExpense.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        icon: TablerIcons.arrow_up,
                        isSuccess: false,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Transactions Section
            SectionHeader(
              title: l10n.transactions,
              actionLabel: l10n.seeAll,
              onActionPressed: () {
                context.read<TransactionsCubit>().loadTransactions(
                  accountIds: [widget.account.id],
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TransactionsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            BlocBuilder<TransactionsCubit, TransactionsState>(
              builder: (context, state) {
                if (state is TransactionsLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (state is TransactionsLoaded) {
                  final groups = _groupTransactionsByDate(state.transactions);
                  return Column(
                    children: groups.map((group) => _buildDateGroup(group, l10n)).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateGroup(_TransactionGroup group, AppLocalizations l10n) {
    final dateStr = DateUtils.isSameDay(group.date, DateTime.now())
        ? l10n.today
        : DateUtils.isSameDay(group.date, DateTime.now().subtract(const Duration(days: 1)))
            ? l10n.yesterday
            : DateFormat('MMM d').format(group.date);
    
    final categoriesState = context.read<CategoriesCubit>().state;
    final allCategories = categoriesState is CategoriesLoaded 
        ? [...categoriesState.incomeCategories, ...categoriesState.expenseCategories] 
        : <Category>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(dateStr, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w500)),
        ),
        Column(
          children: List.generate(group.transactions.length, (index) {
            final tx = group.transactions[index];
            
            // Get category information
            final category = allCategories.where((c) => c.id == tx.categoryId).firstOrNull;
            final categoryName = category?.name ?? tx.note ?? (tx.type == TransactionType.transfer ? 'Transfer' : (tx.type == TransactionType.income ? 'Income' : 'Expense'));
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
              timestamp: dateStr,
              amount: tx.amount.toStringAsFixed(2),
              isIncome: isIncome,
              isTransfer: isTransfer,
              showDivider: index < group.transactions.length - 1,
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
        ),
      ],
    );
  }

  List<_TransactionGroup> _groupTransactionsByDate(List<Transaction> transactions) {
    final groups = <DateTime, List<Transaction>>{};
    for (final tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (!groups.containsKey(date)) {
        groups[date] = [];
      }
      groups[date]!.add(tx);
    }

    final sortedDates = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    return sortedDates.map((date) {
      return _TransactionGroup(date, groups[date]!);
    }).toList();
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return TablerIcons.wallet;
      case AccountType.bank:
      case AccountType.savings:
        return TablerIcons.building_bank;
      case AccountType.creditCard:
        return TablerIcons.credit_card;
    }
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

class _TransactionGroup {
  final DateTime date;
  final List<Transaction> transactions;
  _TransactionGroup(this.date, this.transactions);
}
