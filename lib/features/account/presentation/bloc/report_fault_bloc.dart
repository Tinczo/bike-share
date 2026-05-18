import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/fault_report.dart';
import '../../domain/entities/fault_type.dart';
import '../../domain/usecases/report_fault.dart';

part 'report_fault_event.dart';
part 'report_fault_state.dart';

const String serverFailureMessage = 'Server error. Please try again later.';
const String networkFailureMessage = 'No internet connection';
const String unknownFailureMessage = 'An unexpected error occurred';

@injectable
class ReportFaultBloc extends Bloc<ReportFaultEvent, ReportFaultState> {
  final ReportFault reportFault;

  ReportFaultBloc({required this.reportFault})
    : super(const ReportFaultInitial()) {
    on<FaultTypeSelected>(_onFaultTypeSelected);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<FaultReportSubmitted>(_onFaultReportSubmitted);
  }

  void _onFaultTypeSelected(
    FaultTypeSelected event,
    Emitter<ReportFaultState> emit,
  ) {
    final currentState = state;
    final description = currentState is ReportFaultTypeSelected
        ? currentState.description
        : null;

    emit(ReportFaultTypeSelected(event.type, description: description));
  }

  void _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<ReportFaultState> emit,
  ) {
    final currentState = state;
    if (currentState is ReportFaultTypeSelected) {
      emit(
        ReportFaultTypeSelected(
          currentState.selectedType,
          description: event.description,
        ),
      );
    }
  }

  Future<void> _onFaultReportSubmitted(
    FaultReportSubmitted event,
    Emitter<ReportFaultState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReportFaultTypeSelected) {
      emit(const ReportFaultFailure('Please select a fault type'));
      return;
    }

    emit(const ReportFaultSubmitting());

    final result = await reportFault(
      ReportFaultParams(
        bikeId: event.bikeId,
        type: currentState.selectedType,
        description: currentState.description,
      ),
    );

    result.fold(
      (failure) => emit(ReportFaultFailure(_mapFailureToMessage(failure))),
      (faultReport) => emit(ReportFaultSuccess(faultReport)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      NetworkFailure() => networkFailureMessage,
      ServerFailure() => serverFailureMessage,
      _ => unknownFailureMessage,
    };
  }
}
