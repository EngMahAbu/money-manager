import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/filter_chip.dart';
import '../../shared/widgets/transaction_row.dart';
import '../accounts/cubit/accounts_cubit.dart';
import '../accounts/cubit/accounts_state.dart';
import '../categories/cubit/categories_cubit.dart';
import '../categories/cubit/categories_state.dart';
import 'cubit/transactions_cubit.dart';
import 'cubit/transactions_state.dart';
import 'widgets/combined_filter_sheet.dart';
import 'widgets/date_range_picker_sheet.dart';
import 'widgets/multi_select_picker_sheet.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // No need to load here, the Cubit handles its own initial load
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDateRangePicker(TransactionsLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateRangePickerSheet(
        startDate: state.startDate,
        endDate: state.endDate,
        onRangeSelected: (start, end) {
          context.read<TransactionsCubit>().loadTransactions(
                startDate: start,
                endDate: end,
                accountIds: state.accountIds,
                categoryIds: state.categoryIds,
              );
        },
      ),
    );
  }

  void _showAccountMultiSelect(TransactionsLoaded state) {
    final accountsCubit = context.read<AccountsCubit>();
    final accounts = accountsCubit.state is AccountsLoaded 
        ? (accountsCubit.state as AccountsLoaded).activeAccounts 
        : <Account>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiSelectPickerSheet(
        title: AppLocalizations.of(context)!.filterByAccount,
        items: accounts.map((a) => MultiSelectItem(id: a.id, label: a.name, icon: TablerIcons.wallet)).toList(),
        initialSelectedIds: state.accountIds ?? [],
        onApply: (selectedIds) {
          context.read<TransactionsCubit>().loadTransactions(
                startDate: state.startDate,
                endDate: state.endDate,
                accountIds: selectedIds,
                categoryIds: state.categoryIds,
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCategoryMultiSelect(TransactionsLoaded state) {
    final categoriesCubit = context.read<CategoriesCubit>();
    final categories = categoriesCubit.state is CategoriesLoaded 
        ? [...(categoriesCubit.state as CategoriesLoaded).incomeCategories, ...(categoriesCubit.state as CategoriesLoaded).expenseCategories]
        : <Category>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiSelectPickerSheet(
        title: AppLocalizations.of(context)!.filterByCategory,
        items: categories.map((c) => MultiSelectItem(id: c.id, label: c.name, icon: TablerIcons.tag)).toList(),
        initialSelectedIds: state.categoryIds ?? [],
        onApply: (selectedIds) {
          context.read<TransactionsCubit>().loadTransactions(
                startDate: state.startDate,
                endDate: state.endDate,
                accountIds: state.accountIds,
                categoryIds: selectedIds,
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showFilterSheet(TransactionsLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CombinedFilterSheet(
        startDate: state.startDate,
        endDate: state.endDate,
        accountIds: state.accountIds ?? [],
        categoryIds: state.categoryIds ?? [],
        onApply: ({startDate, endDate, type, accountIds, categoryIds}) {
          context.read<TransactionsCubit>().loadTransactions(
                startDate: startDate,
                endDate: endDate,
                accountIds: accountIds,
                categoryIds: categoryIds,
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      appBar: _isSearching ? _buildSearchAppBar(l10n) : _buildDefaultAppBar(l10n),
      body: BlocBuilder<TransactionsCubit, TransactionsState>(
        builder: (context, state) {
          if (state is TransactionsLoading || state is TransactionsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionsError) {
            return Center(child: Text(state.message));
          }

          if (state is TransactionsLoaded) {
            final transactions = state.transactions;
            if (transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(TablerIcons.receipt_off, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('No transactions found', style: AppTextStyles.muted),
                  ],
                ),
              );
            }

            final groupedTransactions = _groupTransactionsByDate(transactions);
            final accountIds = state.accountIds;
            final categoryIds = state.categoryIds;
            
            return CustomScrollView(
              key: const PageStorageKey('transactions_scroll_view'),
              slivers: [
                if (!_isSearching)
                  SliverPersistentHeader(
                    pinned: true,
                    key: const ValueKey('filter_header'),
                    delegate: _FilterHeaderDelegate(
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            AppFilterChip(
                              label: state.startDate != null ? 'Filtered Range' : l10n.thisMonth,
                              isActive: state.startDate != null,
                              onTap: () => _showDateRangePicker(state),
                            ),
                            const SizedBox(width: 8),
                            AppFilterChip(
                              label: (accountIds != null && accountIds.length == 1)
                                  ? 'Account selected' 
                                  : (accountIds != null && accountIds.isNotEmpty ? 'Multiple accounts' : l10n.allAccounts),
                              isActive: accountIds != null && accountIds.isNotEmpty,
                              onTap: () => _showAccountMultiSelect(state),
                            ),
                            const SizedBox(width: 8),
                            AppFilterChip(
                              label: (categoryIds != null && categoryIds.isNotEmpty) ? 'Category selected' : l10n.category,
                              isActive: categoryIds != null && categoryIds.isNotEmpty,
                              onTap: () => _showCategoryMultiSelect(state),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_isSearching)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        l10n.results(state.transactions.length),
                        style: AppTextStyles.muted,
                      ),
                    ),
                  ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= groupedTransactions.length) return null;
                      final group = groupedTransactions[index];
                      return _buildDateGroup(group, l10n);
                    },
                    childCount: groupedTransactions.length,
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildDefaultAppBar(AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.transactions),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(TablerIcons.search),
          onPressed: () => setState(() => _isSearching = true),
        ),
        IconButton(
          icon: const Icon(TablerIcons.adjustments_horizontal),
          onPressed: () {
            final state = context.read<TransactionsCubit>().state;
            if (state is TransactionsLoaded) _showFilterSheet(state);
          },
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSearchAppBar(AppLocalizations l10n) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
            context.read<TransactionsCubit>().updateSearch('');
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: l10n.searchTransactions,
          border: InputBorder.none,
        ),
        onChanged: (query) => context.read<TransactionsCubit>().updateSearch(query),
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _searchController.clear();
              context.read<TransactionsCubit>().updateSearch('');
            },
          ),
      ],
    );
  }

  Widget _buildDateGroup(_TransactionGroup group, AppLocalizations l10n) {
    final dateStr = DateUtils.isSameDay(group.date, DateTime.now())
        ? l10n.today
        : DateUtils.isSameDay(group.date, DateTime.now().subtract(const Duration(days: 1)))
            ? l10n.yesterday
            : DateFormat('MMM d').format(group.date);

    final accountsState = context.read<AccountsCubit>().state;
    final accounts = accountsState is AccountsLoaded ? accountsState.activeAccounts : <Account>[];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w500)),
              Text(
                '${group.total >= 0 ? '+' : '-'}\$${group.total.abs().toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: AppTextStyles.label.copyWith(
                  color: group.total >= 0 ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: List.generate(group.transactions.length, (index) {
            final tx = group.transactions[index];
            final account = accounts.where((a) => a.id == tx.accountId).firstOrNull;
            final accountName = account?.name ?? 'Unknown';

            return TransactionRow(
              icon: tx.type == TransactionType.income ? TablerIcons.briefcase : TablerIcons.shopping_cart,
              name: tx.note ?? (tx.type == TransactionType.income ? 'Income' : 'Expense'),
              highlightQuery: _isSearching ? _searchController.text : null,
              timestamp: accountName,
              amount: tx.amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
              isIncome: tx.type == TransactionType.income,
              isTransfer: tx.type == TransactionType.transfer,
              showDivider: true,
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
      groups.putIfAbsent(date, () => []).add(tx);
    }

    final sortedDates = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    return sortedDates.map((date) {
      final txs = groups[date] ?? [];
      double total = 0;
      for (final tx in txs) {
        if (tx.type == TransactionType.income) total += tx.amount;
        if (tx.type == TransactionType.expense) total -= tx.amount;
      }
      return _TransactionGroup(date, txs, total);
    }).toList();
  }
}

class _TransactionGroup {
  final DateTime date;
  final List<Transaction> transactions;
  final double total;
  _TransactionGroup(this.date, this.transactions, this.total);
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _FilterHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: Material(
        color: AppColors.surfacePage,
        child: Container(
          decoration: BoxDecoration(
            border: overlapsContent 
                ? const Border(bottom: BorderSide(color: AppColors.borderStrong, width: 0.5)) 
                : null,
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60;
  @override
  double get minExtent => 60;
  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) => true;
}
