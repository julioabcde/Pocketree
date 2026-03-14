import 'package:equatable/equatable.dart';
import 'package:pocketree/features/accounts/domain/entities/account_type.dart';

class Account extends Equatable {
  final int id;
  final String name;
  final AccountType type;
  final double balance;
  final double initialBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.initialBalance,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    balance,
    initialBalance,
    createdAt,
    updatedAt,
  ];
}