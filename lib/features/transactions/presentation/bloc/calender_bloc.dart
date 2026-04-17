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
    on<CalendarDataRefreshed>(_onDataRefreshed);
  }


  Future<void> _onMonthRequested(
    CalendarMonthRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarLoading());
    await _loadMonthAndDay(
      emit: emit,
      month: event.month,
      selectedDate: null,
    );
  }

  Future<void> _onDataRefreshed(
    CalendarDataRefreshed event,
    Emitter<CalendarState> emit,
  ) async {
    final current = state;
    final month = current is CalendarLoaded ? current.currentMonth : DateTime.now();
    final selected = current is CalendarLoaded ? current.selectedDate : null;
    await _loadMonthAndDay(emit: emit, month: month, selectedDate: selected);
    if (!event.completer.isCompleted) event.completer.complete();
  }

  Future<void> _loadMonthAndDay({
    required Emitter<CalendarState> emit,
    required DateTime month,
    required DateTime? selectedDate,
  }) async {
    final monthStr = _monthFormat.format(month);

    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final monthFilter = TransactionFilter(
      startDate: monthStart,
      endDate: monthEnd,
    );

    final (dailyResult, summaryResult) = await (
      getDailySummary(month: monthStr),
      getTransactionSummary(filter: monthFilter),
    ).wait;

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

    final now = DateTime.now();
    final isCurrentMonth = month.year == now.year && month.month == now.month;
    final resolvedSelected = selectedDate ??
        (isCurrentMonth
            ? DateTime(now.year, now.month, now.day)
            : monthStart);

    final dayFilter = TransactionFilter(
      startDate: resolvedSelected,
      endDate: resolvedSelected,
    );
    final dayResult = await getTransactions(filter: dayFilter);
    final dayTransactions = dayResult.fold((_) => <dynamic>[], (list) => list);

    emit(CalendarLoaded(
      currentMonth: monthStart,
      dailySummaries: dailySummaries,
      monthlySummary: monthlySummary,
      selectedDate: resolvedSelected,
      selectedDayTransactions: List.unmodifiable(dayTransactions),
    ));
  }


  Future<void> _onDaySelected(
    CalendarDaySelected event,
    Emitter<CalendarState> emit,
  ) async {
    final current = state;
    if (current is! CalendarLoaded) return;

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

    if (state is! CalendarLoaded) return;

    emit((state as CalendarLoaded).copyWith(
      selectedDayTransactions: List.unmodifiable(transactions),
      isLoadingDay: false,
    ));
  }


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