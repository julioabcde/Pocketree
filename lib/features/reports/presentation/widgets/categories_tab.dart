import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/features/reports/domain/entities/category_breakdown.dart';
import 'package:pocketree/features/reports/presentation/utils/report_visuals.dart';
import 'package:pocketree/features/reports/presentation/widgets/section_card.dart';

class CategoriesTab extends StatelessWidget {
  const CategoriesTab({super.key, required this.breakdown});

  final CategoryBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final items = breakdown.items;

    if (items.isEmpty) {
      return const _EmptyCategories();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category Breakdown',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownEspresso,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total ${CurrencyFormatter.format(breakdown.totalAmount)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.brownMocha,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 58,
                        startDegreeOffset: -90,
                        sections: items
                            .map(
                              (c) => PieChartSectionData(
                                value: c.percentage,
                                color: ReportVisuals.colorFromHex(c.color),
                                radius: 28,
                                showTitle: false,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${items.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brownEspresso,
                          ),
                        ),
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.brownMocha,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                CategoryRow(item: items[i]),
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

class CategoryRow extends StatelessWidget {
  const CategoryRow({super.key, required this.item});

  final CategoryBreakdownItem item;

  @override
  Widget build(BuildContext context) {
    final color = ReportVisuals.colorFromHex(item.color);
    final icon = ReportVisuals.iconFromToken(item.icon);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brownEspresso,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.percentage.toStringAsFixed(0)}%',
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.brownEspresso,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: const [
          Icon(
            Icons.pie_chart_outline_rounded,
            size: 40,
            color: AppColors.neutralTaupe,
          ),
          SizedBox(height: 12),
          Text(
            'No category data in this period',
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
