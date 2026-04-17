import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/features/reports/domain/entities/report_overview.dart';
import 'package:pocketree/features/reports/presentation/widgets/section_card.dart';

class NetBalanceCard extends StatelessWidget {
  const NetBalanceCard({super.key, required this.overview});

  final ReportOverview overview;

  @override
  Widget build(BuildContext context) {
    final percent = overview.delta.net.percent;
    final isPositive = (percent ?? 0) >= 0;
    final accent =
        isPositive ? AppColors.primaryForest : AppColors.errorRed;

    return SectionCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Net Balance',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.brownMocha,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(overview.net),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.brownEspresso,
            ),
          ),
          if (percent != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 16,
                  color: accent,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${percent.toStringAsFixed(1)}% vs previous period',
                  style: TextStyle(
                    fontSize: 12,
                    color: accent.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
