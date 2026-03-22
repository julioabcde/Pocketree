import 'package:equatable/equatable.dart';

class AccountSummary extends Equatable {
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;
  final int accountsCount;

  const AccountSummary({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.accountsCount,
  });

  @override
  List<Object?> get props => [
    totalAssets,
    totalLiabilities,
    netWorth,
    accountsCount,
  ];
}