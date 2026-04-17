
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_filter.dart';
import 'package:pocketree/features/transactions/domain/usecases/create_transaction_usecase.dart';
import 'package:pocketree/features/transactions/domain/usecases/create_transfer_usecase.dart';
import 'package:pocketree/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'package:pocketree/features/transactions/domain/usecases/get_transaction_summary_usecase.dart';
import 'package:pocketree/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:pocketree/features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase getTransactions;
  final GetTransactionSummaryUseCase getTransactionSummary;
  final CreateTransactionUseCase createTransaction;
  final UpdateTransactionUseCase updateTransaction;
  final DeleteTransactionUseCase deleteTransaction;
  final CreateTransferUseCase createTransfer;

  static const int _pageSize = 20;

  TransactionBloc({
    required this.getTransactions,
    required this.getTransactionSummary,
    required this.createTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
    required this.createTransfer,
  }) : super(const TransactionInitial()) {
    on<TransactionDataRequested>(_onDataRequested);
    on<TransactionDataRefreshed>(_onDataRefreshed);
    on<TransactionNextPageRequested>(_onNextPageRequested);
    on<TransactionCreateRequested>(_onCreateRequested);
    on<TransactionUpdateRequested>(_onUpdateRequested);
    on<TransactionDeleteRequested>(_onDeleteRequested);
    on<TransactionTransferRequested>(_onTransferRequested);
  }

  Future<void> _onDataRequested(
    TransactionDataRequested event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is! TransactionLoaded) {
      emit(const TransactionLoading());
    }
    await _fetchAndEmit(emit, event.filter);
  }

  Future<void> _onDataRefreshed(
    TransactionDataRefreshed event,
    Emitter<TransactionState> emit,
  ) async {
    final filter = event.filter ?? _currentFilter;
    await _fetchAndEmit(emit, filter);
    if (!event.completer.isCompleted) event.completer.complete();
  }

  Future<void> _fetchAndEmit(
    Emitter<TransactionState> emit,
    TransactionFilter filter,
  ) async {
    final (transactionsResult, summaryResult) = await (
      getTransactions(filter: filter, limit: _pageSize),
      getTransactionSummary(filter: filter),
    ).wait;

    transactionsResult.fold(
      (failure) => emit(TransactionError(_mapFailureToMessage(failure))),
      (transactions) => summaryResult.fold(
        (failure) => emit(TransactionError(_mapFailureToMessage(failure))),
        (summary) => emit(
          TransactionLoaded(
            transactions: transactions,
            summary: summary,
            filter: filter,
            hasReachedEnd: transactions.length < _pageSize,
          ),
        ),
      ),
    );
  }

  Future<void> _onNextPageRequested(
    TransactionNextPageRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransactionLoaded ||
        currentState.hasReachedEnd ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await getTransactions(
      filter: currentState.filter,
      limit: _pageSize,
      offset: currentState.transactions.length,
    );

    result.fold(
      (_) => emit(currentState.copyWith(isLoadingMore: false)),
      (newTransactions) => emit(
        currentState.copyWith(
          transactions: [...currentState.transactions, ...newTransactions],
          hasReachedEnd: newTransactions.length < _pageSize,
          isLoadingMore: false,
        ),
      ),
    );
  }

  Future<void> _onCreateRequested(
    TransactionCreateRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final currentFilter = _currentFilter;

    if (state is TransactionLoaded) {
      emit((state as TransactionLoaded).copyWith(isPerformingAction: true));
    }

    final result = await createTransaction(
      accountId: event.accountId,
      type: event.type,
      amount: event.amount,
      date: event.date,
      categoryId: event.categoryId,
      note: event.note,
    );

    result.fold(
      (failure) => emit(TransactionError(_mapFailureToMessage(failure))),
      (_) {
        emit(
          const TransactionActionSuccess('Transaction created successfully'),
        );
        add(TransactionDataRequested(filter: currentFilter));
      },
    );
  }

  Future<void> _onUpdateRequested(
    TransactionUpdateRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final currentFilter = _currentFilter;

    if (state is TransactionLoaded) {
      emit((state as TransactionLoaded).copyWith(isPerformingAction: true));
    }

    final result = await updateTransaction(
      transactionId: event.transactionId,
      accountId: event.accountId,
      categoryId: event.categoryId,
      amount: event.amount,
      date: event.date,
      note: event.note,
    );

    result.fold(
      (failure) => emit(TransactionError(_mapFailureToMessage(failure))),
      (_) {
        emit(
          const TransactionActionSuccess('Transaction updated successfully'),
        );
        add(TransactionDataRequested(filter: currentFilter));
      },
    );
  }

  Future<void> _onDeleteRequested(
    TransactionDeleteRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final currentFilter = _currentFilter;

    if (state is TransactionLoaded) {
      emit((state as TransactionLoaded).copyWith(isPerformingAction: true));
    }

    final result = await deleteTransaction(event.transactionId);

    result.fold(
      (failure) => emit(TransactionError(_mapFailureToMessage(failure))),
      (_) {
        emit(
          const TransactionActionSuccess('Transaction deleted successfully'),
        );
        add(TransactionDataRequested(filter: currentFilter));
      },
    );
  }

  Future<void> _onTransferRequested(
    TransactionTransferRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final currentFilter = _currentFilter;

    if (state is TransactionLoaded) {
      emit((state as TransactionLoaded).copyWith(isPerformingAction: true));
    }

    final result = await createTransfer(
      fromAccountId: event.fromAccountId,
      toAccountId: event.toAccountId,
      amount: event.amount,
      date: event.date,
      note: event.note,
    );

    result.fold(
      (failure) => emit(TransactionError(_mapFailureToMessage(failure))),
      (transferResult) {
        emit(TransactionActionSuccess(transferResult.message));
        add(TransactionDataRequested(filter: currentFilter));
      },
    );
  }

  TransactionFilter get _currentFilter {
    final current = state;
    return current is TransactionLoaded
        ? current.filter
        : const TransactionFilter();
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure f => f.message,
      NetworkFailure _ =>
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      UnauthorizedFailure _ => failure.message,
      CacheFailure _ => 'Terjadi kesalahan lokal. Silakan coba lagi.',
    };
  }
}
