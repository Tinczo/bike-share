import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/features/rental/domain/entities/rental.dart';
import 'package:bike_app/features/rental/domain/entities/rental_status.dart';
import 'package:bike_app/features/rental/domain/repositories/rental_repository.dart';
import 'package:bike_app/features/rental/domain/usecases/pause_rental.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRentalRepository extends Mock implements RentalRepository {}

void main() {
  late PauseRental usecase;
  late MockRentalRepository mockRentalRepository;

  setUp(() {
    mockRentalRepository = MockRentalRepository();
    usecase = PauseRental(mockRentalRepository);
  });

  const tRentalId = 'rental-123';
  final tStartTime = DateTime(2024, 1, 15, 10, 0);

  final tPausedRental = Rental(
    id: tRentalId,
    bikeId: 'bike-123',
    userId: 'user-123',
    startTime: tStartTime,
    cost: 5.0,
    status: RentalStatus.paused,
  );

  test('should pause rental via repository', () async {
    // arrange
    when(
      () => mockRentalRepository.pauseRental(rentalId: tRentalId),
    ).thenAnswer((_) async => Right(tPausedRental));

    // act
    final result = await usecase(const PauseRentalParams(rentalId: tRentalId));

    // assert
    expect(result, Right(tPausedRental));
    verify(
      () => mockRentalRepository.pauseRental(rentalId: tRentalId),
    ).called(1);
    verifyNoMoreInteractions(mockRentalRepository);
  });

  test('should return failure when pausing rental fails', () async {
    // arrange
    when(
      () => mockRentalRepository.pauseRental(rentalId: tRentalId),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(const PauseRentalParams(rentalId: tRentalId));

    // assert
    expect(result, Left(ServerFailure()));
    verify(
      () => mockRentalRepository.pauseRental(rentalId: tRentalId),
    ).called(1);
  });

  test('should return NetworkFailure when no network connection', () async {
    // arrange
    when(
      () => mockRentalRepository.pauseRental(rentalId: tRentalId),
    ).thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase(const PauseRentalParams(rentalId: tRentalId));

    // assert
    expect(result, Left(NetworkFailure()));
  });

  group('PauseRentalParams', () {
    test('should support value equality', () {
      const params1 = PauseRentalParams(rentalId: tRentalId);
      const params2 = PauseRentalParams(rentalId: tRentalId);

      expect(params1, equals(params2));
    });

    test('props should contain rentalId', () {
      const params = PauseRentalParams(rentalId: tRentalId);

      expect(params.props, [tRentalId]);
    });
  });
}
