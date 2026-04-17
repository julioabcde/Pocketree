import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/core/widgets/ticket_card.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_summary.dart';

class ActiveBillCard extends StatelessWidget {
  final SplitBillSummary bill;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ActiveBillCard({
    super.key,
    required this.bill,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final remaining =
        bill.settlementSummary?.remainingDebtAmount ?? bill.totalAmount;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showOptions(context),
      child: TicketCard(
        top: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brownEspresso,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMM yyyy').format(bill.date),
                      style: const TextStyle(fontSize: 13, color: AppColors.brownMocha),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              BillIcon(title: bill.title),
            ],
          ),
        ),
        bottom: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.hasCalculation ? 'REMAINING TO COLLECT' : 'TOTAL AMOUNT',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownMocha,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(remaining),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryForest,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              PaidBadge(
                paid: bill.paidParticipantCount,
                total: bill.totalNonPayerCount,
                hasCalculation: bill.hasCalculation,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.errorRed),
              title: const Text('Delete', style: TextStyle(color: AppColors.errorRed)),
              onTap: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettledBillCard extends StatelessWidget {
  final SplitBillSummary bill;
  final VoidCallback onTap;

  const SettledBillCard({super.key, required this.bill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TicketCard(
        borderColor: const Color(0xFFEAE3D5).withValues(alpha: 0.5),
        top: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brownEspresso.withValues(alpha: 0.55),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMM yyyy').format(bill.date),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.brownMocha.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              BillIcon(title: bill.title, dimmed: true),
            ],
          ),
        ),
        bottom: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL AMOUNT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownMocha.withValues(alpha: 0.55),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(bill.totalAmount),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brownEspresso.withValues(alpha: 0.45),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.neutralSand,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Settled',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brownMocha,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BillIcon extends StatelessWidget {
  final String title;
  final bool dimmed;

  const BillIcon({super.key, required this.title, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: dimmed
            ? AppColors.neutralSand
            : AppColors.primaryForest.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.receipt_long_rounded,
        size: 22,
        color: dimmed ? AppColors.brownMocha : AppColors.primaryForest,
      ),
    );
  }
}

class PaidBadge extends StatelessWidget {
  final int paid;
  final int total;
  final bool hasCalculation;

  const PaidBadge({
    super.key,
    required this.paid,
    required this.total,
    required this.hasCalculation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Text(
        hasCalculation ? '$paid of $total Paid' : 'Uncalculated',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryForest,
        ),
      ),
    );
  }
}

class TotalHeader extends StatelessWidget {
  final double totalToCollect;
  const TotalHeader({super.key, required this.totalToCollect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'TOTAL TO COLLECT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.brownMocha,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          CurrencyFormatter.format(totalToCollect),
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryForest,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}
