import 'package:equatable/equatable.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_filter.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_summary.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final TransactionSummary summary;
  final TransactionFilter filter;
  final bool hasReachedEnd;
  final bool isLoadingMore;
  final bool isPerformingAction;

  const TransactionLoaded({
    required this.transactions,
    required this.summary,
    this.filter = const TransactionFilter(),
    this.hasReachedEnd = false,
    this.isLoadingMore = false,
    this.isPerformingAction = false,
  });

  TransactionLoaded copyWith({
    List<Transaction>? transactions,
    TransactionSummary? summary,
    TransactionFilter? filter,
    bool? hasReachedEnd,
    bool? isLoadingMore,
    bool? isPerformingAction,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      summary: summary ?? this.summary,
      filter: filter ?? this.filter,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    summary,
    filter,
    hasReachedEnd,
    isLoadingMore,
    isPerformingAction,
  ];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionActionSuccess extends TransactionState {
  final String message;

  const TransactionActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}