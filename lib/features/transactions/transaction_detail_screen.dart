import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/theme/theme_constants.dart';
import '../../shared/utils/icon_mapper.dart';
import '../accounts/cubit/accounts_cubit.dart';
import '../accounts/cubit/accounts_state.dart';
import '../categories/cubit/categories_cubit.dart';
import '../categories/cubit/categories_state.dart';
import 'add_edit_transaction_screen.dart';
import 'cubit/transactions_cubit.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTransfer = transaction.type == TransactionType.transfer;
    final isIncome = transaction.type == TransactionType.income;

    // Get type-based colors (not ramp colors - per design system exception)
    final typeColor = isTransfer
        ? AppColors.accent
        : (isIncome ? AppColors.success : AppColors.danger);
    final typeContainerColor = isTransfer
        ? AppColors.accentContainer
        : (isIncome ? AppColors.successContainer : AppColors.dangerContainer);
    final typeTextColor = isTransfer
        ? AppColors.accentText
        : (isIncome ? AppColors.successText : AppColors.dangerText);

    // Get category name
    final categoriesState = context.read<CategoriesCubit>().state;
    final allCategories = categoriesState is CategoriesLoaded
        ? [
            ...categoriesState.incomeCategories,
            ...categoriesState.expenseCategories,
          ]
        : <Category>[];
    final category = allCategories
        .where((c) => c.id == transaction.categoryId)
        .firstOrNull;
    final categoryName = isTransfer
        ? l10n.transfer
        : (category?.name ?? l10n.uncategorized);

    // Get category icon for non-transfer transactions
    final headerIcon = isTransfer
        ? TablerIcons.arrow_right
        : getTablerIcon(category?.icon);

    // Get accounts for From/To display
    final accountsState = context.read<AccountsCubit>().state;
    final accounts = accountsState is AccountsLoaded
        ? accountsState.activeAccounts
        : <Account>[];
    final fromAccount = accounts
        .where((a) => a.id == transaction.accountId)
        .firstOrNull;
    final toAccount = transaction.toAccountId != null
        ? accounts.where((a) => a.id == transaction.toAccountId).firstOrNull
        : null;

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            TablerIcons.arrow_left,
            size: 20,
            color: AppColors.textSecondary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              TablerIcons.pencil,
              size: 19,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditTransactionScreen(transaction: transaction),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(TablerIcons.trash, size: 19, color: AppColors.danger),
            onPressed: () => _showDeleteDialog(context, l10n),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeConstants.cardPadding),
        child: Column(
          children: [
            // Header block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(ThemeConstants.cardRadius),
                border: Border.all(color: AppColors.borderDefault, width: 0.5),
              ),
              child: Column(
                children: [
                  // Header with icon, amount, and category
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        // Category icon badge - type-colored (not ramp-colored)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: typeContainerColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            headerIcon,
                            size: 22,
                            color: typeTextColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Amount - no sign, color carries direction
                        Text(
                          '\$${transaction.amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: AppTextStyles.netWorth.copyWith(
                            fontSize: 32,
                            color: typeColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Category name
                        Text(
                          categoryName,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Field rows
                  Column(
                    children: [
                      if (isTransfer) ...[
                        _buildFieldRow(
                          context,
                          icon: TablerIcons.wallet,
                          label: l10n.from,
                          value: fromAccount?.name ?? l10n.unknown,
                        ),
                        const SizedBox(height: 4),
                        _buildFieldRow(
                          context,
                          icon: TablerIcons.arrow_right,
                          label: l10n.to,
                          value: toAccount?.name ?? l10n.unknown,
                        ),
                        const SizedBox(height: 4),
                      ] else ...[
                        _buildFieldRow(
                          context,
                          icon: TablerIcons.wallet,
                          label: l10n.account,
                          value: fromAccount?.name ?? l10n.unknown,
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Date row
                      _buildFieldRow(
                        context,
                        icon: TablerIcons.calendar,
                        label: l10n.date,
                        value: _formatDate(transaction.date, l10n),
                      ),
                      const SizedBox(height: 4),

                      // Note row - always shown
                      _buildFieldRow(
                        context,
                        icon: TablerIcons.note,
                        label: l10n.note,
                        value: transaction.note ?? '',
                        isEmptyPlaceholder: transaction.note == null,
                        emptyText: l10n.noNoteAdded,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Receipts section
                  _buildReceiptsSection(context, transaction, l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isEmptyPlaceholder = false,
    String emptyText = '',
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceInner,
        borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            isEmptyPlaceholder ? emptyText : value,
            style: isEmptyPlaceholder
                ? AppTextStyles.muted.copyWith(fontStyle: FontStyle.italic)
                : AppTextStyles.body,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptsSection(
    BuildContext context,
    Transaction transaction,
    AppLocalizations l10n,
  ) {
    final hasReceipts =
        transaction.receipts != null && transaction.receipts!.isNotEmpty;

    if (!hasReceipts) {
      return _buildFieldRow(
        context,
        icon: TablerIcons.photo,
        label: l10n.receipts,
        value: '',
        isEmptyPlaceholder: true,
        emptyText: l10n.noReceiptsAttached,
      );
    }

    // For now, show receipts placeholder - actual image display would need implementation
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceInner,
        borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(TablerIcons.photo, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Text(
                l10n.receipts,
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _getReceiptCount(transaction.receipts),
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.accentContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    TablerIcons.photo,
                    size: 22,
                    color: AppColors.accentText,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getReceiptCount(String? receipts) {
    if (receipts == null || receipts.isEmpty) return 0;
    // Assuming receipts is a comma-separated list of paths
    return receipts.split(',').length;
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return l10n.today;
    } else if (dateOnly == yesterday) {
      return l10n.yesterday;
    } else {
      final daysDiff = today.difference(dateOnly).inDays;
      if (daysDiff < 7) {
        return l10n.daysAgo(daysDiff);
      } else if (daysDiff < 30) {
        return DateFormat('MMM d').format(date);
      } else {
        return DateFormat('MMM d, yyyy').format(date);
      }
    }
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTransaction),
        content: Text(l10n.deleteTransactionConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<TransactionsCubit>().deleteTransaction(transaction);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
