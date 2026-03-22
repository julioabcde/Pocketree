import 'package:equatable/equatable.dart';
import 'package:pocketree/features/accounts/domain/entities/account_type.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class AccountDataRequested extends AccountEvent {
  const AccountDataRequested();
}

class AccountCreateRequested extends AccountEvent {
  final String name;
  final AccountType type;
  final double? initialBalance;

  const AccountCreateRequested({
    required this.name,
    required this.type,
    this.initialBalance,
  });

  @override
  List<Object?> get props => [name, type, initialBalance];
}

class AccountUpdateRequested extends AccountEvent {
  final int accountId;
  final String? name;
  final AccountType? type;

  const AccountUpdateRequested({
    required this.accountId,
    this.name,
    this.type,
  });

  @override
  List<Object?> get props => [accountId, name, type];
}

class AccountDeleteRequested extends AccountEvent {
  final int accountId;

  const AccountDeleteRequested({required this.accountId});

  @override
  List<Object?> get props => [accountId];
}