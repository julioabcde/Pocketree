import 'package:equatable/equatable.dart';

class SplitBillCharge extends Equatable {
  final int id;
  final String type;   
  final String name;
  final double amount;
  final DateTime createdAt;

  const SplitBillCharge({
    required this.id,
    required this.type,
    required this.name,
    required this.amount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, type, name, amount, createdAt];
}