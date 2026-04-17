import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/features/reports/domain/entities/top_transaction.dart';
import 'package:pocketree/features/reports/presentation/widgets/section_card.dart';

class TopTransactionsSection extends StatelessWidget {
  const TopTransactionsSection({
    super.key,
    required this.transactions,
    required this.selectedType,
  });

  final List<TopTransaction> transactions;
  final String selectedType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Top Transactions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.brownEspresso,
            ),
          ),
        ),
        if (transactions.isEmpty)
          SectionCard(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            child: Column(
              children: const [
                Icon(
                  Icons.inbox_outlined,
                  size: 36,
                  color: AppColors.neutralTaupe,
                ),
                SizedBox(height: 10),
                Text(
                  'No transactions in this period',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.brownMocha,
                  ),
                ),
              ],
            ),
          )
        else
          for (var i = 0; i < transactions.length; i++) ...[
            TopTransactionRow(
              transaction: transactions[i],
              selectedType: selectedType,
            ),
            if (i != transactions.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class TopTransactionRow extends StatelessWidget {
  const TopTransactionRow({
    super.key,
    required this.transaction,
    required this.selectedType,
  });

  final TopTransaction transaction;
  final String selectedType;

  @override
  Widget build(BuildContext context) {
    final isIncome = selectedType == 'income';
    final accent = isIncome ? AppColors.primaryForest : AppColors.errorRed;
    final title = (transaction.note?.trim().isNotEmpty ?? false)
        ? transaction.note!.trim()
        : transaction.category;
    final amount = transaction.amount.abs();

    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
              size: 20,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brownEspresso,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.category} - ${DateFormat('d MMM').format(transaction.date)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.brownMocha,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${CurrencyFormatter.format(amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
