import 'package:pocketree/features/reports/domain/entities/account_breakdown.dart';

class AccountBreakdownItemModel {
  final int accountId;
  final String accountName;
  final String accountType;
  final double amount;
  final double percentage;
  final int transactionCount;

  AccountBreakdownItemModel({
    required this.accountId,
    required this.accountName,
    required this.accountType,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });

  factory AccountBreakdownItemModel.fromJson(Map<String, dynamic> json) {
    return AccountBreakdownItemModel(
      accountId: json['account_id'] as int,
      accountName: json['account_name'] as String,
      accountType: json['account_type'] as String,
      amount: double.parse(json['amount'] as String),
      percentage: double.parse(json['percentage'] as String),
      transactionCount: json['transaction_count'] as int,
    );
  }

  AccountBreakdownItem toEntity() => AccountBreakdownItem(
    accountId: accountId,
    accountName: accountName,
    accountType: accountType,
    amount: amount,
    percentage: percentage,
    transactionCount: transactionCount,
  );
}

class AccountBreakdownModel {
  final double totalAmount;
  final List<AccountBreakdownItemModel> items;

  AccountBreakdownModel({required this.totalAmount, required this.items});

  factory AccountBreakdownModel.fromJson(Map<String, dynamic> json) {
    return AccountBreakdownModel(
      totalAmount: double.parse(json['total_amount'] as String),
      items: (json['items'] as List<dynamic>)
          .map(
            (e) =>
                AccountBreakdownItemModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  AccountBreakdown toEntity() => AccountBreakdown(
    totalAmount: totalAmount,
    items: items.map((e) => e.toEntity()).toList(),
  );
}
