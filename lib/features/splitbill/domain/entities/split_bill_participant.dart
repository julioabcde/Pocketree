import 'package:equatable/equatable.dart';
import 'split_bill_participant_item.dart';

class SplitBillParticipant extends Equatable {
  final int id;
  final String name;
  final bool isPayer;
  final double paidAmount;
  final double? finalAmount;
  final List<SplitBillParticipantItem> items;
  final DateTime createdAt;

  const SplitBillParticipant({
    required this.id,
    required this.name,
    required this.isPayer,
    required this.paidAmount,
    this.finalAmount,
    this.items = const [],
    required this.createdAt,
  });

  bool get hasItemBreakdown => items.isNotEmpty;

  @override
  List<Object?> get props =>
      [id, name, isPayer, paidAmount, finalAmount, items, createdAt];
}