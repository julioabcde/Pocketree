import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/features/reports/domain/entities/account_breakdown.dart';
import 'package:pocketree/features/reports/presentation/utils/report_visuals.dart';
import 'package:pocketree/features/reports/presentation/widgets/section_card.dart';

class AccountsTab extends StatelessWidget {
  const AccountsTab({super.key, required this.breakdown});

  final AccountBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final items = breakdown.items;

    if (items.isEmpty) {
      return const _EmptyAccounts();
    }

    final maxAbs = items
        .map((e) => e.amount.abs())
        .reduce((a, b) => a > b ? a : b);
    final maxY = (maxAbs / 1000000).ceilToDouble() + 2;
    final minAbs = items.fold<double>(
      0,
      (acc, e) => e.amount < acc ? e.amount : acc,
    );
    final minY = minAbs < 0
        ? (minAbs / 1000000).floorToDouble() - 1
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Accounts Balance',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownEspresso,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'In millions (Rp)',
                style: TextStyle(fontSize: 12, color: AppColors.brownMocha),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    minY: minY,
                    alignment: BarChartAlignment.spaceAround,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 4,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color:
                            AppColors.neutralTaupe.withValues(alpha: 0.25),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= items.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                items[i].accountName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.brownMocha,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(enabled: false),
                    barGroups: [
                      for (var i = 0; i < items.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: items[i].amount / 1000000,
                              color: ReportVisuals.colorForAccountType(
                                items[i].accountType,
                                i,
                              ),
                              width: 22,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                                bottom: Radius.circular(6),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                AccountRow(item: items[i], index: i),
                if (i != items.length - 1)
                  Divider(
                    height: 1,
                    color: AppColors.neutralTaupe.withValues(alpha: 0.25),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class AccountRow extends StatelessWidget {
  const AccountRow({super.key, required this.item, required this.index});

  final AccountBreakdownItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isNegative = item.amount < 0;
    final color = ReportVisuals.colorForAccountType(item.accountType, index);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.accountName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brownEspresso,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.transactionCount} transactions',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.brownMocha,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(item.amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isNegative
                  ? AppColors.errorRed
                  : AppColors.brownEspresso,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAccounts extends StatelessWidget {
  const _EmptyAccounts();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: const [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 40,
            color: AppColors.neutralTaupe,
          ),
          SizedBox(height: 12),
          Text(
            'No account activity in this period',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.brownMocha,
            ),
          ),
        ],
      ),
    );
  }
}
