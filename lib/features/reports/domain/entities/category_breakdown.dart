import 'package:equatable/equatable.dart';

class CategoryBreakdownItem extends Equatable {
  final int? categoryId;
  final String name;
  final String color;
  final String icon;
  final double amount;
  final double percentage;
  final int transactionCount;

  const CategoryBreakdownItem({
    this.categoryId,
    required this.name,
    required this.color,
    required this.icon,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [
        categoryId,
        name,
        color,
        icon,
        amount,
        percentage,
        transactionCount,
      ];
}

class CategoryBreakdown extends Equatable {
  final double totalAmount;
  final List<CategoryBreakdownItem> items;

  const CategoryBreakdown({
    required this.totalAmount,
    required this.items,
  });

  @override
  List<Object?> get props => [totalAmount, items];
}
