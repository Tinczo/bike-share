import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/features/rental/domain/entities/rental.dart';
import 'package:bike_app/features/rental/domain/entities/rental_status.dart';
import 'package:bike_app/features/rental/domain/repositories/rental_repository.dart';
import 'package:bike_app/features/rental/domain/usecases/resume_rental.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRentalRepository extends Mock implements RentalRepository {}

void main() {
  late ResumeRental usecase;
  late MockRentalRepository mockRentalRepository;

  setUp(() {
    mockRentalRepository = MockRentalRepository();
    usecase = ResumeRental(mockRentalRepository);
  });

  const tRentalId = 'rental-123';
  final tStartTime = DateTime(2024, 1, 15, 10, 0);

  final tResumedRental = Rental(
    id: tRentalId,
    bikeId: 'bike-123',
    userId: 'user-123',
    startTime: tStartTime,
    cost: 5.0,
    status: RentalStatus.active,
  );

  test('should resume rental via repository', () async {
    // arrange
    when(
      () => mockRentalRepository.resumeRental(rentalId: tRentalId),
    ).thenAnswer((_) async => Right(tResumedRental));

    // act
    final result = await usecase(const ResumeRentalParams(rentalId: tRentalId));

    // assert
    expect(result, Right(tResumedRental));
    verify(
      () => mockRentalRepository.resumeRental(rentalId: tRentalId),
    ).called(1);
    verifyNoMoreInteractions(mockRentalRepository);
  });

  test('should return failure when resuming rental fails', () async {
    // arrange
    when(
      () => mockRentalRepository.resumeRental(rentalId: tRentalId),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(const ResumeRentalParams(rentalId: tRentalId));

    // assert
    expect(result, Left(ServerFailure()));
    verify(
      () => mockRentalRepository.resumeRental(rentalId: tRentalId),
    ).called(1);
  });

  test('should return NetworkFailure when no network connection', () async {
    // arrange
    when(
      () => mockRentalRepository.resumeRental(rentalId: tRentalId),
    ).thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase(const ResumeRentalParams(rentalId: tRentalId));

    // assert
    expect(result, Left(NetworkFailure()));
  });

  group('ResumeRentalParams', () {
    test('should support value equality', () {
      const params1 = ResumeRentalParams(rentalId: tRentalId);
      const params2 = ResumeRentalParams(rentalId: tRentalId);

      expect(params1, equals(params2));
    });

    test('props should contain rentalId', () {
      const params = ResumeRentalParams(rentalId: tRentalId);

      expect(params.props, [tRentalId]);
    });
  });
}
