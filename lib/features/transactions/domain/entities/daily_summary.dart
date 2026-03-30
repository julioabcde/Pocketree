import 'package:equatable/equatable.dart';

class DailySummary extends Equatable {
  final DateTime date;
  final double income;
  final double expense;
  final double net;

  const DailySummary({
    required this.date,
    required this.income,
    required this.expense,
    required this.net,
  });

  bool get hasTransactions => income > 0 || expense > 0;

  @override
  List<Object?> get props => [date, income, expense, net];
}