import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/features/reports/domain/entities/cashflow_trend_item.dart';
import 'package:pocketree/features/reports/presentation/widgets/section_card.dart';

class CashflowChartCard extends StatelessWidget {
  const CashflowChartCard({
    super.key,
    required this.trend,
    required this.groupBy,
  });

  final List<CashflowTrendItem> trend;
  final String groupBy;

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) {
      return SectionCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: const [
            Icon(
              Icons.show_chart_rounded,
              size: 40,
              color: AppColors.neutralTaupe,
            ),
            SizedBox(height: 12),
            Text(
              'No cashflow data for this period',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.brownMocha,
              ),
            ),
          ],
        ),
      );
    }

    final incomeSpots = <FlSpot>[
      for (var i = 0; i < trend.length; i++)
        FlSpot(i.toDouble(), trend[i].income / 1000000),
    ];
    final expenseSpots = <FlSpot>[
      for (var i = 0; i < trend.length; i++)
        FlSpot(i.toDouble(), trend[i].expense / 1000000),
    ];

    final maxValue = trend.fold<double>(0, (acc, e) {
      final v = (e.income > e.expense ? e.income : e.expense) / 1000000;
      return v > acc ? v : acc;
    });
    final maxY = (maxValue * 1.25).ceilToDouble().clamp(1, double.infinity);
    final interval = (maxY / 4).clamp(0.5, double.infinity);
    final labelStep = _labelStep(trend.length, groupBy);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cashflow Trend',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.brownEspresso,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${trend.length} periods - In millions (Rp)',
            style: const TextStyle(fontSize: 12, color: AppColors.brownMocha),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              LegendDot(color: AppColors.primaryForest, label: 'Income'),
              SizedBox(width: 16),
              LegendDot(color: AppColors.errorRed, label: 'Expense'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (trend.length - 1).toDouble().clamp(1, double.infinity),
                minY: 0,
                maxY: maxY.toDouble(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval.toDouble(),
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.neutralTaupe.withValues(alpha: 0.25),
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
                      reservedSize: 24,
                      interval: labelStep.toDouble(),
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= trend.length) {
                          return const SizedBox.shrink();
                        }

                        if (i % labelStep != 0 && i != trend.length - 1) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _labelFor(trend[i]),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.brownMocha,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  _lineBar(incomeSpots, AppColors.primaryForest),
                  _lineBar(expenseSpots, AppColors.errorRed),
                ],
                lineTouchData: const LineTouchData(enabled: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _labelStep(int count, String selectedGroupBy) {
    if (count <= 1) return 1;

    final maxLabels = switch (selectedGroupBy) {
      'day' => 6,
      'week' => 8,
      'month' => 12,
      _ => 6,
    };

    final step = (count / maxLabels).ceil();
    return step < 1 ? 1 : step;
  }

  String _labelFor(CashflowTrendItem item) {
    final period = item.period.trim();

    final weekMatch = RegExp(r'^(\d{4})-W(\d{2})$').firstMatch(period);
    if (weekMatch != null) {
      return 'W${weekMatch.group(2)}';
    }

    final dayMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(period);
    if (dayMatch != null) {
      final parsed = DateTime.tryParse(period);
      if (parsed != null) {
        return DateFormat('d MMM').format(parsed);
      }
    }

    final monthMatch = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(period);
    if (monthMatch != null) {
      final year = int.parse(monthMatch.group(1)!);
      final month = int.parse(monthMatch.group(2)!);
      return DateFormat('MMM').format(DateTime(year, month, 1));
    }

    return DateFormat('d MMM').format(item.startDate);
  }

  LineChartBarData _lineBar(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }
}

class LegendDot extends StatelessWidget {
  const LegendDot({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.brownDriftwood,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
