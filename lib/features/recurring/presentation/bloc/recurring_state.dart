import 'package:equatable/equatable.dart';
import 'package:pocketree/features/recurring/domain/entities/recurring_transaction.dart';

abstract class RecurringState extends Equatable {
  const RecurringState();
  @override
  List<Object?> get props => [];
}

class RecurringInitial extends RecurringState {
  const RecurringInitial();
}

class RecurringLoading extends RecurringState {
  const RecurringLoading();
}

class RecurringLoaded extends RecurringState {
  final List<RecurringTransaction> items;

  const RecurringLoaded(this.items);

  List<RecurringTransaction> get activeExpenses =>
      items.where((i) => i.isActive && i.isExpense).toList();

  List<RecurringTransaction> get activeIncomes =>
      items.where((i) => i.isActive && !i.isExpense).toList();

  List<RecurringTransaction> get sorted => [
    ...items.where((i) => i.isActive),
    ...items.where((i) => !i.isActive),
  ];

  double get totalMonthlyExpense =>
      activeExpenses.fold(0, (sum, item) => sum + item.monthlyEquivalent);

  double get totalMonthlyIncome =>
      activeIncomes.fold(0, (sum, item) => sum + item.monthlyEquivalent);

  double get netMonthlyCommitment => totalMonthlyIncome - totalMonthlyExpense;

  double get totalMonthlyCommitment => totalMonthlyExpense;

  @override
  List<Object?> get props => [items];
}

class RecurringError extends RecurringState {
  final String message;
  const RecurringError(this.message);
  @override
  List<Object?> get props => [message];
}

class RecurringActionSuccess extends RecurringState {
  final String message;
  const RecurringActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}