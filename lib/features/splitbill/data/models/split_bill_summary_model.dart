import 'package:pocketree/features/splitbill/domain/entities/split_bill_summary.dart';
import 'settlement_summary_model.dart';

class SplitBillSummaryModel {
  final int id;
  final String title;
  final DateTime date;
  final double totalAmount;
  final int participantCount;
  final int paidParticipantCount;
  final int totalNonPayerCount;
  final bool hasCalculation;
  final bool isFullySettled;
  final SettlementSummaryModel? settlementSummary;

  SplitBillSummaryModel({
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

  factory SplitBillSummaryModel.fromJson(Map<String, dynamic> json) {
    final settlementJson =
        json['settlement_summary'] as Map<String, dynamic>?;

    return SplitBillSummaryModel(
      id: json['id'] as int,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      totalAmount: double.parse(json['total_amount'] as String),
      participantCount: json['participant_count'] as int,
      paidParticipantCount: json['paid_participant_count'] as int,
      totalNonPayerCount: json['total_non_payer_count'] as int,
      hasCalculation: json['has_calculation'] as bool,
      isFullySettled: json['is_fully_settled'] as bool,
      settlementSummary: settlementJson != null
          ? SettlementSummaryModel.fromJson(settlementJson)
          : null,
    );
  }

  SplitBillSummary toEntity() => SplitBillSummary(
        id: id,
        title: title,
        date: date,
        totalAmount: totalAmount,
        participantCount: participantCount,
        paidParticipantCount: paidParticipantCount,
        totalNonPayerCount: totalNonPayerCount,
        hasCalculation: hasCalculation,
        isFullySettled: isFullySettled,
        settlementSummary: settlementSummary?.toEntity(),
      );
}