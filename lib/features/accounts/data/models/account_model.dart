import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/domain/entities/account_type.dart';

class AccountModel{
  final int id;
  final String name;
  final AccountType type;
  final double balance;
  final double initialBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.initialBalance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: AccountType.fromString(json['type'] as String),
      balance: double.parse(json['balance'] as String),
      initialBalance: double.parse(json['initialBalance'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Account toEntity() {
    return Account(
      id: id,
      name: name,
      type: type,
      balance: balance,
      initialBalance: initialBalance,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}