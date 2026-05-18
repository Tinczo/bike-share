/// Represents the current status of a bike in the system.
enum BikeStatus {
  /// Bike is available for rental.
  available,

  /// Bike is currently rented by a user.
  rented,

  /// Bike is reserved by a user.
  reserved,

  /// Bike is broken and not available for rental.
  broken,
}
