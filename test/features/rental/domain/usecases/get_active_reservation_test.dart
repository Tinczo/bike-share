import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/rental/domain/entities/reservation.dart';
import 'package:bike_app/features/rental/domain/entities/reservation_status.dart';
import 'package:bike_app/features/rental/domain/repositories/rental_repository.dart';
import 'package:bike_app/features/rental/domain/usecases/get_active_reservation.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRentalRepository extends Mock implements RentalRepository {}

void main() {
  late GetActiveReservation usecase;
  late MockRentalRepository mockRentalRepository;

  setUp(() {
    mockRentalRepository = MockRentalRepository();
    usecase = GetActiveReservation(mockRentalRepository);
  });

  final tCreatedAt = DateTime(2024, 1, 15, 10, 0);
  final tExpiresAt = DateTime(2024, 1, 15, 10, 15);

  final tReservation = Reservation(
    id: 'reservation-123',
    bikeId: 'bike-123',
    userId: 'user-123',
    createdAt: tCreatedAt,
    expiresAt: tExpiresAt,
    status: ReservationStatus.active,
  );

  test('should get active reservation from the repository', () async {
    // arrange
    when(
      () => mockRentalRepository.getActiveReservation(),
    ).thenAnswer((_) async => Right(tReservation));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Right(tReservation));
    verify(() => mockRentalRepository.getActiveReservation()).called(1);
    verifyNoMoreInteractions(mockRentalRepository);
  });

  test('should return null when no active reservation exists', () async {
    // arrange
    when(
      () => mockRentalRepository.getActiveReservation(),
    ).thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right<Failure, Reservation?>(null));
    verify(() => mockRentalRepository.getActiveReservation()).called(1);
    verifyNoMoreInteractions(mockRentalRepository);
  });

  test('should return failure when getting active reservation fails', () async {
    // arrange
    when(
      () => mockRentalRepository.getActiveReservation(),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(ServerFailure()));
    verify(() => mockRentalRepository.getActiveReservation()).called(1);
    verifyNoMoreInteractions(mockRentalRepository);
  });

  test('should return NetworkFailure when no network connection', () async {
    // arrange
    when(
      () => mockRentalRepository.getActiveReservation(),
    ).thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(NetworkFailure()));
    verify(() => mockRentalRepository.getActiveReservation()).called(1);
  });
}
