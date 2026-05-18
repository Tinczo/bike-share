import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class InvalidCredentialsFailure extends Failure {}

class EmailAlreadyInUseFailure extends Failure {}

class NetworkFailure extends Failure {}

// Rental-specific failures

/// User doesn't have sufficient funds to start a rental (HTTP 402).
class InsufficientFundsFailure extends Failure {}

/// Bike is not available for rental (HTTP 409).
class BikeUnavailableFailure extends Failure {}

/// IoT device communication failure (HTTP 504).
class IoTFailure extends Failure {}

/// User is not eligible to rent (e.g., debtor, no linked card).
class EligibilityFailure extends Failure {
  final String reason;

  const EligibilityFailure(this.reason);

  @override
  List<Object?> get props => [reason];
}

/// Reservation has expired and can no longer be used.
class ReservationExpiredFailure extends Failure {}

/// User already has an active rental (cannot start another).
class ActiveRentalExistsFailure extends Failure {}
