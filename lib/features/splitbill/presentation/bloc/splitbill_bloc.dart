import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketree/features/splitbill/domain/usecases/create_split_bill_usecase.dart';
import 'package:pocketree/features/splitbill/domain/usecases/delete_split_bill_usecase.dart';
import 'package:pocketree/features/splitbill/domain/usecases/get_split_bills_summary_usecase.dart';
import 'splitbill_event.dart';
import 'splitbill_state.dart';

class SplitBillBloc extends Bloc<SplitBillEvent, SplitBillState> {
  final GetSplitBillsSummaryUseCase getSplitBillsSummary;
  final CreateSplitBillUseCase createSplitBill;
  final DeleteSplitBillUseCase deleteSplitBill;

  SplitBillBloc({
    required this.getSplitBillsSummary,
    required this.createSplitBill,
    required this.deleteSplitBill,
  }) : super(const SplitBillInitial()) {
    on<SplitBillSummaryRequested>(_onSummaryRequested);
    on<SplitBillDataRefreshed>(_onDataRefreshed);
    on<SplitBillCreateRequested>(_onCreateRequested);
    on<SplitBillDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onDataRefreshed(
    SplitBillDataRefreshed event,
    Emitter<SplitBillState> emit,
  ) async {
    await _fetchSummary(emit);
    if (!event.completer.isCompleted) event.completer.complete();
  }

  Future<void> _onCreateRequested(
    SplitBillCreateRequested event,
    Emitter<SplitBillState> emit,
  ) async {
    final result = await createSplitBill(
      title: event.title,
      date: event.date,
      items: event.items,
      charges: event.charges,
      note: event.note,
    );

    result.fold((failure) => emit(SplitBillError(failure.message)), (
      bill,
    ) {
      emit(SplitBillCreateSuccess(bill));
      add(const SplitBillSummaryRequested());
    });
  }

  Future<void> _onDeleteRequested(
    SplitBillDeleteRequested event,
    Emitter<SplitBillState> emit,
  ) async {
    final result = await deleteSplitBill(event.billId);

    result.fold((failure) => emit(SplitBillError(failure.message)), (_) {
      emit(const SplitBillActionSuccess('Bill deleted'));
      add(const SplitBillSummaryRequested());
    });
  }

  Future<void> _onSummaryRequested(
    SplitBillSummaryRequested event,
    Emitter<SplitBillState> emit,
  ) async {
    if (state is! SplitBillSummaryLoaded) emit(const SplitBillLoading());
    await _fetchSummary(emit);
  }

  Future<void> _fetchSummary(Emitter<SplitBillState> emit) async {
    final result = await getSplitBillsSummary();
    result.fold((failure) => emit(SplitBillError(failure.message)), (
      summaries,
    ) {
      final active = summaries.where((s) => !s.isFullySettled).toList();
      final settled = summaries.where((s) => s.isFullySettled).toList();
      final totalToCollect = active
          .where((s) => s.settlementSummary != null)
          .fold(
            0.0,
            (sum, s) => sum + s.settlementSummary!.remainingDebtAmount,
          );

      emit(
        SplitBillSummaryLoaded(
          active: active,
          settled: settled,
          totalToCollect: totalToCollect,
        ),
      );
    });
  }

}
