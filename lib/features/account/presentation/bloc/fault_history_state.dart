part of 'fault_history_bloc.dart';

sealed class FaultHistoryState extends Equatable {
  const FaultHistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading.
class FaultHistoryInitial extends FaultHistoryState {
  const FaultHistoryInitial();
}

/// State while loading fault history.
class FaultHistoryLoading extends FaultHistoryState {
  const FaultHistoryLoading();
}

/// State when fault history is loaded successfully.
class FaultHistoryLoaded extends FaultHistoryState {
  final List<FaultReport> faultReports;

  const FaultHistoryLoaded(this.faultReports);

  @override
  List<Object?> get props => [faultReports];
}

/// State when fault history is empty.
class FaultHistoryEmpty extends FaultHistoryState {
  const FaultHistoryEmpty();
}

/// State when loading failed.
class FaultHistoryError extends FaultHistoryState {
  final String message;

  const FaultHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
