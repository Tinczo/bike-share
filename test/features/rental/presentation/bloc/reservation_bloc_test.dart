import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/rental/domain/entities/reservation.dart';
import 'package:bike_app/features/rental/domain/entities/reservation_status.dart';
import 'package:bike_app/features/rental/domain/usecases/cancel_reservation.dart';
import 'package:bike_app/features/rental/domain/usecases/create_reservation.dart';
import 'package:bike_app/features/rental/domain/usecases/get_active_reservation.dart';
import 'package:bike_app/features/rental/presentation/bloc/reservation_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateReservation extends Mock implements CreateReservation {}

class MockCancelReservation extends Mock implements CancelReservation {}

class MockGetActiveReservation extends Mock implements GetActiveReservation {}

void main() {
  late ReservationBloc bloc;
  late MockCreateReservation mockCreateReservation;
  late MockCancelReservation mockCancelReservation;
  late MockGetActiveReservation mockGetActiveReservation;

  setUp(() {
    mockCreateReservation = MockCreateReservation();
    mockCancelReservation = MockCancelReservation();
    mockGetActiveReservation = MockGetActiveReservation();

    bloc = ReservationBloc(
      createReservation: mockCreateReservation,
      cancelReservation: mockCancelReservation,
      getActiveReservation: mockGetActiveReservation,
    );
  });

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(const CreateReservationParams(bikeId: 'bike-123'));
    registerFallbackValue(
      const CancelReservationParams(reservationId: 'reservation-123'),
    );
  });

  tearDown(() {
    bloc.close();
  });

  // Use fixed times that are far in the future to avoid test timing issues
  final tCreatedAt = DateTime.now();
  final tExpiresAt = DateTime.now().add(const Duration(minutes: 15));

  Reservation createTestReservation() => Reservation(
    id: 'reservation-123',
    bikeId: 'bike-123',
    userId: 'user-123',
    createdAt: tCreatedAt,
    expiresAt: tExpiresAt,
    status: ReservationStatus.active,
  );

  test('initial state should be ReservationInitial', () {
    expect(bloc.state, const ReservationInitial());
  });

  group('ReservationCreated', () {
    blocTest<ReservationBloc, ReservationState>(
      'emits [ReservationLoading, ReservationActiveState] on success',
      build: () {
        final tReservation = createTestReservation();
        when(
          () => mockCreateReservation(any()),
        ).thenAnswer((_) async => Right(tReservation));
        return bloc;
      },
      act: (bloc) => bloc.add(const ReservationCreated(bikeId: 'bike-123')),
      expect: () => [const ReservationLoading(), isA<ReservationActiveState>()],
      verify: (_) {
        verify(() => mockCreateReservation(any())).called(1);
      },
    );

    blocTest<ReservationBloc, ReservationState>(
      'emits [ReservationLoading, ReservationFailure] on insufficient funds',
      build: () {
        when(
          () => mockCreateReservation(any()),
        ).thenAnswer((_) async => Left(InsufficientFundsFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const ReservationCreated(bikeId: 'bike-123')),
      expect: () => [
        const ReservationLoading(),
        const ReservationFailure(insufficientFundsMessage),
      ],
    );

    blocTest<ReservationBloc, ReservationState>(
      'emits [ReservationLoading, ReservationFailure] on bike unavailable',
      build: () {
        when(
          () => mockCreateReservation(any()),
        ).thenAnswer((_) async => Left(BikeUnavailableFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const ReservationCreated(bikeId: 'bike-123')),
      expect: () => [
        const ReservationLoading(),
        const ReservationFailure(bikeUnavailableMessage),
      ],
    );

    blocTest<ReservationBloc, ReservationState>(
      'emits [ReservationLoading, ReservationFailure] on server error',
      build: () {
        when(
          () => mockCreateReservation(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const ReservationCreated(bikeId: 'bike-123')),
      expect: () => [
        const ReservationLoading(),
        const ReservationFailure(serverFailureMessage),
      ],
    );
  });

  group('ReservationCancelled', () {
    blocTest<ReservationBloc, ReservationState>(
      'emits [ReservationLoading, ReservationCancelledState] on success',
      build: () {
        when(
          () => mockCancelReservation(any()),
        ).thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const ReservationCancelled(reservationId: 'reservation-123'),
      ),
      expect: () => [
        const ReservationLoading(),
        const ReservationCancelledState(),
      ],
    );

    blocTest<ReservationBloc, ReservationState>(
      'emits [ReservationLoading, ReservationExpiredState] '
      'when reservation expired',
      build: () {
        when(
          () => mockCancelReservation(any()),
        ).thenAnswer((_) async => Left(ReservationExpiredFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const ReservationCancelled(reservationId: 'reservation-123'),
      ),
      expect: () => [
        const ReservationLoading(),
        const ReservationExpiredState(),
      ],
    );

    blocTest<ReservationBloc, ReservationState>(
      'emits [ReservationLoading, ReservationFailure] on server error',
      build: () {
        when(
          () => mockCancelReservation(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const ReservationCancelled(reservationId: 'reservation-123'),
      ),
      expect: () => [
        const ReservationLoading(),
        const ReservationFailure(serverFailureMessage),
      ],
    );
  });

  group('ActiveReservationLoaded', () {
    blocTest<ReservationBloc, ReservationState>(
      'emits [ReservationLoading, ReservationActiveState] when active exists',
      build: () {
        final tReservation = createTestReservation();
        when(
          () => mockGetActiveReservation(any()),
        ).thenAnswer((_) async => Right(tReservation));
        return bloc;
      },
      act: (bloc) => bloc.add(const ActiveReservationLoaded()),
      expect: () => [const ReservationLoading(), isA<ReservationActiveState>()],
    );

    blocTest<ReservationBloc, ReservationState>(
      'emits [ReservationLoading, ReservationInitial] when no active',
      build: () {
        when(
          () => mockGetActiveReservation(any()),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const ActiveReservationLoaded()),
      expect: () => [const ReservationLoading(), const ReservationInitial()],
    );

    blocTest<ReservationBloc, ReservationState>(
      'emits [ReservationLoading, ReservationExpiredState] when expired',
      build: () {
        final expiredReservation = Reservation(
          id: 'reservation-123',
          bikeId: 'bike-123',
          userId: 'user-123',
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
          expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
          status: ReservationStatus.active,
        );
        when(
          () => mockGetActiveReservation(any()),
        ).thenAnswer((_) async => Right(expiredReservation));
        return bloc;
      },
      act: (bloc) => bloc.add(const ActiveReservationLoaded()),
      expect: () => [
        const ReservationLoading(),
        const ReservationExpiredState(),
      ],
    );

    blocTest<ReservationBloc, ReservationState>(
      'emits [ReservationLoading, ReservationFailure] on server error',
      build: () {
        when(
          () => mockGetActiveReservation(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const ActiveReservationLoaded()),
      expect: () => [
        const ReservationLoading(),
        const ReservationFailure(serverFailureMessage),
      ],
    );
  });
}
