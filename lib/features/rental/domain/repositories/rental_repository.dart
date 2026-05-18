import 'package:dartz/dartz.dart';

import '../../../../core/type_defs.dart';
import '../entities/rental.dart';
import '../entities/rental_eligibility.dart';
import '../entities/rental_launch_method.dart';
import '../entities/reservation.dart';

/// Contract for rental operations.
///
/// This interface defines all rental-related operations that must be
/// implemented by the data layer.
abstract class RentalRepository {
  /// Checks if the current user is eligible to rent a bike.
  ///
  /// Returns [RentalEligibility] on success or [Failure] on error.
  FutureEither<RentalEligibility> checkEligibility();

  /// Starts a new rental for the specified bike.
  ///
  /// [bikeId] - The ID of the bike to rent.
  /// [method] - The method used to start the rental (QR or manual).
  ///
  /// Returns [Rental] on success or [Failure] on error.
  /// May return [InsufficientFundsFailure], [BikeUnavailableFailure],
  /// or [IoTFailure].
  FutureEither<Rental> startRental({
    required String bikeId,
    required RentalLaunchMethod method,
  });

  /// Pauses the current rental.
  ///
  /// [rentalId] - The ID of the rental to pause.
  ///
  /// Returns updated [Rental] on success or [Failure] on error.
  FutureEither<Rental> pauseRental({required String rentalId});

  /// Resumes a paused rental.
  ///
  /// [rentalId] - The ID of the rental to resume.
  ///
  /// Returns updated [Rental] on success or [Failure] on error.
  FutureEither<Rental> resumeRental({required String rentalId});

  /// Ends the current rental.
  ///
  /// [rentalId] - The ID of the rental to end.
  ///
  /// Returns completed [Rental] on success or [Failure] on error.
  FutureEither<Rental> endRental({required String rentalId});

  /// Gets the current user's active rental, if any.
  ///
  /// Returns [Rental] if there's an active rental, null if not,
  /// or [Failure] on error.
  FutureEither<Rental?> getActiveRental();

  /// Creates a reservation for the specified bike.
  ///
  /// Reservations last for 15 minutes.
  ///
  /// [bikeId] - The ID of the bike to reserve.
  ///
  /// Returns [Reservation] on success or [Failure] on error.
  /// May return [InsufficientFundsFailure] or [BikeUnavailableFailure].
  FutureEither<Reservation> createReservation({required String bikeId});

  /// Cancels an active reservation.
  ///
  /// [reservationId] - The ID of the reservation to cancel.
  ///
  /// Returns [Unit] on success or [Failure] on error.
  FutureEither<Unit> cancelReservation({required String reservationId});

  /// Gets the current user's active reservation, if any.
  ///
  /// Returns [Reservation] if there's an active reservation, null if not,
  /// or [Failure] on error.
  FutureEither<Reservation?> getActiveReservation();
}
