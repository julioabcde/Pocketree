import 'package:equatable/equatable.dart';

class SplitBillParticipantItem extends Equatable {
  final int itemId;
  final String itemName;
  final int portion;
  final double allocatedSubtotal;

  const SplitBillParticipantItem({
    required this.itemId,
    required this.itemName,
    required this.portion,
    required this.allocatedSubtotal,
  });

  @override
  List<Object?> get props => [itemId, itemName, portion, allocatedSubtotal];
}