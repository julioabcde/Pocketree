import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final bool showDivider;
  final VoidCallback? onOptionsTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.showDivider = true,
    this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final isTransfer = transaction.isTransfer;

    // Icon selection 
    final IconData icon = isTransfer
        ? Icons.swap_horiz_rounded
        : isIncome
            ? Icons.arrow_downward_rounded
            : Icons.arrow_upward_rounded;

    // Label logic 
    final String primaryLabel = transaction.note?.isNotEmpty == true
        ? transaction.note!
        : isTransfer
            ? 'Transfer'
            : isIncome
                ? 'Income'
                : 'Expense';

    final String? secondaryLabel = transaction.note?.isNotEmpty == true
        ? (isTransfer
            ? 'Transfer'
            : isIncome
                ? 'Income'
                : 'Expense')
        : null;

    // Amount formatting 
    final String amountPrefix = isTransfer
        ? ''
        : isIncome
            ? '+'
            : '-';
    final String amountText =
        '$amountPrefix${CurrencyFormatter.format(transaction.amount)}';

    final String timeLabel =
        DateFormat('hh:mm a').format(transaction.createdAt);

    return Container(
      color: AppColors.neutralCream,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              children: [
                //  Leading icon 
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.neutralLinen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 22, color: AppColors.darkDeepPine),
                ),
                const SizedBox(width: 14),

                //  Middle: label + note 
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        primaryLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brownEspresso,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (secondaryLabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          secondaryLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.brownMocha,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                //  Trailing: amount + time + options 
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          amountText,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brownEspresso,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.brownMocha,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onOptionsTap,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.more_vert_rounded,
                          color: AppColors.neutralTaupe,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          //  Divider 
          if (showDivider)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                height: 1,
                color: AppColors.neutralTaupe.withValues(alpha: 0.25),
              ),
            ),
        ],
      ),
    );
  }
}