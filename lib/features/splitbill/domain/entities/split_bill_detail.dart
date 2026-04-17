import 'package:equatable/equatable.dart';
import 'split_bill_charge.dart';
import 'split_bill_debt.dart';
import 'split_bill_item.dart';
import 'split_bill_participant.dart';
import 'split_bill_settlement.dart';

class SplitBillDetail extends Equatable {
  final int id;
  final String title;
  final double subtotal;
  final double totalAmount;
  final DateTime date;
  final String? note;
  final String? receiptImageUrl;
  final List<SplitBillItem> items;
  final List<SplitBillCharge> charges;
  final List<SplitBillParticipant> participants;
  final List<SplitBillDebt> debts;
  final List<SplitBillSettlement> settlements;

  final int paidParticipantCount;
  final int totalNonPayerCount;
  final bool hasCalculation;
  final bool isFullySettled;

  final DateTime createdAt;
  final DateTime updatedAt;
  final int? transactionId;

  const SplitBillDetail({
    required this.id,
    required this.title,
    required this.subtotal,
    required this.totalAmount,
    required this.date,
    this.note,
    this.receiptImageUrl,
    required this.items,
    required this.charges,
    required this.participants,
    required this.debts,
    required this.settlements,
    required this.paidParticipantCount,
    required this.totalNonPayerCount,
    required this.hasCalculation,
    required this.isFullySettled,
    required this.createdAt,
    required this.updatedAt,
    this.transactionId,
  });

  double get nominalProgress {
    if (debts.isEmpty) return isFullySettled ? 1.0 : 0.0;
    final total = debts.fold(0.0, (sum, d) => sum + d.amount);
    final paid = debts.fold(
      0.0,
      (sum, d) => sum + (d.amount - d.remainingAmount),
    );
    return total > 0 ? paid / total : 0.0;
  }

  String get paidLabel => '$paidParticipantCount/$totalNonPayerCount PAID';

  @override
  List<Object?> get props => [
    id,
    title,
    subtotal,
    totalAmount,
    date,
    note,
    receiptImageUrl,
    items,
    charges,
    participants,
    debts,
    settlements,
    paidParticipantCount,
    totalNonPayerCount,
    hasCalculation,
    isFullySettled,
    createdAt,
    updatedAt,
    transactionId,
  ];
}
