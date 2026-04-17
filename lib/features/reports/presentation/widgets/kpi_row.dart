import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/compact_amount_formatter.dart';
import 'package:pocketree/features/reports/domain/entities/report_overview.dart';
import 'package:pocketree/features/reports/presentation/widgets/section_card.dart';

class KpiRow extends StatelessWidget {
  const KpiRow({super.key, required this.overview});

  final ReportOverview overview;

  @override
  Widget build(BuildContext context) {
    final savingsLabel = overview.savingsRate == null
        ? '—'
        : '${overview.savingsRate!.toStringAsFixed(1)}%';

    return Row(
      children: [
        Expanded(
          child: KpiTile(
            label: 'Income',
            value: CompactAmountFormatter.format(overview.totalIncome, prefix: 'Rp '),
            icon: Icons.south_west_rounded,
            accent: AppColors.primaryForest,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: KpiTile(
            label: 'Expense',
            value: CompactAmountFormatter.format(overview.totalExpense, prefix: 'Rp '),
            icon: Icons.north_east_rounded,
            accent: AppColors.errorRed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: KpiTile(
            label: 'Savings',
            value: savingsLabel,
            icon: Icons.savings_rounded,
            accent: AppColors.brownCocoa,
          ),
        ),
      ],
    );
  }
}

class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.brownMocha,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.brownEspresso,
            ),
          ),
        ],
      ),
    );
  }
}
