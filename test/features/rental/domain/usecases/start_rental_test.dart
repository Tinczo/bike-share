import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/features/rental/domain/entities/rental.dart';
import 'package:bike_app/features/rental/domain/entities/rental_launch_method.dart';
import 'package:bike_app/features/rental/domain/entities/rental_status.dart';
import 'package:bike_app/features/rental/domain/repositories/rental_repository.dart';
import 'package:bike_app/features/rental/domain/usecases/start_rental.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRentalRepository extends Mock implements RentalRepository {}

void main() {
  late StartRental usecase;
  late MockRentalRepository mockRentalRepository;

  setUp(() {
    mockRentalRepository = MockRentalRepository();
    usecase = StartRental(mockRentalRepository);
  });

  const tBikeId = 'bike-123';
  const tMethod = RentalLaunchMethod.qr;
  final tStartTime = DateTime(2024, 1, 15, 10, 0);

  final tRental = Rental(
    id: 'rental-123',
    bikeId: tBikeId,
    userId: 'user-123',
    startTime: tStartTime,
    cost: 0.0,
    status: RentalStatus.active,
  );

  test('should start rental via repository', () async {
    // arrange
    when(
      () => mockRentalRepository.startRental(bikeId: tBikeId, method: tMethod),
    ).thenAnswer((_) async => Right(tRental));

    // act
    final result = await usecase(
      const StartRentalParams(bikeId: tBikeId, method: tMethod),
    );

    // assert
    expect(result, Right(tRental));
    verify(
      () => mockRentalRepository.startRental(bikeId: tBikeId, method: tMethod),
    ).called(1);
    verifyNoMoreInteractions(mockRentalRepository);
  });

  test(
    'should return InsufficientFundsFailure when balance is too low',
    () async {
      // arrange
      when(
        () =>
            mockRentalRepository.startRental(bikeId: tBikeId, method: tMethod),
      ).thenAnswer((_) async => Left(InsufficientFundsFailure()));

      // act
      final result = await usecase(
        const StartRentalParams(bikeId: tBikeId, method: tMethod),
      );

      // assert
      expect(result, Left(InsufficientFundsFailure()));
      verify(
        () =>
            mockRentalRepository.startRental(bikeId: tBikeId, method: tMethod),
      ).called(1);
    },
  );

  test(
    'should return BikeUnavailableFailure when bike is not available',
    () async {
      // arrange
      when(
        () =>
            mockRentalRepository.startRental(bikeId: tBikeId, method: tMethod),
      ).thenAnswer((_) async => Left(BikeUnavailableFailure()));

      // act
      final result = await usecase(
        const StartRentalParams(bikeId: tBikeId, method: tMethod),
      );

      // assert
      expect(result, Left(BikeUnavailableFailure()));
    },
  );

  test('should return IoTFailure when IoT device fails', () async {
    // arrange
    when(
      () => mockRentalRepository.startRental(bikeId: tBikeId, method: tMethod),
    ).thenAnswer((_) async => Left(IoTFailure()));

    // act
    final result = await usecase(
      const StartRentalParams(bikeId: tBikeId, method: tMethod),
    );

    // assert
    expect(result, Left(IoTFailure()));
  });

  group('StartRentalParams', () {
    test('should support value equality', () {
      const params1 = StartRentalParams(bikeId: tBikeId, method: tMethod);
      const params2 = StartRentalParams(bikeId: tBikeId, method: tMethod);

      expect(params1, equals(params2));
    });

    test('props should contain bikeId and method', () {
      const params = StartRentalParams(bikeId: tBikeId, method: tMethod);

      expect(params.props, [tBikeId, tMethod]);
    });
  });
}
