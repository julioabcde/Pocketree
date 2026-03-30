import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/compact_amount_formatter.dart';
import 'package:pocketree/features/transactions/domain/entities/daily_summary.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Map<int, DailySummary> dailySummaries;
  final ValueChanged<DateTime> onDayTapped;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const CalendarGrid({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.dailySummaries,
    required this.onDayTapped,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neutralTaupe.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMonthNav(),
          _buildWeekdayHeaders(),
          ..._buildWeekRows(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMonthNav() {
    final label = DateFormat('MMMM yyyy').format(currentMonth);
    final now = DateTime.now();

    final isCurrentMonth =
        currentMonth.year == now.year &&
        currentMonth.month == now.month;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.brownDriftwood,
            onPressed: onPreviousMonth,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.brownEspresso,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            color: isCurrentMonth
                ? AppColors.neutralTaupe.withValues(alpha: 0.4)
                : AppColors.brownDriftwood,
            onPressed: isCurrentMonth ? null : onNextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(days.length, (index) {
          final isWeekend = index == 0 || index == 6;

          return Expanded(
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isWeekend
                      ? AppColors.primaryForest
                      : AppColors.brownMocha,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildWeekRows() {
    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

    final firstWeekday =
        DateTime(currentMonth.year, currentMonth.month, 1).weekday;

    final startOffset = firstWeekday % 7;

    final rows = <Widget>[];
    int day = 1;

    for (int week = 0; week < 6; week++) {
      if (day > daysInMonth) break;

      final cells = <Widget>[];

      for (int col = 0; col < 7; col++) {
        final index = week * 7 + col;

        if (index < startOffset || day > daysInMonth) {
          cells.add(const Expanded(child: SizedBox()));
        } else {
          final date =
              DateTime(currentMonth.year, currentMonth.month, day);

          cells.add(
            Expanded(
              child: _DayCell(
                date: date,
                summary: dailySummaries[day],
                isSelected: _isSameDay(date, selectedDate),
                isToday: _isToday(date),
                isWeekend: col == 0 || col == 6,
                onTap: () => onDayTapped(date),
              ),
            ),
          );

          day++;
        }
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: cells),
        ),
      );
    }

    return rows;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;

  bool _isToday(DateTime date) =>
      _isSameDay(date, DateTime.now());
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final DailySummary? summary;
  final bool isSelected;
  final bool isToday;
  final bool isWeekend;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.summary,
    required this.isSelected,
    required this.isToday,
    required this.isWeekend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final day = date.day;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDayCircle(day),
            if (summary?.hasTransactions == true)
              _buildAmount(summary!.net),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCircle(int day) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primaryForest : null,
        border: isToday && !isSelected
            ? Border.all(color: AppColors.primaryForest, width: 1.5)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '$day',
        style: TextStyle(
          fontWeight: (isSelected || isToday)
              ? FontWeight.w600
              : FontWeight.w400,
          color: isSelected
              ? AppColors.white
              : isWeekend
                  ? AppColors.primaryForest
                  : AppColors.brownEspresso,
        ),
      ),
    );
  }

  Widget _buildAmount(double net) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        CompactAmountFormatter.formatSigned(net),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: net >= 0
              ? AppColors.primaryForest
              : const Color(0xFFB3261E),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}