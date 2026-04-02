import 'package:equatable/equatable.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';

enum RecurringFrequency {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly'),
  yearly('yearly');

  final String value;
  const RecurringFrequency(this.value);

  static RecurringFrequency fromString(String value) {
    return RecurringFrequency.values.firstWhere(
      (f) => f.value == value,
      orElse: () => throw ArgumentError('Unknown frequency: $value'),
    );
  }
}

class RecurringTransaction extends Equatable {
  final int id;
  final int accountId;
  final int? categoryId;
  final TransactionType type;
  final double amount;
  final RecurringFrequency frequency;
  final int? dayOfWeek;
  final int? dayOfMonth;
  final int? monthOfYear;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextDueDate;
  final DateTime? lastRunAt;
  final String timezone;
  final bool autoCreate;
  final int? maxOccurrences;
  final int occurrenceCount;
  final bool isActive;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringTransaction({
    required this.id,
    required this.accountId,
    this.categoryId,
    required this.type,
    required this.amount,
    required this.frequency,
    this.dayOfWeek,
    this.dayOfMonth,
    this.monthOfYear,
    required this.startDate,
    this.endDate,
    required this.nextDueDate,
    this.lastRunAt,
    required this.timezone,
    required this.autoCreate,
    this.maxOccurrences,
    required this.occurrenceCount,
    required this.isActive,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isExpense => type == TransactionType.expense;
  bool get isPaused => !isActive;

  double get monthlyEquivalent {
    if (!isActive) return 0;
    return switch (frequency) {
      RecurringFrequency.daily   => amount * 30,
      RecurringFrequency.weekly  => amount * 4.33,
      RecurringFrequency.monthly => amount,
      RecurringFrequency.yearly  => amount / 12,
    };
  }

  @override
  List<Object?> get props => [
    id, accountId, categoryId, type, amount, frequency,
    dayOfWeek, dayOfMonth, monthOfYear, startDate, endDate,
    nextDueDate, lastRunAt, timezone, autoCreate, maxOccurrences,
    occurrenceCount, isActive, note, createdAt, updatedAt,
  ];
}