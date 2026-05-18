part of 'rental_history_bloc.dart';

sealed class RentalHistoryState extends Equatable {
  const RentalHistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading.
class RentalHistoryInitial extends RentalHistoryState {
  const RentalHistoryInitial();
}

/// State while loading rental history.
class RentalHistoryLoading extends RentalHistoryState {
  const RentalHistoryLoading();
}

/// State when rental history is loaded successfully.
class RentalHistoryLoaded extends RentalHistoryState {
  final List<RentalHistoryItem> rentalHistory;

  const RentalHistoryLoaded(this.rentalHistory);

  @override
  List<Object?> get props => [rentalHistory];
}

/// State when rental history is empty.
class RentalHistoryEmpty extends RentalHistoryState {
  const RentalHistoryEmpty();
}

/// State when loading failed.
class RentalHistoryError extends RentalHistoryState {
  final String message;

  const RentalHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
