import 'package:pocketree/features/splitbill/domain/entities/split_bill_settlement.dart';

class SplitBillSettlementModel {
  final int id;
  final int debtId;
  final int fromParticipantId;
  final int toParticipantId;
  final double amount;
  final DateTime createdAt;
  final int? transactionId;

  SplitBillSettlementModel({
    required this.id,
    required this.debtId,
    required this.fromParticipantId,
    required this.toParticipantId,
    required this.amount,
    required this.createdAt,
    this.transactionId,
  });

  factory SplitBillSettlementModel.fromJson(Map<String, dynamic> json) {
    return SplitBillSettlementModel(
      id: json['id'] as int,
      debtId: json['debt_id'] as int,
      fromParticipantId: json['from_participant_id'] as int,
      toParticipantId: json['to_participant_id'] as int,
      amount: double.parse(json['amount'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      transactionId: json['transaction_id'] as int?,
    );
  }

  SplitBillSettlement toEntity() => SplitBillSettlement(
        id: id,
        debtId: debtId,
        fromParticipantId: fromParticipantId,
        toParticipantId: toParticipantId,
        amount: amount,
        createdAt: createdAt,
        transactionId: transactionId,
      );
}