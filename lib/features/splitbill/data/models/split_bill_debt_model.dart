import 'package:pocketree/features/splitbill/domain/entities/split_bill_debt.dart';
import 'split_bill_settlement_model.dart';

class SplitBillDebtModel {
  final int id;
  final int debtorParticipantId;
  final int creditorParticipantId;
  final String debtorName;
  final String creditorName;
  final double amount;
  final double remainingAmount;
  final bool isSettled;
  final List<SplitBillSettlementModel> settlements;
  final DateTime createdAt;

  SplitBillDebtModel({
    required this.id,
    required this.debtorParticipantId,
    required this.creditorParticipantId,
    required this.debtorName,
    required this.creditorName,
    required this.amount,
    required this.remainingAmount,
    required this.isSettled,
    required this.settlements,
    required this.createdAt,
  });

  factory SplitBillDebtModel.fromJsonWithContext(
    Map<String, dynamic> json,
    Map<int, String> participantNames,
    List<SplitBillSettlementModel> settlements,
  ) {
    final debtorId = json['debtor_participant_id'] as int;
    final creditorId = json['creditor_participant_id'] as int;

    return SplitBillDebtModel(
      id: json['id'] as int,
      debtorParticipantId: debtorId,
      creditorParticipantId: creditorId,
      debtorName: participantNames[debtorId] ?? 'Unknown',
      creditorName: participantNames[creditorId] ?? 'Unknown',
      amount: double.parse(json['amount'] as String),
      remainingAmount: double.parse(json['remaining_amount'] as String),
      isSettled: json['is_settled'] as bool,
      settlements: settlements,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  SplitBillDebt toEntity() => SplitBillDebt(
        id: id,
        debtorParticipantId: debtorParticipantId,
        creditorParticipantId: creditorParticipantId,
        debtorName: debtorName,
        creditorName: creditorName,
        amount: amount,
        remainingAmount: remainingAmount,
        isSettled: isSettled,
        settlements: settlements.map((s) => s.toEntity()).toList(),
        createdAt: createdAt,
      );
}