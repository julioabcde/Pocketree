import 'package:pocketree/features/accounts/domain/entities/account_summary.dart';

class AccountSummaryModel {
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;
  final int accountsCount;

  AccountSummaryModel({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.accountsCount,
  });

  factory AccountSummaryModel.fromJson(Map<String, dynamic> json) {
    return AccountSummaryModel(
      totalAssets: double.parse(json['total_assets'] as String),
      totalLiabilities: double.parse(json['total_liabilities'] as String),
      netWorth: double.parse(json['net_worth'] as String),
      accountsCount: json['accounts_count'] as int,
    );
  }

  AccountSummary toEntity(){
    return AccountSummary(
      totalAssets: totalAssets,
      totalLiabilities: totalLiabilities,
      netWorth: netWorth,
      accountsCount: accountsCount,
    );
  }
}
