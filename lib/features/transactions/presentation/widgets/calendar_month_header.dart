import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/compact_amount_formatter.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_summary.dart';

class CalendarMonthHeader extends StatelessWidget {
  final TransactionSummary summary;

  const CalendarMonthHeader({super.key, required this.summary});

  static const _labelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.brownMocha,
    letterSpacing: 1,
  );

  static const _valueBaseStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildColumn(
          label: 'INCOME',
          value: CompactAmountFormatter.format(
            summary.totalIncome,
            signed: false,
          ),
          color: AppColors.primaryForest,
        ),
        _buildColumn(
          label: 'EXPENSE',
          value: CompactAmountFormatter.format(
            summary.totalExpense,
            signed: false,
          ),
          color: AppColors.brownEspresso,
        ),
        _buildColumn(
          label: 'TOTAL',
          value: CompactAmountFormatter.formatSigned(summary.net),
          color: summary.net >= 0
              ? AppColors.primaryForest
              : const Color(0xFFB3261E),
        ),
      ],
    );
  }

  Widget _buildColumn({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: _labelStyle),
          const SizedBox(height: 4),
          Text(
            value,
            style: _valueBaseStyle.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}