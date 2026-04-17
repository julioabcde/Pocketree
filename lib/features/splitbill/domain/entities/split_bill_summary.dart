import 'package:equatable/equatable.dart';
import 'settlement_summary.dart';

class SplitBillSummary extends Equatable {
  final int id;
  final String title;
  final DateTime date;
  final double totalAmount;
  final int participantCount;
  final int paidParticipantCount;  
  final int totalNonPayerCount;     
  final bool hasCalculation;
  final bool isFullySettled;
  final SettlementSummary? settlementSummary; 

  const SplitBillSummary({
    required this.id,
    required this.title,
    required this.date,
    required this.totalAmount,
    required this.participantCount,
    required this.paidParticipantCount,
    required this.totalNonPayerCount,
    required this.hasCalculation,
    required this.isFullySettled,
    this.settlementSummary,
  });

  String get paidLabel => '$paidParticipantCount/$totalNonPayerCount PAID';

  String get progressPercent {
    if (settlementSummary == null) return '0%';
    final pct =
        (settlementSummary!.nominalProgress * 100).toStringAsFixed(0);
    return '$pct%';
  }

  @override
  List<Object?> get props => [
        id, title, date, totalAmount, participantCount,
        paidParticipantCount, totalNonPayerCount,
        hasCalculation, isFullySettled, settlementSummary,
      ];
}