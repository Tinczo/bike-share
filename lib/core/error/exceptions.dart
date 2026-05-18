class ServerException implements Exception {}

class CacheException implements Exception {}

class InvalidCredentialsException implements Exception {}

class EmailAlreadyInUseException implements Exception {}

// Rental-specific exceptions

/// Thrown when payment is required to proceed (HTTP 402).
class PaymentRequiredException implements Exception {}

/// Thrown when a bike is not available for rental (HTTP 409).
class BikeUnavailableException implements Exception {}

/// Thrown when IoT device communication times out (HTTP 504).
class IoTTimeoutException implements Exception {}

/// Thrown when a reservation has expired.
class ReservationExpiredException implements Exception {}
