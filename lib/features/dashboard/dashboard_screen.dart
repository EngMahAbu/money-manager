import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/theme/theme_constants.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/list_row.dart';
import '../../shared/widgets/transaction_row.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../transactions/add_edit_transaction_screen.dart';
import 'cubit/dashboard_cubit.dart';
import 'cubit/dashboard_state.dart';
import '../../data/database.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                        '\$${state.netWorth.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: AppTextStyles.netWorth,
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
                          value: '\$${state.monthlyIncome.toStringAsFixed(0)}',
                          icon: TablerIcons.arrow_down,
                          isSuccess: true,
                        ),
                      ),
                      const SizedBox(width: ThemeConstants.statCardGap),
                      Expanded(
                        child: MetricCard(
                          label: l10n.expense,
                          value: '\$${state.monthlyExpense.toStringAsFixed(0)}',
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
                      // TODO: Navigate to Accounts screen
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
                          child: ListRow(
                            leading: Icon(accountIcon, size: 18, color: AppColors.textSecondary),
                            label: account.name,
                            value: '\$${account.startingBalance.toStringAsFixed(0)}',
                            valueColor: account.startingBalance < 0 ? AppColors.dangerText : null,
                            onTap: () {
                              // TODO: Navigate to Account Detail
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
                      // TODO: Navigate to Transactions screen
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(ThemeConstants.cardRadius),
                      border: Border.all(color: AppColors.borderDefault, width: 0.5),
                    ),
                    child: Column(
                      children: List.generate(state.recentTransactions.length, (index) {
                        final tx = state.recentTransactions[index];
                        return TransactionRow(
                          icon: tx.type == TransactionType.income ? TablerIcons.briefcase : TablerIcons.shopping_cart,
                          name: tx.note ?? (tx.type == TransactionType.income ? 'Income' : 'Expense'),
                          timestamp: 'Today', // TODO: Format date
                          amount: tx.amount.toStringAsFixed(0),
                          isIncome: tx.type == TransactionType.income,
                          isTransfer: tx.type == TransactionType.transfer,
                          showDivider: index != state.recentTransactions.length - 1,
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onQuickAdd: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditTransactionScreen(),
              fullscreenDialog: true,
            ),
          );
        },
      ),
      floatingActionButton: QuickAddFab(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditTransactionScreen(),
              fullscreenDialog: true,
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
