part of 'fault_history_bloc.dart';

sealed class FaultHistoryEvent extends Equatable {
  const FaultHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the fault report history.
class FaultHistoryLoadRequested extends FaultHistoryEvent {
  const FaultHistoryLoadRequested();
}
