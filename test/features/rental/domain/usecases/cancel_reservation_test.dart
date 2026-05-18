import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/features/rental/domain/repositories/rental_repository.dart';
import 'package:bike_app/features/rental/domain/usecases/cancel_reservation.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRentalRepository extends Mock implements RentalRepository {}

void main() {
  late CancelReservation usecase;
  late MockRentalRepository mockRentalRepository;

  setUp(() {
    mockRentalRepository = MockRentalRepository();
    usecase = CancelReservation(mockRentalRepository);
  });

  const tReservationId = 'reservation-123';

  test('should cancel reservation via repository', () async {
    // arrange
    when(
      () =>
          mockRentalRepository.cancelReservation(reservationId: tReservationId),
    ).thenAnswer((_) async => const Right(unit));

    // act
    final result = await usecase(
      const CancelReservationParams(reservationId: tReservationId),
    );

    // assert
    expect(result, const Right(unit));
    verify(
      () =>
          mockRentalRepository.cancelReservation(reservationId: tReservationId),
    ).called(1);
    verifyNoMoreInteractions(mockRentalRepository);
  });

  test('should return failure when cancelling reservation fails', () async {
    // arrange
    when(
      () =>
          mockRentalRepository.cancelReservation(reservationId: tReservationId),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(
      const CancelReservationParams(reservationId: tReservationId),
    );

    // assert
    expect(result, Left(ServerFailure()));
    verify(
      () =>
          mockRentalRepository.cancelReservation(reservationId: tReservationId),
    ).called(1);
  });

  test('should return NetworkFailure when no network connection', () async {
    // arrange
    when(
      () =>
          mockRentalRepository.cancelReservation(reservationId: tReservationId),
    ).thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase(
      const CancelReservationParams(reservationId: tReservationId),
    );

    // assert
    expect(result, Left(NetworkFailure()));
  });

  test(
    'should return ReservationExpiredFailure when reservation has expired',
    () async {
      // arrange
      when(
        () => mockRentalRepository.cancelReservation(
          reservationId: tReservationId,
        ),
      ).thenAnswer((_) async => Left(ReservationExpiredFailure()));

      // act
      final result = await usecase(
        const CancelReservationParams(reservationId: tReservationId),
      );

      // assert
      expect(result, Left(ReservationExpiredFailure()));
    },
  );

  group('CancelReservationParams', () {
    test('should support value equality', () {
      const params1 = CancelReservationParams(reservationId: tReservationId);
      const params2 = CancelReservationParams(reservationId: tReservationId);

      expect(params1, equals(params2));
    });

    test('props should contain reservationId', () {
      const params = CancelReservationParams(reservationId: tReservationId);

      expect(params.props, [tReservationId]);
    });
  });
}
