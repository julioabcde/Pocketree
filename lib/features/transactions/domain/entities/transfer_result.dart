import 'package:equatable/equatable.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';

class TransferResult extends Equatable {
  final Transaction fromTransaction;
  final Transaction toTransaction;
  final String message;

  const TransferResult({
    required this.fromTransaction,
    required this.toTransaction,
    required this.message,
  });

  @override
  List<Object?> get props => [fromTransaction, toTransaction, message];
}