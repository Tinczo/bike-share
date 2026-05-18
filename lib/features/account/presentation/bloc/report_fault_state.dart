part of 'report_fault_bloc.dart';

sealed class ReportFaultState extends Equatable {
  const ReportFaultState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any fault type is selected.
class ReportFaultInitial extends ReportFaultState {
  const ReportFaultInitial();
}

/// State when a fault type has been selected.
class ReportFaultTypeSelected extends ReportFaultState {
  final FaultType selectedType;
  final String? description;

  const ReportFaultTypeSelected(this.selectedType, {this.description});

  @override
  List<Object?> get props => [selectedType, description];
}

/// State while the fault report is being submitted.
class ReportFaultSubmitting extends ReportFaultState {
  const ReportFaultSubmitting();
}

/// State when the fault report was submitted successfully.
class ReportFaultSuccess extends ReportFaultState {
  final FaultReport faultReport;

  const ReportFaultSuccess(this.faultReport);

  @override
  List<Object?> get props => [faultReport];
}

/// State when the fault report submission failed.
class ReportFaultFailure extends ReportFaultState {
  final String message;

  const ReportFaultFailure(this.message);

  @override
  List<Object?> get props => [message];
}
