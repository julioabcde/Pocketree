import 'package:pocketree/features/splitbill/domain/entities/split_bill_participant_item.dart';

class SplitBillParticipantItemModel {
  final int itemId;
  final String itemName;
  final int portion;
  final double allocatedSubtotal;

  SplitBillParticipantItemModel({
    required this.itemId,
    required this.itemName,
    required this.portion,
    required this.allocatedSubtotal,
  });

  factory SplitBillParticipantItemModel.fromJson(Map<String, dynamic> json) {
    return SplitBillParticipantItemModel(
      itemId: json['item_id'] as int,
      itemName: json['item_name'] as String,
      portion: json['portion'] as int,
      allocatedSubtotal:
          double.parse(json['allocated_subtotal'] as String),
    );
  }

  SplitBillParticipantItem toEntity() => SplitBillParticipantItem(
        itemId: itemId,
        itemName: itemName,
        portion: portion,
        allocatedSubtotal: allocatedSubtotal,
      );
}