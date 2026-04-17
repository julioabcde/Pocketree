import 'package:equatable/equatable.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_settlement.dart';

class SplitBillDebt extends Equatable {
  final int id;
  final int debtorParticipantId;
  final int creditorParticipantId;
  
  final String debtorName;
  final String creditorName;
  final double amount;
  final double remainingAmount;
  final bool isSettled;
  final List<SplitBillSettlement> settlements;
  final DateTime createdAt;

  const SplitBillDebt({
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

  @override
  List<Object?> get props => [
        id, debtorParticipantId, creditorParticipantId,
        debtorName, creditorName, amount, remainingAmount,
        isSettled, settlements, createdAt,
      ];
}