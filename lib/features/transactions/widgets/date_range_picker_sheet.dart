import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/theme/theme_constants.dart';
import '../../../shared/widgets/bottom_sheet_header.dart';
import '../../../l10n/app_localizations.dart';

class DateRangePickerSheet extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime, DateTime) onRangeSelected;

  const DateRangePickerSheet({
    super.key,
    this.startDate,
    this.endDate,
    required this.onRangeSelected,
  });

  @override
  State<DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<DateRangePickerSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _viewMonth = DateTime((_startDate ?? DateTime.now()).year, (_startDate ?? DateTime.now()).month);
  }

  void _onPresetPressed(DateTime start, DateTime end) {
    widget.onRangeSelected(start, end);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomSheetHeader(title: l10n.chooseDateRange),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3,
              children: [
                _buildPresetButton(l10n.thisMonth, _getThisMonthStart(), _getThisMonthEnd()),
                _buildPresetButton(l10n.lastMonth, _getLastMonthStart(), _getLastMonthEnd()),
                _buildPresetButton(l10n.last7Days, DateTime.now().subtract(const Duration(days: 6)), DateTime.now()),
                _buildPresetButton(l10n.last30Days, DateTime.now().subtract(const Duration(days: 29)), DateTime.now()),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildCalendarHeader(),
          _buildCalendarGrid(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_startDate != null && _endDate != null) 
                    ? () {
                        widget.onRangeSelected(_startDate!, _endDate!);
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeConstants.innerRadius)),
                  elevation: 0,
                ),
                child: Text(l10n.apply),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPresetButton(String label, DateTime start, DateTime end) {
    return GestureDetector(
      onTap: () => _onPresetPressed(start, end),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceInner,
          borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
          border: Border.all(color: AppColors.borderStrong, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Text(label, style: AppTextStyles.body.copyWith(fontSize: 13)),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() {
              _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1);
            }),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_viewMonth),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() {
              _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final firstDayWeekday = DateTime(_viewMonth.year, _viewMonth.month, 1).weekday % 7; 
    
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((d) => SizedBox(
              width: 40,
              child: Text(d, textAlign: TextAlign.center, style: AppTextStyles.muted),
            )).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 0, // Zero for range bands
              crossAxisSpacing: 0,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayNumber = index - firstDayWeekday + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) return const SizedBox.shrink();
              
              final date = DateTime(_viewMonth.year, _viewMonth.month, dayNumber);
              final isStart = _startDate != null && DateUtils.isSameDay(date, _startDate!);
              final isEnd = _endDate != null && DateUtils.isSameDay(date, _endDate!);
              final isInRange = _startDate != null && _endDate != null && date.isAfter(_startDate!) && date.isBefore(_endDate!);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_startDate == null || (_startDate != null && _endDate != null)) {
                      _startDate = date;
                      _endDate = null;
                    } else if (date.isBefore(_startDate!)) {
                      _startDate = date;
                    } else {
                      _endDate = date;
                    }
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isInRange)
                      Container(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    if (isStart && _endDate != null)
                      Positioned(
                        right: 0, left: 20, top: 4, bottom: 4,
                        child: Container(color: AppColors.accent.withValues(alpha: 0.1)),
                      ),
                    if (isEnd && _startDate != null)
                      Positioned(
                        left: 0, right: 20, top: 4, bottom: 4,
                        child: Container(color: AppColors.accent.withValues(alpha: 0.1)),
                      ),
                    Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: (isStart || isEnd) ? AppColors.accent : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dayNumber.toString(),
                        style: AppTextStyles.body.copyWith(
                          color: (isStart || isEnd) ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  DateTime _getThisMonthStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  DateTime _getThisMonthEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0);
  }

  DateTime _getLastMonthStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month - 1, 1);
  }

  DateTime _getLastMonthEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 0);
  }
}
