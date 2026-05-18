/// Status of a bike rental.
enum RentalStatus {
  /// Rental is currently active (bike is in use).
  active,

  /// Rental is paused (bike is locked but rental continues).
  paused,

  /// Rental has been completed.
  finished,
}
