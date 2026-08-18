import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/theme/theme_constants.dart';
import '../../shared/widgets/filter_chip.dart';
import '../categories/cubit/categories_cubit.dart';
import '../categories/cubit/categories_state.dart';
import 'cubit/reports_cubit.dart';
import 'cubit/reports_state.dart';
import '../../data/daos.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
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
                _buildSpendingByCategory(state, l10n),
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

  Widget _buildFilters(AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          AppFilterChip(
            label: l10n.last6Months,
            isActive: true,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          AppFilterChip(
            label: l10n.allAccounts,
            isActive: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeVsExpense(ReportsState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.incomeVsExpense, style: AppTextStyles.sectionHeader),
        const SizedBox(height: 24),
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxValue(state.monthlyIncomeSeries, state.monthlyExpenseSeries) * 1.2,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value >= state.monthlyIncomeSeries.length) return const SizedBox();
                      final date = state.monthlyIncomeSeries[value.toInt()].date;
                      final isLast = value.toInt() == state.monthlyIncomeSeries.length - 1;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('MMM').format(date),
                          style: AppTextStyles.muted.copyWith(
                            fontSize: 10,
                            color: isLast ? AppColors.accent : AppColors.textMuted,
                            fontWeight: isLast ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(state.monthlyIncomeSeries.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: state.monthlyIncomeSeries[index].value,
                      color: AppColors.success,
                      width: 8,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                    ),
                    BarChartRodData(
                      toY: state.monthlyExpenseSeries[index].value,
                      color: AppColors.danger,
                      width: 8,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                    ),
                  ],
                );
              }),
            ),
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

  Widget _buildSpendingByCategory(ReportsState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.spendingByCategory, style: AppTextStyles.sectionHeader),
        const SizedBox(height: 24),
        BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, catState) {
            if (catState is! CategoriesLoaded) return const SizedBox();
            
            final breakdown = state.categoryBreakdown;
            if (breakdown.isEmpty) return const Center(child: Text('No data'));

            final sortedCategories = breakdown.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final total = breakdown.values.fold(0.0, (sum, v) => sum + v);

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
                            final colorSet = AppColors.chartRamp[index % AppColors.chartRamp.length];
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
                      final category = [...catState.incomeCategories, ...catState.expenseCategories, ...catState.archivedCategories]
                          .firstWhere((c) => c.id == entry.key);
                      final percentage = state.categoryPercentages[entry.key] ?? 0;
                      final colorSet = AppColors.chartRamp[index % AppColors.chartRamp.length];

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
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MMM').format(state.balanceTrend.first.date),
                            style: AppTextStyles.muted.copyWith(fontSize: 10),
                          ),
                        );
                      }
                      if (value == state.balanceTrend.length - 1) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MMM').format(state.balanceTrend.last.date),
                            style: AppTextStyles.muted.copyWith(fontSize: 10),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
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
                      if (index == state.balanceTrend.length - 1) {
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
      ],
    );
  }
}
