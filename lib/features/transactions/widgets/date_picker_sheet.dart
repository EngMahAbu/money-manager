import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/theme/theme_constants.dart';
import '../../../shared/widgets/bottom_sheet_header.dart';

import '../../../l10n/app_localizations.dart';

class DatePickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const DatePickerSheet({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<DatePickerSheet> {
  late DateTime _selectedDate;
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _viewMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  void _onShortcutPressed(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected(date);
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
          BottomSheetHeader(title: l10n.chooseDate),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildShortcutButton(l10n.today, DateTime.now()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildShortcutButton(l10n.yesterday, DateTime.now().subtract(const Duration(days: 1))),
                ),
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
                onPressed: () {
                  widget.onDateSelected(_selectedDate);
                  Navigator.pop(context);
                },
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

  Widget _buildShortcutButton(String label, DateTime date) {
    return GestureDetector(
      onTap: () => _onShortcutPressed(date),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceInner,
          borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
          border: Border.all(color: AppColors.borderStrong, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Text(label, style: AppTextStyles.body),
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
    final firstDayWeekday = DateTime(_viewMonth.year, _viewMonth.month, 1).weekday; // 1 = Mon, 7 = Sun
    
    // Sunday start: S M T W T F S
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    // Adjusted weekday for Sunday start (0 = Sun, 6 = Sat)
    final adjustedFirstDay = firstDayWeekday % 7; 

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
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayNumber = index - adjustedFirstDay + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) return const SizedBox.shrink();
              
              final date = DateTime(_viewMonth.year, _viewMonth.month, dayNumber);
              final isSelected = DateUtils.isSameDay(date, _selectedDate);
              final isToday = DateUtils.isSameDay(date, DateTime.now());
              final isFuture = date.isAfter(DateTime.now());

              return GestureDetector(
                onTap: isFuture ? null : () => setState(() => _selectedDate = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    dayNumber.toString(),
                    style: AppTextStyles.body.copyWith(
                      color: isSelected 
                          ? Colors.white 
                          : (isFuture ? AppColors.textMuted.withValues(alpha: 0.3) : AppColors.textPrimary),
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
