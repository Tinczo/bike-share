import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/fault_report.dart';
import '../../domain/usecases/get_fault_report_history.dart';

part 'fault_history_event.dart';
part 'fault_history_state.dart';

@injectable
class FaultHistoryBloc extends Bloc<FaultHistoryEvent, FaultHistoryState> {
  final GetFaultReportHistory getFaultReportHistory;

  FaultHistoryBloc({required this.getFaultReportHistory})
    : super(const FaultHistoryInitial()) {
    on<FaultHistoryLoadRequested>(_onFaultHistoryLoadRequested);
  }

  Future<void> _onFaultHistoryLoadRequested(
    FaultHistoryLoadRequested event,
    Emitter<FaultHistoryState> emit,
  ) async {
    emit(const FaultHistoryLoading());

    final result = await getFaultReportHistory(NoParams());

    result.fold(
      (failure) => emit(FaultHistoryError(_mapFailureToMessage(failure))),
      (faultReports) {
        if (faultReports.isEmpty) {
          emit(const FaultHistoryEmpty());
        } else {
          emit(FaultHistoryLoaded(faultReports));
        }
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      NetworkFailure() => 'No internet connection',
      ServerFailure() => 'Server error. Please try again later.',
      _ => 'An unexpected error occurred',
    };
  }
}
