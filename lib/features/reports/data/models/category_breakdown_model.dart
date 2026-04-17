import 'package:pocketree/features/reports/domain/entities/category_breakdown.dart';

class CategoryBreakdownItemModel {
  final int? categoryId;
  final String name;
  final String color;
  final String icon;
  final double amount;
  final double percentage;
  final int transactionCount;

  CategoryBreakdownItemModel({
    this.categoryId,
    required this.name,
    required this.color,
    required this.icon,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });

  factory CategoryBreakdownItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownItemModel(
      categoryId: json['category_id'] as int?,
      name: (json['name'] as String?) ?? 'Uncategorized',
      color: (json['color'] as String?) ?? '#808080',
      icon: (json['icon'] as String?) ?? '',
      amount: double.parse(json['amount'] as String),
      percentage: double.parse(json['percentage'] as String),
      transactionCount: json['transaction_count'] as int,
    );
  }

  CategoryBreakdownItem toEntity() => CategoryBreakdownItem(
        categoryId: categoryId,
        name: name,
        color: color,
        icon: icon,
        amount: amount,
        percentage: percentage,
        transactionCount: transactionCount,
      );
}

class CategoryBreakdownModel {
  final double totalAmount;
  final List<CategoryBreakdownItemModel> items;

  CategoryBreakdownModel({
    required this.totalAmount,
    required this.items,
  });

  factory CategoryBreakdownModel.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownModel(
      totalAmount: double.parse(json['total_amount'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) =>
              CategoryBreakdownItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  CategoryBreakdown toEntity() => CategoryBreakdown(
        totalAmount: totalAmount,
        items: items.map((e) => e.toEntity()).toList(),
      );
}
