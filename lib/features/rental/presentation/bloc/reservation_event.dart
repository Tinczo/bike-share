part of 'reservation_bloc.dart';

sealed class ReservationEvent extends Equatable {
  const ReservationEvent();

  @override
  List<Object?> get props => [];
}

/// Request to create a reservation for a bike.
final class ReservationCreated extends ReservationEvent {
  final String bikeId;

  const ReservationCreated({required this.bikeId});

  @override
  List<Object?> get props => [bikeId];
}

/// Request to cancel an active reservation.
final class ReservationCancelled extends ReservationEvent {
  final String reservationId;

  const ReservationCancelled({required this.reservationId});

  @override
  List<Object?> get props => [reservationId];
}

/// Timer tick event for countdown.
final class ReservationTimerTicked extends ReservationEvent {
  const ReservationTimerTicked();
}

/// Request to load the current active reservation.
final class ActiveReservationLoaded extends ReservationEvent {
  const ActiveReservationLoaded();
}

/// Clear the reservation state (e.g., when rental starts from reservation).
final class ReservationCleared extends ReservationEvent {
  const ReservationCleared();
}
