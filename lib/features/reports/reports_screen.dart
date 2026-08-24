import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';

import '../../data/daos.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/theme/theme_constants.dart';
import '../../shared/utils/category_colors.dart';
import '../../shared/widgets/filter_chip.dart';
import '../accounts/cubit/accounts_cubit.dart';
import '../accounts/cubit/accounts_state.dart';
import '../categories/cubit/categories_cubit.dart';
import '../categories/cubit/categories_state.dart';
import '../transactions/widgets/date_range_picker_sheet.dart';
import '../transactions/widgets/multi_select_picker_sheet.dart';
import 'cubit/reports_cubit.dart';
import 'cubit/reports_state.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int? _touchedBarIndex;
  int? _touchedLineIndex;
  TransactionType _breakdownType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    _loadDefaultData();
  }

  void _loadDefaultData() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 5, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);
    context.read<ReportsCubit>().loadReports(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      appBar: AppBar(
        title: Text(l10n.reports),
        centerTitle: false,
      ),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(ThemeConstants.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilters(l10n),
                const SizedBox(height: 24),
                _buildIncomeVsExpense(state, l10n),
                const Divider(height: 48),
                _buildCategoryBreakdown(state, l10n),
                const Divider(height: 48),
                _buildBalanceTrend(state, l10n),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDateRangePicker(ReportsState state) {
    final startDate = state.startDate ?? DateTime.now().subtract(const Duration(days: 180));
    final endDate = state.endDate ?? DateTime.now();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateRangePickerSheet(
        startDate: startDate,
        endDate: endDate,
        onRangeSelected: (start, end) {
          context.read<ReportsCubit>().updateDateRange(start, end);
        },
      ),
    );
  }

  void _showAccountMultiSelect(ReportsState state) {
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
          context.read<ReportsCubit>().updateAccountIds(selectedIds);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildFilters(AppLocalizations l10n) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        final now = DateTime.now();
        final defaultStart = DateTime(now.year, now.month - 5, 1);
        final defaultEnd = DateTime(now.year, now.month + 1, 0);
        final isDefaultDateRange = state.startDate != null && state.endDate != null &&
            DateUtils.isSameDay(state.startDate!, defaultStart) &&
            DateUtils.isSameDay(state.endDate!, defaultEnd);
        final hasAccountFilter = state.accountIds != null && state.accountIds!.isNotEmpty;
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              AppFilterChip(
                label: isDefaultDateRange ? l10n.last6Months : _formatDateRange(state.startDate!, state.endDate!, l10n),
                isActive: !isDefaultDateRange,
                onTap: () => _showDateRangePicker(state),
              ),
              const SizedBox(width: 8),
              AppFilterChip(
                label: hasAccountFilter 
                    ? l10n.filterByAccount
                    : l10n.allAccounts,
                isActive: hasAccountFilter,
                onTap: () => _showAccountMultiSelect(state),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateRange(DateTime start, DateTime end, AppLocalizations l10n) {
    final now = DateTime.now();
    final defaultStart = DateTime(now.year, now.month - 5, 1);
    final defaultEnd = DateTime(now.year, now.month + 1, 0);
    
    if (DateUtils.isSameDay(start, defaultStart) && DateUtils.isSameDay(end, defaultEnd)) {
      return l10n.last6Months;
    }
    return '${DateFormat('MMM d, yyyy').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
  }

  Widget _buildIncomeVsExpense(ReportsState state, AppLocalizations l10n) {
    final maxValue = _getMaxValue(
        state.monthlyIncomeSeries, state.monthlyExpenseSeries);
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.incomeVsExpense, style: AppTextStyles.sectionHeader),
        const SizedBox(height: 24),
        SizedBox(
          height: 180,
          child: Stack(
            children: [
              // Min/Max Labels
              Positioned(
                top: 0,
                left: 0,
                child: Text(
                  currencyFormat.format(maxValue),
                  style: AppTextStyles.muted.copyWith(fontSize: 10),
                ),
              ),
              Positioned(
                bottom: 38, // Adjusted for x-axis labels
                left: 0,
                child: Text(
                  currencyFormat.format(0),
                  style: AppTextStyles.muted.copyWith(fontSize: 10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 44.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxValue * 1.2,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.textPrimary,
                        tooltipRoundedRadius: 6,
                        tooltipPadding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 4),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            currencyFormat.format(rod.toY),
                            AppTextStyles.body.copyWith(
                              color: AppColors.surfacePage,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                      touchCallback: (FlTouchEvent event, barTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              barTouchResponse == null ||
                              barTouchResponse.spot == null) {
                            _touchedBarIndex = -1;
                            return;
                          }
                          _touchedBarIndex =
                              barTouchResponse.spot!.touchedBarGroupIndex;
                        });
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value < 0 ||
                                value >= state.monthlyIncomeSeries.length) {
                              return const SizedBox();
                            }
                            final date = state.monthlyIncomeSeries[value
                                .toInt()].date;
                            final isTouched = value.toInt() == _touchedBarIndex;
                            final isLast = value.toInt() ==
                                state.monthlyIncomeSeries.length - 1 &&
                                _touchedBarIndex == -1;

                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('MMM').format(date),
                                style: AppTextStyles.muted.copyWith(
                                  fontSize: 10,
                                  color: (isTouched || isLast) ? AppColors
                                      .accent : AppColors.textMuted,
                                  fontWeight: (isTouched || isLast) ? FontWeight
                                      .w500 : FontWeight.w400,
                                ),
                              ),
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                        state.monthlyIncomeSeries.length, (index) {
                      final isTouched = index == _touchedBarIndex;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: state.monthlyIncomeSeries[index].value,
                            color: AppColors.success,
                            width: 8,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(2)),
                            borderSide: isTouched
                                ? const BorderSide(
                                color: AppColors.textPrimary, width: 1.5)
                                : const BorderSide(
                                color: Colors.transparent, width: 0),
                          ),
                          BarChartRodData(
                            toY: state.monthlyExpenseSeries[index].value,
                            color: AppColors.danger,
                            width: 8,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(2)),
                            borderSide: isTouched
                                ? const BorderSide(
                                color: AppColors.textPrimary, width: 1.5)
                                : const BorderSide(
                                color: Colors.transparent, width: 0),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildLegendItem(l10n.income, AppColors.success),
            const SizedBox(width: 16),
            _buildLegendItem(l10n.expense, AppColors.danger),
          ],
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            l10n.barChartHint,
            style: AppTextStyles.muted.copyWith(fontSize: 10),
          ),
        ),
      ],
    );
  }

  double _getMaxValue(List<DateTimeDouble> s1, List<DateTimeDouble> s2) {
    double max = 0;
    for (var d in s1) { if (d.value > max) max = d.value; }
    for (var d in s2) { if (d.value > max) max = d.value; }
    return max == 0 ? 1000 : max;
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.muted.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _buildTypeToggle(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceInner,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleItem(
              label: l10n.expense,
              isSelected: _breakdownType == TransactionType.expense,
              onTap: () =>
                  setState(() => _breakdownType = TransactionType.expense),
              activeColor: AppColors.danger,
              activeTextColor: AppColors.dangerText,
              activeBgColor: AppColors.dangerContainer,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildToggleItem(
              label: l10n.income,
              isSelected: _breakdownType == TransactionType.income,
              onTap: () =>
                  setState(() => _breakdownType = TransactionType.income),
              activeColor: AppColors.success,
              activeTextColor: AppColors.successText,
              activeBgColor: AppColors.successContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
    required Color activeTextColor,
    required Color activeBgColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? activeTextColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(ReportsState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.byCategory, style: AppTextStyles.sectionHeader),
        const SizedBox(height: 12),
        _buildTypeToggle(l10n),
        const SizedBox(height: 24),
        BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, catState) {
            if (catState is! CategoriesLoaded) return const SizedBox();

            final breakdown = _breakdownType == TransactionType.expense
                ? state.expenseBreakdown
                : state.incomeBreakdown;
            final percentages = _breakdownType == TransactionType.expense
                ? state.expensePercentages
                : state.incomePercentages;

            if (breakdown.isEmpty) return const Center(child: Text('No data'));

            final sortedCategories = breakdown.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final total = breakdown.values.fold(0.0, (sum, v) => sum + v);
            final allCategories = [
              ...catState.incomeCategories,
              ...catState.expenseCategories,
              ...catState.archivedCategories
            ];

            return Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 35,
                          sections: List.generate(sortedCategories.length, (index) {
                            final entry = sortedCategories[index];
                            final colorSet = getCategoryRampColor(
                                entry.key, allCategories);
                            return PieChartSectionData(
                              color: colorSet.fill,
                              value: entry.value,
                              radius: 15,
                              showTitle: false,
                            );
                          }),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${total.toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                              style: AppTextStyles.label.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            Text(l10n.total, style: AppTextStyles.muted.copyWith(fontSize: 8)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: List.generate(sortedCategories.length, (index) {
                      final entry = sortedCategories[index];
                      final category = allCategories.firstWhere((c) =>
                      c.id == entry.key);
                      final percentage = percentages[entry.key] ?? 0;
                      final colorSet = getCategoryRampColor(
                          entry.key, allCategories);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: colorSet.fill, borderRadius: BorderRadius.circular(2)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(category.name, style: AppTextStyles.body.copyWith(fontSize: 12)),
                            ),
                            Text('${percentage.toInt()}%', style: AppTextStyles.muted.copyWith(fontSize: 12)),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildBalanceTrend(ReportsState state, AppLocalizations l10n) {
    if (state.balanceTrend.isEmpty) return const SizedBox();
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.balanceTrend, style: AppTextStyles.sectionHeader),
        const SizedBox(height: 24),
        SizedBox(
          height: 100,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.textPrimary,
                  tooltipRoundedRadius: 6,
                  tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 4),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        currencyFormat.format(spot.y),
                        AppTextStyles.body.copyWith(
                          color: AppColors.surfacePage,
                          fontSize: 10,
                        ),
                      );
                    }).toList();
                  },
                ),
                touchCallback: (FlTouchEvent event, lineTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        lineTouchResponse == null ||
                        lineTouchResponse.lineBarSpots == null) {
                      _touchedLineIndex = -1;
                      return;
                    }
                    _touchedLineIndex =
                        lineTouchResponse.lineBarSpots!.first.spotIndex;
                  });
                },
                handleBuiltInTouches: true,
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return Padding(
                          padding: const EdgeInsetsGeometry.directional(
                              top: 8.0, start: 32.0),
                          child: Text(
                            '${DateFormat('MMM').format(state.balanceTrend.first
                                .date)} · ${currencyFormat.format(
                                state.balanceTrend.first.value)}',
                            style: AppTextStyles.muted.copyWith(fontSize: 9),
                          ),
                        );
                      }
                      if (value == state.balanceTrend.length - 1) {
                        return Padding(
                          padding: const EdgeInsetsGeometry.directional(
                              top: 8.0, end: 32.0),
                          child: Text(
                            '${DateFormat('MMM').format(state.balanceTrend.last
                                .date)} · ${currencyFormat.format(
                                state.balanceTrend.last.value)}',
                            style: AppTextStyles.muted.copyWith(fontSize: 9),
                            textAlign: TextAlign.end,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(state.balanceTrend.length, (index) {
                    return FlSpot(index.toDouble(), state.balanceTrend[index].value);
                  }),
                  isCurved: true,
                  color: AppColors.accent,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      final isTouched = index == _touchedLineIndex;
                      final isLast = index == state.balanceTrend.length - 1 &&
                          _touchedLineIndex == -1;

                      if (isTouched || isLast) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.accent,
                          strokeWidth: 2,
                          strokeColor: AppColors.surfacePage,
                        );
                      }
                      return FlDotCirclePainter(radius: 0);
                    },
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            l10n.lineChartHint,
            style: AppTextStyles.muted.copyWith(fontSize: 10),
          ),
        ),
      ],
    );
  }
}
