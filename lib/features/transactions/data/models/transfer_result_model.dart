import 'package:pocketree/features/transactions/data/models/transaction_model.dart';
import 'package:pocketree/features/transactions/domain/entities/transfer_result.dart';

class TransferResultModel {
  final TransactionModel fromTransaction;
  final TransactionModel toTransaction;
  final String message;

  TransferResultModel({
    required this.fromTransaction,
    required this.toTransaction,
    required this.message,
  });

  factory TransferResultModel.fromJson(Map<String, dynamic> json) {
    return TransferResultModel(
      fromTransaction: TransactionModel.fromJson(
        json['from_transaction'] as Map<String, dynamic>,
      ),
      toTransaction: TransactionModel.fromJson(
        json['to_transaction'] as Map<String, dynamic>,
      ),
      message: json['message'] as String,
    );
  }

  TransferResult toEntity() {
    return TransferResult(
      fromTransaction: fromTransaction.toEntity(),
      toTransaction: toTransaction.toEntity(),
      message: message,
    );
  }
}
