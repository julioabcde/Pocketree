import 'package:equatable/equatable.dart';
import 'package:pocketree/features/transactions/domain/entities/daily_summary.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_summary.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {
  const CalendarInitial();
}

class CalendarLoading extends CalendarState {
  const CalendarLoading();
}

class CalendarLoaded extends CalendarState {
  final DateTime currentMonth;

  final Map<int, DailySummary> dailySummaries;

  final TransactionSummary monthlySummary;

  final DateTime selectedDate;

  final List<Transaction> selectedDayTransactions;

  final bool isLoadingDay;

  const CalendarLoaded({
    required this.currentMonth,
    required this.dailySummaries,
    required this.monthlySummary,
    required this.selectedDate,
    required this.selectedDayTransactions,
    this.isLoadingDay = false,
  });

  CalendarLoaded copyWith({
    DateTime? currentMonth,
    Map<int, DailySummary>? dailySummaries,
    TransactionSummary? monthlySummary,
    DateTime? selectedDate,
    List<Transaction>? selectedDayTransactions,
    bool? isLoadingDay,
  }) {
    return CalendarLoaded(
      currentMonth: currentMonth ?? this.currentMonth,
      dailySummaries: dailySummaries ?? this.dailySummaries,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDayTransactions:
          selectedDayTransactions ?? this.selectedDayTransactions,
      isLoadingDay: isLoadingDay ?? this.isLoadingDay,
    );
  }

  @override
  List<Object?> get props => [
    currentMonth,
    dailySummaries,
    monthlySummary,
    selectedDate,
    selectedDayTransactions,
    isLoadingDay,
  ];
}

class CalendarError extends CalendarState {
  final String message;

  const CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}
