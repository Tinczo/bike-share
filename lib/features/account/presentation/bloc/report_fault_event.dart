part of 'report_fault_bloc.dart';

sealed class ReportFaultEvent extends Equatable {
  const ReportFaultEvent();

  @override
  List<Object?> get props => [];
}

/// Event to select a fault type.
class FaultTypeSelected extends ReportFaultEvent {
  final FaultType type;

  const FaultTypeSelected(this.type);

  @override
  List<Object?> get props => [type];
}

/// Event to update the description.
class DescriptionChanged extends ReportFaultEvent {
  final String description;

  const DescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

/// Event to submit the fault report.
class FaultReportSubmitted extends ReportFaultEvent {
  final String bikeId;

  const FaultReportSubmitted({required this.bikeId});

  @override
  List<Object?> get props => [bikeId];
}
