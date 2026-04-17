import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/reports/domain/usecases/get_reports_data_usecase.dart';
import 'package:pocketree/features/reports/presentation/bloc/reports_event.dart';
import 'package:pocketree/features/reports/presentation/bloc/reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetReportsDataUseCase getReportsData;

  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  int? _accountId;
  String _groupBy = 'day';
  String _type = 'expense';
  int _topN = 10;
  int _limit = 5;

  ReportsBloc({required this.getReportsData}) : super(const ReportsInitial()) {
    on<ReportsDataRequested>(_onDataRequested);
    on<ReportsDataRefreshed>(_onDataRefreshed);
    on<ReportsGroupByChanged>(_onGroupByChanged);
    on<ReportsTypeChanged>(_onTypeChanged);
  }

  Future<void> _onDataRequested(
    ReportsDataRequested event,
    Emitter<ReportsState> emit,
  ) async {
    _startDate = event.startDate;
    _endDate = event.endDate;
    _accountId = event.accountId;
    _groupBy = event.groupBy;
    _type = event.type;
    _topN = event.topN;
    _limit = event.limit;

    emit(const ReportsLoading());
    await _loadAndEmit(emit);
  }

  Future<void> _onDataRefreshed(
    ReportsDataRefreshed event,
    Emitter<ReportsState> emit,
  ) async {
    await _loadAndEmit(emit);
    if (!event.completer.isCompleted) event.completer.complete();
  }

  Future<void> _loadAndEmit(Emitter<ReportsState> emit) async {
    final result = await getReportsData(
      startDate: _startDate,
      endDate: _endDate,
      accountId: _accountId,
      groupBy: _groupBy,
      type: _type,
      topN: _topN,
      limit: _limit,
    );

    result.fold(
      (failure) => emit(ReportsError(_mapFailure(failure))),
      (data) => emit(ReportsLoaded(
        data: data,
        startDate: _startDate,
        endDate: _endDate,
        accountId: _accountId,
        groupBy: _groupBy,
        type: _type,
        topN: _topN,
        limit: _limit,
      )),
    );
  }

  Future<void> _onGroupByChanged(
    ReportsGroupByChanged event,
    Emitter<ReportsState> emit,
  ) async {
    _groupBy = event.groupBy;
    add(ReportsDataRequested(
      startDate: _startDate,
      endDate: _endDate,
      accountId: _accountId,
      groupBy: _groupBy,
      type: _type,
      topN: _topN,
      limit: _limit,
    ));
  }

  Future<void> _onTypeChanged(
    ReportsTypeChanged event,
    Emitter<ReportsState> emit,
  ) async {
    _type = event.type;
    add(ReportsDataRequested(
      startDate: _startDate,
      endDate: _endDate,
      accountId: _accountId,
      groupBy: _groupBy,
      type: _type,
      topN: _topN,
      limit: _limit,
    ));
  }

  String _mapFailure(Failure failure) => switch (failure) {
        ServerFailure f => f.message,
        NetworkFailure _ =>
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        UnauthorizedFailure _ => failure.message,
        CacheFailure _ => 'Terjadi kesalahan lokal. Silakan coba lagi.',
      };
}
