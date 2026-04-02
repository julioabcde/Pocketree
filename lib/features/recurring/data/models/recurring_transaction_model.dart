import 'package:pocketree/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';

class RecurringTransactionModel {
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

  RecurringTransactionModel({
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

  factory RecurringTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecurringTransactionModel(
      id: json['id'] as int,
      accountId: json['account_id'] as int,
      categoryId: json['category_id'] as int?,
      type: TransactionType.fromString(json['type'] as String),
      amount: double.parse(json['amount'] as String),
      frequency: RecurringFrequency.fromString(json['frequency'] as String),
      dayOfWeek: json['day_of_week'] as int?,
      dayOfMonth: json['day_of_month'] as int?,
      monthOfYear: json['month_of_year'] as int?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      nextDueDate: DateTime.parse(json['next_due_date'] as String),
      lastRunAt: json['last_run_at'] != null
          ? DateTime.parse(json['last_run_at'] as String)
          : null,
      timezone: json['timezone'] as String,
      autoCreate: json['auto_create'] as bool,
      maxOccurrences: json['max_occurrences'] as int?,
      occurrenceCount: json['occurrence_count'] as int,
      isActive: json['is_active'] as bool,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  RecurringTransaction toEntity() {
    return RecurringTransaction(
      id: id,
      accountId: accountId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      frequency: frequency,
      dayOfWeek: dayOfWeek,
      dayOfMonth: dayOfMonth,
      monthOfYear: monthOfYear,
      startDate: startDate,
      endDate: endDate,
      nextDueDate: nextDueDate,
      lastRunAt: lastRunAt,
      timezone: timezone,
      autoCreate: autoCreate,
      maxOccurrences: maxOccurrences,
      occurrenceCount: occurrenceCount,
      isActive: isActive,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
