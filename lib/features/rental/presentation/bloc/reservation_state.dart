part of 'reservation_bloc.dart';

sealed class ReservationState extends Equatable {
  const ReservationState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any reservation action.
final class ReservationInitial extends ReservationState {
  const ReservationInitial();
}

/// Loading state while processing.
final class ReservationLoading extends ReservationState {
  const ReservationLoading();
}

/// Reservation is active with countdown.
final class ReservationActiveState extends ReservationState {
  final Reservation reservation;
  final Duration remainingTime;

  const ReservationActiveState({
    required this.reservation,
    required this.remainingTime,
  });

  @override
  List<Object?> get props => [reservation, remainingTime];
}

/// Reservation has expired.
final class ReservationExpiredState extends ReservationState {
  const ReservationExpiredState();
}

/// Reservation was cancelled.
final class ReservationCancelledState extends ReservationState {
  const ReservationCancelledState();
}

/// Error state with a message.
final class ReservationFailure extends ReservationState {
  final String message;

  const ReservationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
