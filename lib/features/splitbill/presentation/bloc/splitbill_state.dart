import 'package:equatable/equatable.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_summary.dart';

abstract class SplitBillState extends Equatable {
  const SplitBillState();

  @override
  List<Object?> get props => [];
}

class SplitBillInitial extends SplitBillState {
  const SplitBillInitial();
}

class SplitBillLoading extends SplitBillState {
  const SplitBillLoading();
}

class SplitBillError extends SplitBillState {
  final String message;
  const SplitBillError(this.message);

  @override
  List<Object?> get props => [message];
}

class SplitBillActionSuccess extends SplitBillState {
  final String message;
  const SplitBillActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SplitBillCreateSuccess extends SplitBillState {
  final SplitBill createdBill;
  const SplitBillCreateSuccess(this.createdBill);

  @override
  List<Object?> get props => [createdBill];
}

class SplitBillSummaryLoaded extends SplitBillState {
  final List<SplitBillSummary> active;
  final List<SplitBillSummary> settled;
  final double totalToCollect;

  const SplitBillSummaryLoaded({
    required this.active,
    required this.settled,
    required this.totalToCollect,
  });

  @override
  List<Object?> get props => [active, settled, totalToCollect];
}
