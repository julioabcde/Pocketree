import 'package:equatable/equatable.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';

class TransactionFilter extends Equatable {
  final int? accountId;
  final int? categoryId;
  final TransactionType? type;
  final DateTime? startDate;
  final DateTime? endDate;

  const TransactionFilter({
    this.accountId,
    this.categoryId,
    this.type,
    this.startDate,
    this.endDate,
  });

  bool get hasFilters =>
      accountId != null ||
      categoryId != null ||
      type != null ||
      startDate != null ||
      endDate != null;

  TransactionFilter copyWith({
    int? accountId,
    int? categoryId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TransactionFilter(
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
    accountId,
    categoryId,
    type,
    startDate,
    endDate,
  ];
}