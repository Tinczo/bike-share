import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/type_defs.dart';
import '../../domain/entities/rental.dart';
import '../../domain/entities/rental_eligibility.dart';
import '../../domain/entities/rental_launch_method.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/rental_repository.dart';
import '../datasources/rental_remote_datasource.dart';

@LazySingleton(as: RentalRepository)
class RentalRepositoryImpl implements RentalRepository {
  final RentalRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  RentalRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  FutureEither<RentalEligibility> checkEligibility() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final eligibility = await remoteDataSource.checkEligibility();
      return Right(eligibility);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  FutureEither<Rental> startRental({
    required String bikeId,
    required RentalLaunchMethod method,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final rental = await remoteDataSource.startRental(
        bikeId: bikeId,
        method: method,
      );
      return Right(rental);
    } on PaymentRequiredException {
      return Left(InsufficientFundsFailure());
    } on BikeUnavailableException {
      return Left(BikeUnavailableFailure());
    } on IoTTimeoutException {
      return Left(IoTFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  FutureEither<Rental> pauseRental({required String rentalId}) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final rental = await remoteDataSource.pauseRental(rentalId: rentalId);
      return Right(rental);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  FutureEither<Rental> resumeRental({required String rentalId}) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final rental = await remoteDataSource.resumeRental(rentalId: rentalId);
      return Right(rental);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  FutureEither<Rental> endRental({required String rentalId}) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final rental = await remoteDataSource.endRental(rentalId: rentalId);
      return Right(rental);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  FutureEither<Rental?> getActiveRental() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final rental = await remoteDataSource.getActiveRental();
      return Right(rental);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  FutureEither<Reservation> createReservation({required String bikeId}) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final reservation = await remoteDataSource.createReservation(
        bikeId: bikeId,
      );
      return Right(reservation);
    } on PaymentRequiredException {
      return Left(InsufficientFundsFailure());
    } on BikeUnavailableException {
      return Left(BikeUnavailableFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  FutureEither<Unit> cancelReservation({required String reservationId}) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await remoteDataSource.cancelReservation(reservationId: reservationId);
      return const Right(unit);
    } on ReservationExpiredException {
      return Left(ReservationExpiredFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  FutureEither<Reservation?> getActiveReservation() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final reservation = await remoteDataSource.getActiveReservation();
      return Right(reservation);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
