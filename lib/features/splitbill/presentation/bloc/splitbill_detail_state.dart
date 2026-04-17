import 'package:equatable/equatable.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_detail.dart';

abstract class SplitBillDetailState extends Equatable {
  const SplitBillDetailState();

  @override
  List<Object?> get props => [];
}

class SplitBillDetailInitial extends SplitBillDetailState {
  const SplitBillDetailInitial();
}

class SplitBillDetailLoading extends SplitBillDetailState {
  const SplitBillDetailLoading();
}

class SplitBillDetailLoaded extends SplitBillDetailState {
  final SplitBillDetail detail;
  final bool isPerformingAction;

  const SplitBillDetailLoaded({
    required this.detail,
    this.isPerformingAction = false,
  });

  SplitBillDetailLoaded copyWith({
    SplitBillDetail? detail,
    bool? isPerformingAction,
  }) {
    return SplitBillDetailLoaded(
      detail: detail ?? this.detail,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
    );
  }

  @override
  List<Object?> get props => [detail, isPerformingAction];
}

class SplitBillDetailError extends SplitBillDetailState {
  final String message;
  const SplitBillDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class SplitBillDetailActionSuccess extends SplitBillDetailState {
  final String message;
  const SplitBillDetailActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}