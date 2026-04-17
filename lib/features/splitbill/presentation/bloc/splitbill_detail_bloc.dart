import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketree/features/splitbill/domain/usecases/calculate_split_usecase.dart';
import 'package:pocketree/features/splitbill/domain/usecases/delete_split_bill_usecase.dart';
import 'package:pocketree/features/splitbill/domain/usecases/get_split_bill_detail_usecase.dart';
import 'package:pocketree/features/splitbill/domain/usecases/settle_debt_usecase.dart';
import 'splitbill_detail_event.dart';
import 'splitbill_detail_state.dart';

class SplitBillDetailBloc
    extends Bloc<SplitBillDetailEvent, SplitBillDetailState> {
  final GetSplitBillDetailUseCase getSplitBillDetail;
  final CalculateSplitUseCase calculateSplit;
  final SettleDebtUseCase settleDebt;
  final DeleteSplitBillUseCase deleteSplitBill;
  int? _currentBillId;

  SplitBillDetailBloc({
    required this.getSplitBillDetail,
    required this.calculateSplit,
    required this.settleDebt,
    required this.deleteSplitBill,
  }) : super(const SplitBillDetailInitial()) {
    on<SplitBillDetailRequested>(_onDetailRequested);
    on<SplitBillDetailRefreshed>(_onDetailRefreshed);
    on<SplitBillCalculateRequested>(_onCalculateRequested);
    on<SplitBillSettleRequested>(_onSettleRequested);
    on<SplitBillDetailDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onDetailRequested(
    SplitBillDetailRequested event,
    Emitter<SplitBillDetailState> emit,
  ) async {
    _currentBillId = event.billId;

    if (state is! SplitBillDetailLoaded) emit(const SplitBillDetailLoading());
    await _fetchDetail(event.billId, emit);
  }

  Future<void> _onDetailRefreshed(
    SplitBillDetailRefreshed event,
    Emitter<SplitBillDetailState> emit,
  ) async {
    _currentBillId = event.billId;
    await _fetchDetail(event.billId, emit);
    if (!event.completer.isCompleted) event.completer.complete();
  }

  Future<void> _fetchDetail(
    int billId,
    Emitter<SplitBillDetailState> emit,
  ) async {
    final result = await getSplitBillDetail(billId);
    result.fold(
      (failure) => emit(SplitBillDetailError(failure.message)),
      (detail) => emit(SplitBillDetailLoaded(detail: detail)),
    );
  }

  Future<void> _onCalculateRequested(
    SplitBillCalculateRequested event,
    Emitter<SplitBillDetailState> emit,
  ) async {
    final billId = _currentBillId;
    if (billId == null) return;

    if (state is SplitBillDetailLoaded) {
      emit((state as SplitBillDetailLoaded).copyWith(isPerformingAction: true));
    }

    final result = await calculateSplit(
      billId: billId,
      participants: event.participants,
      shares: event.shares,
      accountId: event.accountId,
    );

    result.fold((failure) => emit(SplitBillDetailError(failure.message)), (
      detail,
    ) {
      emit(const SplitBillDetailActionSuccess('Split calculated'));
      emit(SplitBillDetailLoaded(detail: detail));
    });
  }

  Future<void> _onSettleRequested(
    SplitBillSettleRequested event,
    Emitter<SplitBillDetailState> emit,
  ) async {
    final billId = _currentBillId;
    if (billId == null) return;

    if (state is SplitBillDetailLoaded) {
      emit((state as SplitBillDetailLoaded).copyWith(isPerformingAction: true));
    }

    final settleResult = await settleDebt(
      billId: billId,
      debtId: event.debtId,
      amount: event.amount,
      accountId: event.accountId,
    );

    await settleResult.fold(
      (failure) async => emit(SplitBillDetailError(failure.message)),
      (_) async {
        final detailResult = await getSplitBillDetail(billId);
        detailResult.fold(
          (failure) => emit(SplitBillDetailError(failure.message)),
          (detail) {
            emit(const SplitBillDetailActionSuccess('Payment recorded'));
            emit(SplitBillDetailLoaded(detail: detail));
          },
        );
      },
    );
  }

  Future<void> _onDeleteRequested(
    SplitBillDetailDeleteRequested event,
    Emitter<SplitBillDetailState> emit,
  ) async {
    emit(const SplitBillDetailLoading());

    final result = await deleteSplitBill(event.billId);
    result.fold(
      (failure) => emit(SplitBillDetailError(failure.message)),
      (_) => emit(const SplitBillDetailActionSuccess('Bill deleted')),
    );
  }

}
