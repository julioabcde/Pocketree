import 'package:equatable/equatable.dart';

class AccountBreakdownItem extends Equatable {
  final int accountId;
  final String accountName;
  final String accountType;
  final double amount;
  final double percentage;
  final int transactionCount;

  const AccountBreakdownItem({
    required this.accountId,
    required this.accountName,
    required this.accountType,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [
        accountId,
        accountName,
        accountType,
        amount,
        percentage,
        transactionCount,
      ];
}

class AccountBreakdown extends Equatable {
  final double totalAmount;
  final List<AccountBreakdownItem> items;

  const AccountBreakdown({
    required this.totalAmount,
    required this.items,
  });

  @override
  List<Object?> get props => [totalAmount, items];
}
