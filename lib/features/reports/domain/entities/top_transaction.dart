import 'package:equatable/equatable.dart';

class TopTransaction extends Equatable {
  final int transactionId;
  final DateTime date;
  final double amount;
  final String account;
  final String category;
  final String? note;

  const TopTransaction({
    required this.transactionId,
    required this.date,
    required this.amount,
    required this.account,
    required this.category,
    this.note,
  });

  @override
  List<Object?> get props => [
        transactionId,
        date,
        amount,
        account,
        category,
        note,
      ];
}
