import 'package:equatable/equatable.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/domain/entities/account_summary.dart';
import 'package:pocketree/features/accounts/domain/entities/account_type.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {
  const AccountInitial();
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountLoaded extends AccountState {
  final List<Account> accounts;
  final AccountSummary summary;
  final bool isPerformingAction;

  const AccountLoaded({
    required this.accounts,
    required this.summary,
    this.isPerformingAction = false,
  });

  List<Account> get cashAccounts =>
      accounts.where((a) => a.type == AccountType.cash).toList();

  List<Account> get bankAccounts =>
      accounts.where((a) => a.type == AccountType.bankAccount).toList();

  List<Account> get eWalletAccounts =>
      accounts.where((a) => a.type == AccountType.eWallet).toList();

  List<Account> get creditCardAccounts =>
      accounts.where((a) => a.type == AccountType.creditCard).toList();

  AccountLoaded copyWith({bool? isPerformingAction}) {
    return AccountLoaded(
      accounts: accounts,
      summary: summary,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
    );
  }

  @override
  List<Object?> get props => [accounts, summary, isPerformingAction];
}

class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountActionSuccess extends AccountState {
  final String message;

  const AccountActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
