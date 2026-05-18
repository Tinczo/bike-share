part of 'rental_history_bloc.dart';

sealed class RentalHistoryEvent extends Equatable {
  const RentalHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the rental history.
class RentalHistoryLoadRequested extends RentalHistoryEvent {
  const RentalHistoryLoadRequested();
}
