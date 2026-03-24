import 'package:equatable/equatable.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';

class HomeData extends Equatable {
  final List<Account> accounts;
  final List<Transaction> todayTransactions;

  const HomeData({
    required this.accounts,
    required this.todayTransactions,
  });

  @override
  List<Object?> get props => [accounts, todayTransactions];
}