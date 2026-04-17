import 'package:equatable/equatable.dart';

class SplitBillSettlement extends Equatable {
  final int id;
  final int debtId;
  final int fromParticipantId;
  final int toParticipantId;
  final double amount;
  final DateTime createdAt;
  final int? transactionId;

  const SplitBillSettlement({
    required this.id,
    required this.debtId,
    required this.fromParticipantId,
    required this.toParticipantId,
    required this.amount,
    required this.createdAt,
    this.transactionId,
  });

  @override
  List<Object?> get props =>
      [id, debtId, fromParticipantId, toParticipantId, amount, createdAt, transactionId];
}