import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/rental/domain/entities/rental.dart';
import 'package:bike_app/features/rental/domain/entities/rental_status.dart';
import 'package:bike_app/features/rental/domain/repositories/rental_repository.dart';
import 'package:bike_app/features/rental/domain/usecases/get_active_rental.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRentalRepository extends Mock implements RentalRepository {}

void main() {
  late GetActiveRental usecase;
  late MockRentalRepository mockRentalRepository;

  setUp(() {
    mockRentalRepository = MockRentalRepository();
    usecase = GetActiveRental(mockRentalRepository);
  });

  final tStartTime = DateTime(2024, 1, 15, 10, 0);

  final tRental = Rental(
    id: 'rental-123',
    bikeId: 'bike-123',
    userId: 'user-123',
    startTime: tStartTime,
    cost: 5.0,
    status: RentalStatus.active,
  );

  test('should get active rental from the repository', () async {
    // arrange
    when(
      () => mockRentalRepository.getActiveRental(),
    ).thenAnswer((_) async => Right(tRental));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Right(tRental));
    verify(() => mockRentalRepository.getActiveRental()).called(1);
    verifyNoMoreInteractions(mockRentalRepository);
  });

  test('should return null when no active rental exists', () async {
    // arrange
    when(
      () => mockRentalRepository.getActiveRental(),
    ).thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right<Failure, Rental?>(null));
    verify(() => mockRentalRepository.getActiveRental()).called(1);
    verifyNoMoreInteractions(mockRentalRepository);
  });

  test('should return failure when getting active rental fails', () async {
    // arrange
    when(
      () => mockRentalRepository.getActiveRental(),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(ServerFailure()));
    verify(() => mockRentalRepository.getActiveRental()).called(1);
    verifyNoMoreInteractions(mockRentalRepository);
  });

  test('should return NetworkFailure when no network connection', () async {
    // arrange
    when(
      () => mockRentalRepository.getActiveRental(),
    ).thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(NetworkFailure()));
    verify(() => mockRentalRepository.getActiveRental()).called(1);
  });
}
