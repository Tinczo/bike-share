import 'package:bike_app/core/error/exceptions.dart';
import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/network/network_info.dart';
import 'package:bike_app/features/rental/data/datasources/rental_remote_datasource.dart';
import 'package:bike_app/features/rental/data/models/rental_eligibility_model.dart';
import 'package:bike_app/features/rental/data/models/rental_model.dart';
import 'package:bike_app/features/rental/data/models/reservation_model.dart';
import 'package:bike_app/features/rental/data/repositories/rental_repository_impl.dart';
import 'package:bike_app/features/rental/domain/entities/rental_launch_method.dart';
import 'package:bike_app/features/rental/domain/entities/rental_status.dart';
import 'package:bike_app/features/rental/domain/entities/reservation_status.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRentalRemoteDataSource extends Mock
    implements RentalRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late RentalRepositoryImpl repository;
  late MockRentalRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRentalRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = RentalRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('checkEligibility', () {
    const tEligibilityModel = RentalEligibilityModel(
      isEligible: true,
      hasMinimumBalance: true,
      hasLinkedCard: true,
      hasActiveSubscription: false,
      isDebtor: false,
    );

    runTestsOnline(() {
      test(
        'should return eligibility when remote call is successful',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.checkEligibility(),
          ).thenAnswer((_) async => tEligibilityModel);

          // act
          final result = await repository.checkEligibility();

          // assert
          verify(() => mockRemoteDataSource.checkEligibility()).called(1);
          expect(result, const Right(tEligibilityModel));
        },
      );

      test('should return ServerFailure when remote call fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.checkEligibility(),
        ).thenThrow(ServerException());

        // act
        final result = await repository.checkEligibility();

        // assert
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.checkEligibility();

        // assert
        verifyNever(() => mockRemoteDataSource.checkEligibility());
        expect(result, Left(NetworkFailure()));
      });
    });
  });

  group('startRental', () {
    const tBikeId = 'bike-123';
    const tMethod = RentalLaunchMethod.qr;
    final tStartTime = DateTime(2024, 1, 15, 10, 0);

    final tRentalModel = RentalModel(
      id: 'rental-123',
      bikeId: tBikeId,
      userId: 'user-123',
      startTime: tStartTime,
      cost: 0.0,
      status: RentalStatus.active,
    );

    runTestsOnline(() {
      test('should return rental when remote call is successful', () async {
        // arrange
        when(
          () => mockRemoteDataSource.startRental(
            bikeId: tBikeId,
            method: tMethod,
          ),
        ).thenAnswer((_) async => tRentalModel);

        // act
        final result = await repository.startRental(
          bikeId: tBikeId,
          method: tMethod,
        );

        // assert
        verify(
          () => mockRemoteDataSource.startRental(
            bikeId: tBikeId,
            method: tMethod,
          ),
        ).called(1);
        expect(result, Right(tRentalModel));
      });

      test(
        'should return InsufficientFundsFailure when payment required',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.startRental(
              bikeId: tBikeId,
              method: tMethod,
            ),
          ).thenThrow(PaymentRequiredException());

          // act
          final result = await repository.startRental(
            bikeId: tBikeId,
            method: tMethod,
          );

          // assert
          expect(result, Left(InsufficientFundsFailure()));
        },
      );

      test(
        'should return BikeUnavailableFailure when bike not available',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.startRental(
              bikeId: tBikeId,
              method: tMethod,
            ),
          ).thenThrow(BikeUnavailableException());

          // act
          final result = await repository.startRental(
            bikeId: tBikeId,
            method: tMethod,
          );

          // assert
          expect(result, Left(BikeUnavailableFailure()));
        },
      );

      test('should return IoTFailure when IoT device fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.startRental(
            bikeId: tBikeId,
            method: tMethod,
          ),
        ).thenThrow(IoTTimeoutException());

        // act
        final result = await repository.startRental(
          bikeId: tBikeId,
          method: tMethod,
        );

        // assert
        expect(result, Left(IoTFailure()));
      });

      test('should return ServerFailure when remote call fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.startRental(
            bikeId: tBikeId,
            method: tMethod,
          ),
        ).thenThrow(ServerException());

        // act
        final result = await repository.startRental(
          bikeId: tBikeId,
          method: tMethod,
        );

        // assert
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.startRental(
          bikeId: tBikeId,
          method: tMethod,
        );

        // assert
        expect(result, Left(NetworkFailure()));
      });
    });
  });

  group('pauseRental', () {
    const tRentalId = 'rental-123';
    final tStartTime = DateTime(2024, 1, 15, 10, 0);

    final tPausedRentalModel = RentalModel(
      id: tRentalId,
      bikeId: 'bike-123',
      userId: 'user-123',
      startTime: tStartTime,
      cost: 5.0,
      status: RentalStatus.paused,
    );

    runTestsOnline(() {
      test(
        'should return paused rental when remote call is successful',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.pauseRental(rentalId: tRentalId),
          ).thenAnswer((_) async => tPausedRentalModel);

          // act
          final result = await repository.pauseRental(rentalId: tRentalId);

          // assert
          verify(
            () => mockRemoteDataSource.pauseRental(rentalId: tRentalId),
          ).called(1);
          expect(result, Right(tPausedRentalModel));
        },
      );

      test('should return ServerFailure when remote call fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.pauseRental(rentalId: tRentalId),
        ).thenThrow(ServerException());

        // act
        final result = await repository.pauseRental(rentalId: tRentalId);

        // assert
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.pauseRental(rentalId: tRentalId);

        // assert
        expect(result, Left(NetworkFailure()));
      });
    });
  });

  group('endRental', () {
    const tRentalId = 'rental-123';
    final tStartTime = DateTime(2024, 1, 15, 10, 0);
    final tEndTime = DateTime(2024, 1, 15, 11, 30);

    final tFinishedRentalModel = RentalModel(
      id: tRentalId,
      bikeId: 'bike-123',
      userId: 'user-123',
      startTime: tStartTime,
      endTime: tEndTime,
      cost: 15.0,
      status: RentalStatus.finished,
    );

    runTestsOnline(() {
      test(
        'should return finished rental when remote call is successful',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.endRental(rentalId: tRentalId),
          ).thenAnswer((_) async => tFinishedRentalModel);

          // act
          final result = await repository.endRental(rentalId: tRentalId);

          // assert
          verify(
            () => mockRemoteDataSource.endRental(rentalId: tRentalId),
          ).called(1);
          expect(result, Right(tFinishedRentalModel));
        },
      );

      test('should return ServerFailure when remote call fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.endRental(rentalId: tRentalId),
        ).thenThrow(ServerException());

        // act
        final result = await repository.endRental(rentalId: tRentalId);

        // assert
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.endRental(rentalId: tRentalId);

        // assert
        expect(result, Left(NetworkFailure()));
      });
    });
  });

  group('getActiveRental', () {
    final tStartTime = DateTime(2024, 1, 15, 10, 0);

    final tRentalModel = RentalModel(
      id: 'rental-123',
      bikeId: 'bike-123',
      userId: 'user-123',
      startTime: tStartTime,
      cost: 5.0,
      status: RentalStatus.active,
    );

    runTestsOnline(() {
      test('should return rental when remote call is successful', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getActiveRental(),
        ).thenAnswer((_) async => tRentalModel);

        // act
        final result = await repository.getActiveRental();

        // assert
        verify(() => mockRemoteDataSource.getActiveRental()).called(1);
        expect(result, Right(tRentalModel));
      });

      test('should return null when no active rental exists', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getActiveRental(),
        ).thenAnswer((_) async => null);

        // act
        final result = await repository.getActiveRental();

        // assert
        expect(result, const Right(null));
      });

      test('should return ServerFailure when remote call fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getActiveRental(),
        ).thenThrow(ServerException());

        // act
        final result = await repository.getActiveRental();

        // assert
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.getActiveRental();

        // assert
        expect(result, Left(NetworkFailure()));
      });
    });
  });

  group('createReservation', () {
    const tBikeId = 'bike-123';
    final tCreatedAt = DateTime(2024, 1, 15, 10, 0);
    final tExpiresAt = DateTime(2024, 1, 15, 10, 15);

    final tReservationModel = ReservationModel(
      id: 'reservation-123',
      bikeId: tBikeId,
      userId: 'user-123',
      createdAt: tCreatedAt,
      expiresAt: tExpiresAt,
      status: ReservationStatus.active,
    );

    runTestsOnline(() {
      test(
        'should return reservation when remote call is successful',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.createReservation(bikeId: tBikeId),
          ).thenAnswer((_) async => tReservationModel);

          // act
          final result = await repository.createReservation(bikeId: tBikeId);

          // assert
          verify(
            () => mockRemoteDataSource.createReservation(bikeId: tBikeId),
          ).called(1);
          expect(result, Right(tReservationModel));
        },
      );

      test(
        'should return InsufficientFundsFailure when payment required',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.createReservation(bikeId: tBikeId),
          ).thenThrow(PaymentRequiredException());

          // act
          final result = await repository.createReservation(bikeId: tBikeId);

          // assert
          expect(result, Left(InsufficientFundsFailure()));
        },
      );

      test(
        'should return BikeUnavailableFailure when bike not available',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.createReservation(bikeId: tBikeId),
          ).thenThrow(BikeUnavailableException());

          // act
          final result = await repository.createReservation(bikeId: tBikeId);

          // assert
          expect(result, Left(BikeUnavailableFailure()));
        },
      );

      test('should return ServerFailure when remote call fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.createReservation(bikeId: tBikeId),
        ).thenThrow(ServerException());

        // act
        final result = await repository.createReservation(bikeId: tBikeId);

        // assert
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.createReservation(bikeId: tBikeId);

        // assert
        expect(result, Left(NetworkFailure()));
      });
    });
  });

  group('cancelReservation', () {
    const tReservationId = 'reservation-123';

    runTestsOnline(() {
      test('should return Unit when remote call is successful', () async {
        // arrange
        when(
          () => mockRemoteDataSource.cancelReservation(
            reservationId: tReservationId,
          ),
        ).thenAnswer((_) async => {});

        // act
        final result = await repository.cancelReservation(
          reservationId: tReservationId,
        );

        // assert
        verify(
          () => mockRemoteDataSource.cancelReservation(
            reservationId: tReservationId,
          ),
        ).called(1);
        expect(result, const Right(unit));
      });

      test(
        'should return ReservationExpiredFailure when reservation expired',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.cancelReservation(
              reservationId: tReservationId,
            ),
          ).thenThrow(ReservationExpiredException());

          // act
          final result = await repository.cancelReservation(
            reservationId: tReservationId,
          );

          // assert
          expect(result, Left(ReservationExpiredFailure()));
        },
      );

      test('should return ServerFailure when remote call fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.cancelReservation(
            reservationId: tReservationId,
          ),
        ).thenThrow(ServerException());

        // act
        final result = await repository.cancelReservation(
          reservationId: tReservationId,
        );

        // assert
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.cancelReservation(
          reservationId: tReservationId,
        );

        // assert
        expect(result, Left(NetworkFailure()));
      });
    });
  });

  group('getActiveReservation', () {
    final tCreatedAt = DateTime(2024, 1, 15, 10, 0);
    final tExpiresAt = DateTime(2024, 1, 15, 10, 15);

    final tReservationModel = ReservationModel(
      id: 'reservation-123',
      bikeId: 'bike-123',
      userId: 'user-123',
      createdAt: tCreatedAt,
      expiresAt: tExpiresAt,
      status: ReservationStatus.active,
    );

    runTestsOnline(() {
      test(
        'should return reservation when remote call is successful',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.getActiveReservation(),
          ).thenAnswer((_) async => tReservationModel);

          // act
          final result = await repository.getActiveReservation();

          // assert
          verify(() => mockRemoteDataSource.getActiveReservation()).called(1);
          expect(result, Right(tReservationModel));
        },
      );

      test('should return null when no active reservation exists', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getActiveReservation(),
        ).thenAnswer((_) async => null);

        // act
        final result = await repository.getActiveReservation();

        // assert
        expect(result, const Right(null));
      });

      test('should return ServerFailure when remote call fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getActiveReservation(),
        ).thenThrow(ServerException());

        // act
        final result = await repository.getActiveReservation();

        // assert
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.getActiveReservation();

        // assert
        expect(result, Left(NetworkFailure()));
      });
    });
  });
}
