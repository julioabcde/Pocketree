import 'package:equatable/equatable.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';

class HomeData extends Equatable {
  final List<Account> accounts;

  const HomeData({required this.accounts});

  @override
  List<Object?> get props => [accounts];
}
