import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/features/accounts/domain/entities/account_summary.dart';

class AccountSummaryCard extends StatelessWidget {
  final AccountSummary summary;

  const AccountSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neutralTaupe.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Net Worth
          Text(
            'TOTAL NET WORTH',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.brownMocha,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(summary.netWorth),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.brownEspresso,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          Divider(
            color: AppColors.neutralTaupe.withValues(alpha: 0.3),
            thickness: 1,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // Assets
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 14,
                          color: AppColors.primaryForest,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ASSETS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brownMocha,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(summary.totalAssets),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryForest,
                      ),
                    ),
                  ],
                ),
              ),

              // Vertical divider
              Container(
                width: 1,
                height: 40,
                color: AppColors.neutralTaupe.withValues(alpha: 0.3),
              ),

              // Liabilities
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'DEBT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brownMocha,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_downward_rounded,
                          size: 14,
                          color: AppColors.brownCocoa,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(summary.totalLiabilities),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brownCocoa,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}