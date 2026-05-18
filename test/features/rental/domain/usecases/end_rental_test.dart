import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/features/rental/domain/entities/rental.dart';
import 'package:bike_app/features/rental/domain/entities/rental_status.dart';
import 'package:bike_app/features/rental/domain/repositories/rental_repository.dart';
import 'package:bike_app/features/rental/domain/usecases/end_rental.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRentalRepository extends Mock implements RentalRepository {}

void main() {
  late EndRental usecase;
  late MockRentalRepository mockRentalRepository;

  setUp(() {
    mockRentalRepository = MockRentalRepository();
    usecase = EndRental(mockRentalRepository);
  });

  const tRentalId = 'rental-123';
  final tStartTime = DateTime(2024, 1, 15, 10, 0);
  final tEndTime = DateTime(2024, 1, 15, 11, 30);

  final tFinishedRental = Rental(
    id: tRentalId,
    bikeId: 'bike-123',
    userId: 'user-123',
    startTime: tStartTime,
    endTime: tEndTime,
    cost: 15.0,
    status: RentalStatus.finished,
  );

  test('should end rental via repository', () async {
    // arrange
    when(
      () => mockRentalRepository.endRental(rentalId: tRentalId),
    ).thenAnswer((_) async => Right(tFinishedRental));

    // act
    final result = await usecase(const EndRentalParams(rentalId: tRentalId));

    // assert
    expect(result, Right(tFinishedRental));
    verify(() => mockRentalRepository.endRental(rentalId: tRentalId)).called(1);
    verifyNoMoreInteractions(mockRentalRepository);
  });

  test('should return failure when ending rental fails', () async {
    // arrange
    when(
      () => mockRentalRepository.endRental(rentalId: tRentalId),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(const EndRentalParams(rentalId: tRentalId));

    // assert
    expect(result, Left(ServerFailure()));
    verify(() => mockRentalRepository.endRental(rentalId: tRentalId)).called(1);
  });

  test('should return NetworkFailure when no network connection', () async {
    // arrange
    when(
      () => mockRentalRepository.endRental(rentalId: tRentalId),
    ).thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase(const EndRentalParams(rentalId: tRentalId));

    // assert
    expect(result, Left(NetworkFailure()));
  });

  group('EndRentalParams', () {
    test('should support value equality', () {
      const params1 = EndRentalParams(rentalId: tRentalId);
      const params2 = EndRentalParams(rentalId: tRentalId);

      expect(params1, equals(params2));
    });

    test('props should contain rentalId', () {
      const params = EndRentalParams(rentalId: tRentalId);

      expect(params.props, [tRentalId]);
    });
  });
}
