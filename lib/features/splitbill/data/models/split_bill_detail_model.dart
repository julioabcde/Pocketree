import 'package:pocketree/features/splitbill/domain/entities/split_bill_detail.dart';
import 'split_bill_charge_model.dart';
import 'split_bill_debt_model.dart';
import 'split_bill_item_model.dart';
import 'split_bill_participant_model.dart';
import 'split_bill_settlement_model.dart';

class SplitBillDetailModel {
  final int id;
  final String title;
  final double subtotal;
  final double totalAmount;
  final DateTime date;
  final String? note;
  final String? receiptImageUrl;
  final List<SplitBillItemModel> items;
  final List<SplitBillChargeModel> charges;
  final List<SplitBillParticipantModel> participants;
  final List<SplitBillDebtModel> debts;
  final List<SplitBillSettlementModel> settlements;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int paidParticipantCount;
  final int totalNonPayerCount;
  final bool hasCalculation;
  final bool isFullySettled;
  final int? transactionId;

  SplitBillDetailModel({
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
    required this.createdAt,
    required this.updatedAt,
    required this.paidParticipantCount,
    required this.totalNonPayerCount,
    required this.hasCalculation,
    required this.isFullySettled,
    this.transactionId,
  });

  factory SplitBillDetailModel.fromJson(Map<String, dynamic> json) {
    final participantModels = (json['participants'] as List<dynamic>)
        .map(
          (p) => SplitBillParticipantModel.fromJson(p as Map<String, dynamic>),
        )
        .toList();

    final participantNames = <int, String>{
      for (final p in participantModels) p.id: p.name,
    };

    final settlementModels = (json['settlements'] as List<dynamic>)
        .map(
          (s) => SplitBillSettlementModel.fromJson(s as Map<String, dynamic>),
        )
        .toList();

    final settlementsByDebtId = <int, List<SplitBillSettlementModel>>{};
    for (final s in settlementModels) {
      settlementsByDebtId.putIfAbsent(s.debtId, () => []).add(s);
    }

    final debtModels = (json['debts'] as List<dynamic>).map((d) {
      final map = d as Map<String, dynamic>;
      final debtId = map['id'] as int;
      return SplitBillDebtModel.fromJsonWithContext(
        map,
        participantNames,
        settlementsByDebtId[debtId] ?? [],
      );
    }).toList();

    return SplitBillDetailModel(
      id: json['id'] as int,
      title: json['title'] as String,
      subtotal: double.parse(json['subtotal'] as String),
      totalAmount: double.parse(json['total_amount'] as String),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      receiptImageUrl: json['receipt_image_url'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((i) => SplitBillItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      charges: (json['charges'] as List<dynamic>)
          .map((c) => SplitBillChargeModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      participants: participantModels,
      debts: debtModels,
      settlements: settlementModels,
      paidParticipantCount: json['paid_participant_count'] as int? ?? 0,
      totalNonPayerCount: json['total_non_payer_count'] as int? ?? 0,
      hasCalculation: json['has_calculation'] as bool? ?? false,
      isFullySettled: json['is_fully_settled'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      transactionId: json['transaction_id'] as int?,
    );
  }

  SplitBillDetail toEntity() => SplitBillDetail(
    id: id,
    title: title,
    subtotal: subtotal,
    totalAmount: totalAmount,
    date: date,
    note: note,
    receiptImageUrl: receiptImageUrl,
    items: items.map((i) => i.toEntity()).toList(),
    charges: charges.map((c) => c.toEntity()).toList(),
    participants: participants.map((p) => p.toEntity()).toList(),
    debts: debts.map((d) => d.toEntity()).toList(),
    settlements: settlements.map((s) => s.toEntity()).toList(),
    createdAt: createdAt,
    updatedAt: updatedAt,
    paidParticipantCount: paidParticipantCount,
    totalNonPayerCount: totalNonPayerCount,
    hasCalculation: hasCalculation,
    isFullySettled: isFullySettled,
    transactionId: transactionId,
  );
}
