import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/theme/theme_constants.dart';
import '../../../shared/widgets/bottom_sheet_header.dart';
import '../../accounts/cubit/accounts_cubit.dart';
import '../../accounts/cubit/accounts_state.dart';
import '../../categories/cubit/categories_cubit.dart';
import '../../categories/cubit/categories_state.dart';

import 'date_range_picker_sheet.dart';

class CombinedFilterSheet extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionType? type;
  final List<int> accountIds;
  final List<int> categoryIds;
  final Function({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    List<int>? accountIds,
    List<int>? categoryIds,
  }) onApply;

  const CombinedFilterSheet({
    super.key,
    this.startDate,
    this.endDate,
    this.type,
    required this.accountIds,
    required this.categoryIds,
    required this.onApply,
  });

  @override
  State<CombinedFilterSheet> createState() => _CombinedFilterSheetState();
}

class _CombinedFilterSheetState extends State<CombinedFilterSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  TransactionType? _type;
  late List<int> _accountIds;
  late List<int> _categoryIds;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _type = widget.type;
    _accountIds = List.from(widget.accountIds);
    _categoryIds = List.from(widget.categoryIds);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Spacer
                  const BottomSheetHeader(title: ''),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                        _type = null;
                        _accountIds.clear();
                        _categoryIds.clear();
                      });
                    },
                    child: Text(l10n.reset, style: const TextStyle(color: AppColors.accent)),
                  ),
                ],
              ),
            ),
            _buildSectionHeader(l10n.dateRange),
            _buildDateRangeSelector(l10n),
            _buildSectionHeader(l10n.type),
            _buildTypeSelector(l10n),
            _buildSectionHeader(l10n.accounts),
            _buildAccountSelector(),
            _buildSectionHeader(l10n.categories),
            _buildCategorySelector(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => widget.onApply(
                    startDate: _startDate,
                    endDate: _endDate,
                    type: _type,
                    accountIds: _accountIds,
                    categoryIds: _categoryIds,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeConstants.innerRadius)),
                    elevation: 0,
                  ),
                  child: Text(l10n.applyFilters),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildDateRangeSelector(AppLocalizations l10n) {
    final rangeText = _startDate != null && _endDate != null
        ? '${DateFormat('MMM d').format(_startDate!)} – ${DateFormat('MMM d, yyyy').format(_endDate!)}'
        : 'All time';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => DateRangePickerSheet(
              startDate: _startDate,
              endDate: _endDate,
              onRangeSelected: (start, end) {
                setState(() {
                  _startDate = start;
                  _endDate = end;
                });
                Navigator.pop(context);
              },
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceInner,
            borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rangeText, style: AppTextStyles.body),
              const Icon(TablerIcons.chevron_right, size: 14, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTypeButton(TransactionType.expense, l10n.expense, AppColors.danger),
          const SizedBox(width: 8),
          _buildTypeButton(TransactionType.income, l10n.income, AppColors.success),
        ],
      ),
    );
  }

  Widget _buildTypeButton(TransactionType type, String label, Color activeColor) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = isSelected ? null : type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.1) : AppColors.surfaceInner,
            borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
            border: isSelected ? Border.all(color: activeColor, width: 0.5) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: isSelected ? activeColor : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSelector() {
    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        final accounts = state is AccountsLoaded ? state.activeAccounts : <Account>[];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: accounts.map((account) {
              final isSelected = _accountIds.contains(account.id);
              return _buildFilterChip(
                label: account.name,
                isSelected: isSelected,
                onTap: () => setState(() {
                  isSelected ? _accountIds.remove(account.id) : _accountIds.add(account.id);
                }),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        final categories = state is CategoriesLoaded 
            ? [...state.incomeCategories, ...state.expenseCategories]
            : <Category>[];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              final isSelected = _categoryIds.contains(cat.id);
              return _buildFilterChip(
                label: cat.name,
                isSelected: isSelected,
                onTap: () => setState(() {
                  isSelected ? _categoryIds.remove(cat.id) : _categoryIds.add(cat.id);
                }),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentContainer : AppColors.surfaceInner,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: AppColors.accent, width: 0.5) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isSelected ? AppColors.accentText : AppColors.textSecondary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(TablerIcons.check, size: 12, color: AppColors.accentText),
            ],
          ],
        ),
      ),
    );
  }
}
