/// Status of a bike reservation.
enum ReservationStatus {
  /// Reservation is active and the bike is held for the user.
  active,

  /// Reservation has expired (15-minute window passed).
  expired,

  /// Reservation was cancelled by the user.
  cancelled,

  /// Reservation was converted to an active rental.
  converted,
}
