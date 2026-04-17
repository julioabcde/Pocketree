import 'package:pocketree/features/splitbill/domain/entities/split_bill_participant.dart';
import 'split_bill_participant_item_model.dart';

class SplitBillParticipantModel {
  final int id;
  final String name;
  final bool isPayer;
  final double paidAmount;
  final double? finalAmount;
  final List<SplitBillParticipantItemModel> items;
  final DateTime createdAt;

  SplitBillParticipantModel({
    required this.id,
    required this.name,
    required this.isPayer,
    required this.paidAmount,
    this.finalAmount,
    required this.items,
    required this.createdAt,
  });

  factory SplitBillParticipantModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];

    return SplitBillParticipantModel(
      id: json['id'] as int,
      name: json['name'] as String,
      isPayer: json['is_payer'] as bool,
      paidAmount: double.parse(json['paid_amount'] as String),
      finalAmount: json['final_amount'] != null
          ? double.parse(json['final_amount'] as String)
          : null,
      items: itemsJson
          .map(
            (i) => SplitBillParticipantItemModel.fromJson(
              i as Map<String, dynamic>,
            ),
          )
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  SplitBillParticipant toEntity() => SplitBillParticipant(
    id: id,
    name: name,
    isPayer: isPayer,
    paidAmount: paidAmount,
    finalAmount: finalAmount,
    items: items.map((i) => i.toEntity()).toList(),
    createdAt: createdAt,
  );
}
