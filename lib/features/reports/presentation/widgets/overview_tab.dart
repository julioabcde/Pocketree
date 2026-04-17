import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/features/reports/domain/entities/reports_data.dart';
import 'package:pocketree/features/reports/presentation/widgets/cashflow_chart_card.dart';
import 'package:pocketree/features/reports/presentation/widgets/kpi_row.dart';
import 'package:pocketree/features/reports/presentation/widgets/net_balance_card.dart';
import 'package:pocketree/features/reports/presentation/widgets/top_transactions_section.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({
    super.key,
    required this.data,
    required this.selectedType,
    required this.groupBy,
  });

  final ReportsData data;
  final String selectedType;
  final String groupBy;

  @override
  Widget build(BuildContext context) {
    final overview = data.overview;
    final expenseDeltaPercent = overview.delta.expense.percent;
    final commentary = expenseDeltaPercent == null
        ? null
        : expenseDeltaPercent >= 0
            ? 'Expenses increased by ${expenseDeltaPercent.toStringAsFixed(1)}% vs previous period'
            : 'Expenses decreased by ${expenseDeltaPercent.abs().toStringAsFixed(1)}% vs previous period';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NetBalanceCard(overview: overview),
        const SizedBox(height: 12),
        KpiRow(overview: overview),
        const SizedBox(height: 16),
        CashflowChartCard(
          trend: data.cashflowTrend,
          groupBy: groupBy,
        ),
        if (commentary != null) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              commentary,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.brownMocha,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        TopTransactionsSection(
          transactions: data.topTransactions,
          selectedType: selectedType,
        ),
      ],
    );
  }
}
