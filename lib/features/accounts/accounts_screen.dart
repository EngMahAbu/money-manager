import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/theme/theme_constants.dart';
import '../../shared/widgets/list_row.dart';
import 'cubit/accounts_cubit.dart';
import 'cubit/accounts_state.dart';
import 'add_edit_account_screen.dart';
import 'account_detail_screen.dart';

import '../../repositories/account_repository.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  bool _isArchivedExpanded = false;

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
        title: Text(l10n.accounts),
        actions: [
          IconButton(
            icon: const Icon(TablerIcons.plus, color: AppColors.accent),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddEditAccountScreen(),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AccountsCubit, AccountsState>(
        builder: (context, state) {
          if (state is AccountsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AccountsLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeConstants.cardPadding),
              child: Column(
                children: [
                  // Net Worth Card
                  StreamBuilder<double>(
                    stream: accountRepository.watchNetWorth(),
                    initialData: 0,
                    builder: (context, snapshot) {
                      final netWorth = snapshot.data ?? 0;
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
                            Text(l10n.netWorth, style: AppTextStyles.label),
                            const SizedBox(height: 4),
                            Text(
                              '\$${netWorth.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              style: AppTextStyles.netWorth,
                            ),
                          ],
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 20),

                  // Active Accounts List
                  ...state.activeAccounts.map((account) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: StreamBuilder<double>(
                          stream: accountRepository.watchAccountBalance(account.id),
                          initialData: account.startingBalance,
                          builder: (context, snapshot) {
                            final balance = snapshot.data ?? account.startingBalance;
                            return ListRow(
                              leading: Icon(_getAccountIcon(account.type), size: 20, color: AppColors.textSecondary),
                              label: account.name,
                              subtitle: _getAccountTypeLabel(account.type, l10n),
                              value: '\$${balance.toStringAsFixed(0)}',
                              valueColor: balance < 0 ? AppColors.dangerText : null,
                              trailing: const Icon(TablerIcons.chevron_right, size: 16, color: AppColors.textMuted),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AccountDetailScreen(account: account),
                                  ),
                                );
                              },
                            );
                          }
                        ),
                      )),

                  // Archived Section
                  if (state.archivedAccounts.isNotEmpty) ...[
                    const Divider(height: 32),
                    GestureDetector(
                      onTap: () => setState(() => _isArchivedExpanded = !_isArchivedExpanded),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.archivedWithCount(state.archivedAccounts.length),
                              style: AppTextStyles.label,
                            ),
                            Icon(
                              _isArchivedExpanded ? TablerIcons.chevron_up : TablerIcons.chevron_down,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isArchivedExpanded)
                      ...state.archivedAccounts.map((account) => Opacity(
                            opacity: 0.6,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: StreamBuilder<double>(
                                stream: accountRepository.watchAccountBalance(account.id),
                                initialData: account.startingBalance,
                                builder: (context, snapshot) {
                                  final balance = snapshot.data ?? account.startingBalance;
                                  return ListRow(
                                    leading: Icon(_getAccountIcon(account.type), size: 20, color: AppColors.textMuted),
                                    label: account.name,
                                    subtitle: '${_getAccountTypeLabel(account.type, l10n)} · archived',
                                    value: '\$${balance.toStringAsFixed(0)}',
                                    trailing: TextButton(
                                      onPressed: () => context.read<AccountsCubit>().restoreAccount(account.id),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        l10n.restore,
                                        style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w500, fontSize: 12),
                                      ),
                                    ),
                                  );
                                }
                              ),
                            ),
                          )),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
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
