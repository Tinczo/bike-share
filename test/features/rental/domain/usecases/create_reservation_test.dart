import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/features/rental/domain/entities/reservation.dart';
import 'package:bike_app/features/rental/domain/entities/reservation_status.dart';
import 'package:bike_app/features/rental/domain/repositories/rental_repository.dart';
import 'package:bike_app/features/rental/domain/usecases/create_reservation.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRentalRepository extends Mock implements RentalRepository {}

void main() {
  late CreateReservation usecase;
  late MockRentalRepository mockRentalRepository;

  setUp(() {
    mockRentalRepository = MockRentalRepository();
    usecase = CreateReservation(mockRentalRepository);
  });

  const tBikeId = 'bike-123';
  final tCreatedAt = DateTime(2024, 1, 15, 10, 0);
  final tExpiresAt = DateTime(2024, 1, 15, 10, 15);

  final tReservation = Reservation(
    id: 'reservation-123',
    bikeId: tBikeId,
    userId: 'user-123',
    createdAt: tCreatedAt,
    expiresAt: tExpiresAt,
    status: ReservationStatus.active,
  );

  test('should create reservation via repository', () async {
    // arrange
    when(
      () => mockRentalRepository.createReservation(bikeId: tBikeId),
    ).thenAnswer((_) async => Right(tReservation));

    // act
    final result = await usecase(
      const CreateReservationParams(bikeId: tBikeId),
    );

    // assert
    expect(result, Right(tReservation));
    verify(
      () => mockRentalRepository.createReservation(bikeId: tBikeId),
    ).called(1);
    verifyNoMoreInteractions(mockRentalRepository);
  });

  test(
    'should return InsufficientFundsFailure when balance is too low',
    () async {
      // arrange
      when(
        () => mockRentalRepository.createReservation(bikeId: tBikeId),
      ).thenAnswer((_) async => Left(InsufficientFundsFailure()));

      // act
      final result = await usecase(
        const CreateReservationParams(bikeId: tBikeId),
      );

      // assert
      expect(result, Left(InsufficientFundsFailure()));
      verify(
        () => mockRentalRepository.createReservation(bikeId: tBikeId),
      ).called(1);
    },
  );

  test(
    'should return BikeUnavailableFailure when bike is not available',
    () async {
      // arrange
      when(
        () => mockRentalRepository.createReservation(bikeId: tBikeId),
      ).thenAnswer((_) async => Left(BikeUnavailableFailure()));

      // act
      final result = await usecase(
        const CreateReservationParams(bikeId: tBikeId),
      );

      // assert
      expect(result, Left(BikeUnavailableFailure()));
    },
  );

  test('should return NetworkFailure when no network connection', () async {
    // arrange
    when(
      () => mockRentalRepository.createReservation(bikeId: tBikeId),
    ).thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase(
      const CreateReservationParams(bikeId: tBikeId),
    );

    // assert
    expect(result, Left(NetworkFailure()));
  });

  group('CreateReservationParams', () {
    test('should support value equality', () {
      const params1 = CreateReservationParams(bikeId: tBikeId);
      const params2 = CreateReservationParams(bikeId: tBikeId);

      expect(params1, equals(params2));
    });

    test('props should contain bikeId', () {
      const params = CreateReservationParams(bikeId: tBikeId);

      expect(params.props, [tBikeId]);
    });
  });
}
