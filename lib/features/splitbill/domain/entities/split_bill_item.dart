import 'package:equatable/equatable.dart';

class SplitBillItem extends Equatable {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final double subtotal;
  final DateTime createdAt;

  const SplitBillItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, price, quantity, subtotal, createdAt];
}