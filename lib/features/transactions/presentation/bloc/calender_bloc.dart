import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/transactions/domain/entities/daily_summary.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_filter.dart';
import 'package:pocketree/features/transactions/domain/usecases/get_daily_summary_usecase.dart';
import 'package:pocketree/features/transactions/domain/usecases/get_transaction_summary_usecase.dart';
import 'package:pocketree/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:pocketree/features/transactions/presentation/bloc/calender_event.dart';
import 'package:pocketree/features/transactions/presentation/bloc/calender_state.dart';


class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final GetDailySummaryUseCase getDailySummary;
  final GetTransactionsUseCase getTransactions;
  final GetTransactionSummaryUseCase getTransactionSummary;

  static final DateFormat _monthFormat = DateFormat('yyyy-MM');

  CalendarBloc({
    required this.getDailySummary,
    required this.getTransactions,
    required this.getTransactionSummary,
  }) : super(const CalendarInitial()) {
    on<CalendarMonthRequested>(_onMonthRequested);
    on<CalendarDaySelected>(_onDaySelected);
  }

  //  Month Load 

  Future<void> _onMonthRequested(
    CalendarMonthRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarLoading());

    final monthStr = _monthFormat.format(event.month);

    // Build filter for the full month's summary
    final monthStart = DateTime(event.month.year, event.month.month, 1);
    final monthEnd = DateTime(event.month.year, event.month.month + 1, 0);
    final monthFilter = TransactionFilter(
      startDate: monthStart,
      endDate: monthEnd,
    );

    // Parallel fetch: daily breakdown + month totals
    final (dailyResult, summaryResult) = await (
      getDailySummary(month: monthStr),
      getTransactionSummary(filter: monthFilter),
    ).wait;

    // Handle failures
    final dailySummaries = dailyResult.fold(
      (failure) => null,
      (list) => _toSparseMap(list),
    );
    final monthlySummary = summaryResult.fold(
      (failure) => null,
      (summary) => summary,
    );

    if (dailySummaries == null || monthlySummary == null) {
      final failure = dailyResult.fold((f) => f, (_) => null) ??
          summaryResult.fold((f) => f, (_) => null);
      emit(CalendarError(_mapFailureToMessage(failure!)));
      return;
    }

    // Determine default selected day
    final now = DateTime.now();
    final isCurrentMonth =
        event.month.year == now.year && event.month.month == now.month;
    final selectedDate = isCurrentMonth
        ? DateTime(now.year, now.month, now.day)
        : monthStart;

    // Fetch selected day's transactions
    final dayFilter = TransactionFilter(
      startDate: selectedDate,
      endDate: selectedDate,
    );
    final dayResult = await getTransactions(filter: dayFilter);
    final dayTransactions = dayResult.fold((_) => <dynamic>[], (list) => list);

    emit(CalendarLoaded(
      currentMonth: monthStart,
      dailySummaries: dailySummaries,
      monthlySummary: monthlySummary,
      selectedDate: selectedDate,
      selectedDayTransactions: List.unmodifiable(dayTransactions),
    ));
  }

  //  Day Selection 

  Future<void> _onDaySelected(
    CalendarDaySelected event,
    Emitter<CalendarState> emit,
  ) async {
    final current = state;
    if (current is! CalendarLoaded) return;

    // Immediately update selected date + show day loading
    emit(current.copyWith(
      selectedDate: event.date,
      isLoadingDay: true,
    ));

    final dayFilter = TransactionFilter(
      startDate: event.date,
      endDate: event.date,
    );
    final result = await getTransactions(filter: dayFilter);
    final transactions = result.fold((_) => <dynamic>[], (list) => list);

    // Guard: state might have changed while awaiting
    if (state is! CalendarLoaded) return;

    emit((state as CalendarLoaded).copyWith(
      selectedDayTransactions: List.unmodifiable(transactions),
      isLoadingDay: false,
    ));
  }

  //  Helpers 

  /// Converts the sparse API list into a day-number-keyed map for O(1) lookup.
  Map<int, DailySummary> _toSparseMap(List<DailySummary> list) {
    return {for (final ds in list) ds.date.day: ds};
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