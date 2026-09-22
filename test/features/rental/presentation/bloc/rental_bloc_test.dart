import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/rental/domain/entities/rental.dart';
import 'package:bike_app/features/rental/domain/entities/rental_eligibility.dart';
import 'package:bike_app/features/rental/domain/entities/rental_launch_method.dart';
import 'package:bike_app/features/rental/domain/entities/rental_status.dart';
import 'package:bike_app/features/rental/domain/usecases/check_rental_eligibility.dart';
import 'package:bike_app/features/rental/domain/usecases/end_rental.dart';
import 'package:bike_app/features/rental/domain/usecases/get_active_rental.dart';
import 'package:bike_app/features/rental/domain/usecases/pause_rental.dart';
import 'package:bike_app/features/rental/domain/usecases/resume_rental.dart';
import 'package:bike_app/features/rental/domain/usecases/start_rental.dart';
import 'package:bike_app/features/rental/presentation/bloc/rental_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckRentalEligibility extends Mock
    implements CheckRentalEligibility {}

class MockStartRental extends Mock implements StartRental {}

class MockPauseRental extends Mock implements PauseRental {}

class MockResumeRental extends Mock implements ResumeRental {}

class MockEndRental extends Mock implements EndRental {}

class MockGetActiveRental extends Mock implements GetActiveRental {}

void main() {
  late RentalBloc bloc;
  late MockCheckRentalEligibility mockCheckRentalEligibility;
  late MockStartRental mockStartRental;
  late MockPauseRental mockPauseRental;
  late MockResumeRental mockResumeRental;
  late MockEndRental mockEndRental;
  late MockGetActiveRental mockGetActiveRental;

  setUp(() {
    mockCheckRentalEligibility = MockCheckRentalEligibility();
    mockStartRental = MockStartRental();
    mockPauseRental = MockPauseRental();
    mockResumeRental = MockResumeRental();
    mockEndRental = MockEndRental();
    mockGetActiveRental = MockGetActiveRental();

    bloc = RentalBloc(
      checkRentalEligibility: mockCheckRentalEligibility,
      startRental: mockStartRental,
      pauseRental: mockPauseRental,
      resumeRental: mockResumeRental,
      endRental: mockEndRental,
      getActiveRental: mockGetActiveRental,
    );
  });

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(
      const StartRentalParams(
        bikeId: 'bike-123',
        method: RentalLaunchMethod.qr,
      ),
    );
    registerFallbackValue(const PauseRentalParams(rentalId: 'rental-123'));
    registerFallbackValue(const ResumeRentalParams(rentalId: 'rental-123'));
    registerFallbackValue(const EndRentalParams(rentalId: 'rental-123'));
  });

  tearDown(() {
    bloc.close();
  });

  const tEligibility = RentalEligibility(
    isEligible: true,
    hasMinimumBalance: true,
    hasLinkedCard: true,
    hasActiveSubscription: false,
    isDebtor: false,
  );

  const tIneligibility = RentalEligibility(
    isEligible: false,
    hasMinimumBalance: false,
    hasLinkedCard: true,
    hasActiveSubscription: false,
    isDebtor: true,
    reason: 'Outstanding debt',
  );

  final tStartTime = DateTime(2024, 1, 15, 10, 0);

  final tRental = Rental(
    id: 'rental-123',
    bikeId: 'bike-123',
    userId: 'user-123',
    startTime: tStartTime,
    cost: 0.0,
    status: RentalStatus.active,
  );

  final tPausedRental = Rental(
    id: 'rental-123',
    bikeId: 'bike-123',
    userId: 'user-123',
    startTime: tStartTime,
    cost: 5.0,
    status: RentalStatus.paused,
  );

  final tResumedRental = Rental(
    id: 'rental-123',
    bikeId: 'bike-123',
    userId: 'user-123',
    startTime: tStartTime,
    cost: 5.0,
    status: RentalStatus.active,
  );

  final tFinishedRental = Rental(
    id: 'rental-123',
    bikeId: 'bike-123',
    userId: 'user-123',
    startTime: tStartTime,
    endTime: DateTime(2024, 1, 15, 11, 30),
    cost: 15.0,
    status: RentalStatus.finished,
  );

  test('initial state should be RentalInitial', () {
    expect(bloc.state, const RentalInitial());
  });

  group('CheckEligibilityRequested', () {
    blocTest<RentalBloc, RentalState>(
      'emits [RentalEligibilityChecking, RentalEligible] when eligible',
      build: () {
        when(
          () => mockCheckRentalEligibility(any()),
        ).thenAnswer((_) async => const Right(tEligibility));
        return bloc;
      },
      act: (bloc) => bloc.add(const CheckEligibilityRequested()),
      expect: () => [
        const RentalEligibilityChecking(),
        const RentalEligible(tEligibility),
      ],
      verify: (_) {
        verify(() => mockCheckRentalEligibility(any())).called(1);
      },
    );

    blocTest<RentalBloc, RentalState>(
      'emits [RentalEligibilityChecking, RentalIneligible] when not eligible',
      build: () {
        when(
          () => mockCheckRentalEligibility(any()),
        ).thenAnswer((_) async => const Right(tIneligibility));
        return bloc;
      },
      act: (bloc) => bloc.add(const CheckEligibilityRequested()),
      expect: () => [
        const RentalEligibilityChecking(),
        const RentalIneligible(tIneligibility),
      ],
    );

    blocTest<RentalBloc, RentalState>(
      'emits [RentalEligibilityChecking, RentalFailure] on server error',
      build: () {
        when(
          () => mockCheckRentalEligibility(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const CheckEligibilityRequested()),
      expect: () => [
        const RentalEligibilityChecking(),
        const RentalFailure(serverFailureMessage),
      ],
    );

    blocTest<RentalBloc, RentalState>(
      'emits [RentalEligibilityChecking, RentalFailure] on network error',
      build: () {
        when(
          () => mockCheckRentalEligibility(any()),
        ).thenAnswer((_) async => Left(NetworkFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const CheckEligibilityRequested()),
      expect: () => [
        const RentalEligibilityChecking(),
        const RentalFailure(networkFailureMessage),
      ],
    );
  });

  group('RentalStarted', () {
    blocTest<RentalBloc, RentalState>(
      'emits [RentalStarting, RentalUnlocking, RentalActive] on success',
      build: () {
        when(
          () => mockStartRental(any()),
        ).thenAnswer((_) async => Right(tRental));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const RentalStarted(bikeId: 'bike-123', method: RentalLaunchMethod.qr),
      ),
      expect: () => [
        const RentalStarting(),
        const RentalUnlocking(),
        isA<RentalActive>().having((s) => s.rental, 'rental', tRental),
      ],
    );

    blocTest<RentalBloc, RentalState>(
      'emits [RentalStarting, RentalUnlocking, RentalFailure] '
      'on insufficient funds',
      build: () {
        when(
          () => mockStartRental(any()),
        ).thenAnswer((_) async => Left(InsufficientFundsFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const RentalStarted(bikeId: 'bike-123', method: RentalLaunchMethod.qr),
      ),
      expect: () => [
        const RentalStarting(),
        const RentalUnlocking(),
        const RentalFailure(insufficientFundsMessage),
      ],
    );

    blocTest<RentalBloc, RentalState>(
      'emits [RentalStarting, RentalUnlocking, RentalFailure] '
      'on bike unavailable',
      build: () {
        when(
          () => mockStartRental(any()),
        ).thenAnswer((_) async => Left(BikeUnavailableFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const RentalStarted(bikeId: 'bike-123', method: RentalLaunchMethod.qr),
      ),
      expect: () => [
        const RentalStarting(),
        const RentalUnlocking(),
        const RentalFailure(bikeUnavailableMessage),
      ],
    );

    blocTest<RentalBloc, RentalState>(
      'emits [RentalStarting, RentalUnlocking, RentalFailure] on IoT failure',
      build: () {
        when(
          () => mockStartRental(any()),
        ).thenAnswer((_) async => Left(IoTFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const RentalStarted(bikeId: 'bike-123', method: RentalLaunchMethod.qr),
      ),
      expect: () => [
        const RentalStarting(),
        const RentalUnlocking(),
        const RentalFailure(iotFailureMessage),
      ],
    );

    blocTest<RentalBloc, RentalState>(
      'starts the rental only once when the event is added twice in a row',
      build: () {
        when(() => mockStartRental(any())).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return Right(tRental);
        });
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          const RentalStarted(
            bikeId: 'bike-123',
            method: RentalLaunchMethod.qr,
          ),
        );
        bloc.add(
          const RentalStarted(
            bikeId: 'bike-123',
            method: RentalLaunchMethod.qr,
          ),
        );
      },
      wait: const Duration(milliseconds: 150),
      expect: () => [
        const RentalStarting(),
        const RentalUnlocking(),
        isA<RentalActive>().having((s) => s.rental, 'rental', tRental),
      ],
      verify: (_) {
        verify(() => mockStartRental(any())).called(1);
      },
    );
  });

  group('RentalPauseToggled', () {
    blocTest<RentalBloc, RentalState>(
      'emits [RentalPausing, RentalPaused] when pausing from active state',
      build: () {
        when(
          () => mockPauseRental(any()),
        ).thenAnswer((_) async => Right(tPausedRental));
        return bloc;
      },
      seed: () => RentalActive(tRental),
      act: (bloc) => bloc.add(const RentalPauseToggled(rentalId: 'rental-123')),
      expect: () => [
        const RentalPausing(),
        isA<RentalPaused>().having((s) => s.rental, 'rental', tPausedRental),
      ],
    );

    blocTest<RentalBloc, RentalState>(
      'emits [RentalResuming, RentalActive] when resuming from paused state',
      build: () {
        when(
          () => mockResumeRental(any()),
        ).thenAnswer((_) async => Right(tResumedRental));
        return bloc;
      },
      seed: () => RentalPaused(tPausedRental),
      act: (bloc) => bloc.add(const RentalPauseToggled(rentalId: 'rental-123')),
      expect: () => [
        const RentalResuming(),
        isA<RentalActive>().having((s) => s.rental, 'rental', tResumedRental),
      ],
      verify: (_) {
        verify(() => mockResumeRental(any())).called(1);
      },
    );

    blocTest<RentalBloc, RentalState>(
      'emits [RentalResuming, RentalFailure] on server error when resuming',
      build: () {
        when(
          () => mockResumeRental(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      seed: () => RentalPaused(tPausedRental),
      act: (bloc) => bloc.add(const RentalPauseToggled(rentalId: 'rental-123')),
      expect: () => [
        const RentalResuming(),
        const RentalFailure(serverFailureMessage),
      ],
    );

    blocTest<RentalBloc, RentalState>(
      'emits [RentalPausing, RentalFailure] on server error when pausing',
      build: () {
        when(
          () => mockPauseRental(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      seed: () => RentalActive(tRental),
      act: (bloc) => bloc.add(const RentalPauseToggled(rentalId: 'rental-123')),
      expect: () => [
        const RentalPausing(),
        const RentalFailure(serverFailureMessage),
      ],
    );
  });

  group('RentalEndRequested', () {
    blocTest<RentalBloc, RentalState>(
      'emits [RentalEnding, RentalEnded] on success',
      build: () {
        when(
          () => mockEndRental(any()),
        ).thenAnswer((_) async => Right(tFinishedRental));
        return bloc;
      },
      act: (bloc) => bloc.add(const RentalEndRequested(rentalId: 'rental-123')),
      expect: () => [const RentalEnding(), RentalEnded(tFinishedRental)],
    );

    blocTest<RentalBloc, RentalState>(
      'emits [RentalEnding, RentalFailure] on server error',
      build: () {
        when(
          () => mockEndRental(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const RentalEndRequested(rentalId: 'rental-123')),
      expect: () => [
        const RentalEnding(),
        const RentalFailure(serverFailureMessage),
      ],
    );
  });

  group('ActiveRentalLoaded', () {
    blocTest<RentalBloc, RentalState>(
      'emits [RentalLoading, RentalActive] when active rental exists',
      build: () {
        when(
          () => mockGetActiveRental(any()),
        ).thenAnswer((_) async => Right(tRental));
        return bloc;
      },
      act: (bloc) => bloc.add(const ActiveRentalLoaded()),
      expect: () => [
        const RentalLoading(),
        isA<RentalActive>().having((s) => s.rental, 'rental', tRental),
      ],
    );

    blocTest<RentalBloc, RentalState>(
      'emits [RentalLoading, RentalPaused] when paused rental exists',
      build: () {
        when(
          () => mockGetActiveRental(any()),
        ).thenAnswer((_) async => Right(tPausedRental));
        return bloc;
      },
      act: (bloc) => bloc.add(const ActiveRentalLoaded()),
      expect: () => [
        const RentalLoading(),
        isA<RentalPaused>().having((s) => s.rental, 'rental', tPausedRental),
      ],
    );

    blocTest<RentalBloc, RentalState>(
      'emits [RentalLoading, RentalInitial] when no active rental',
      build: () {
        when(
          () => mockGetActiveRental(any()),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const ActiveRentalLoaded()),
      expect: () => [const RentalLoading(), const RentalInitial()],
    );

    blocTest<RentalBloc, RentalState>(
      'emits [RentalLoading, RentalFailure] on server error',
      build: () {
        when(
          () => mockGetActiveRental(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const ActiveRentalLoaded()),
      expect: () => [
        const RentalLoading(),
        const RentalFailure(serverFailureMessage),
      ],
    );
  });

  group('RentalStartWithCheckRequested', () {
    blocTest<RentalBloc, RentalState>(
      'does not emit when already has active rental (preserves existing state)',
      build: () => bloc,
      seed: () => RentalActive(tRental),
      act: (bloc) => bloc.add(
        const RentalStartWithCheckRequested(
          bikeId: 'bike-456',
          method: RentalLaunchMethod.manual,
        ),
      ),
      expect: () => <RentalState>[],
      verify: (_) {
        verifyNever(() => mockCheckRentalEligibility(any()));
        verifyNever(() => mockStartRental(any()));
      },
    );

    blocTest<RentalBloc, RentalState>(
      'does not emit when already has paused rental (preserves existing state)',
      build: () => bloc,
      seed: () => RentalPaused(tPausedRental),
      act: (bloc) => bloc.add(
        const RentalStartWithCheckRequested(
          bikeId: 'bike-456',
          method: RentalLaunchMethod.manual,
        ),
      ),
      expect: () => <RentalState>[],
      verify: (_) {
        verifyNever(() => mockCheckRentalEligibility(any()));
        verifyNever(() => mockStartRental(any()));
      },
    );

    blocTest<RentalBloc, RentalState>(
      'emits [RentalEligibilityChecking, RentalIneligible] when not eligible',
      build: () {
        when(
          () => mockCheckRentalEligibility(any()),
        ).thenAnswer((_) async => const Right(tIneligibility));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const RentalStartWithCheckRequested(
          bikeId: 'bike-123',
          method: RentalLaunchMethod.manual,
        ),
      ),
      expect: () => [
        const RentalEligibilityChecking(),
        const RentalIneligible(tIneligibility),
      ],
      verify: (_) {
        verify(() => mockCheckRentalEligibility(any())).called(1);
        verifyNever(() => mockStartRental(any()));
      },
    );

    blocTest<RentalBloc, RentalState>(
      'emits [RentalEligibilityChecking, RentalFailure] on eligibility error',
      build: () {
        when(
          () => mockCheckRentalEligibility(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const RentalStartWithCheckRequested(
          bikeId: 'bike-123',
          method: RentalLaunchMethod.manual,
        ),
      ),
      expect: () => [
        const RentalEligibilityChecking(),
        const RentalFailure(serverFailureMessage),
      ],
      verify: (_) {
        verify(() => mockCheckRentalEligibility(any())).called(1);
        verifyNever(() => mockStartRental(any()));
      },
    );

    blocTest<RentalBloc, RentalState>(
      'emits full success flow when eligible and no active rental',
      build: () {
        when(
          () => mockCheckRentalEligibility(any()),
        ).thenAnswer((_) async => const Right(tEligibility));
        when(
          () => mockStartRental(any()),
        ).thenAnswer((_) async => Right(tRental));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const RentalStartWithCheckRequested(
          bikeId: 'bike-123',
          method: RentalLaunchMethod.manual,
        ),
      ),
      expect: () => [
        const RentalEligibilityChecking(),
        const RentalStarting(),
        const RentalUnlocking(),
        isA<RentalActive>().having((s) => s.rental, 'rental', tRental),
      ],
      verify: (_) {
        verify(() => mockCheckRentalEligibility(any())).called(1);
        verify(() => mockStartRental(any())).called(1);
      },
    );

    blocTest<RentalBloc, RentalState>(
      'emits failure when eligible but rental start fails',
      build: () {
        when(
          () => mockCheckRentalEligibility(any()),
        ).thenAnswer((_) async => const Right(tEligibility));
        when(
          () => mockStartRental(any()),
        ).thenAnswer((_) async => Left(BikeUnavailableFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const RentalStartWithCheckRequested(
          bikeId: 'bike-123',
          method: RentalLaunchMethod.manual,
        ),
      ),
      expect: () => [
        const RentalEligibilityChecking(),
        const RentalStarting(),
        const RentalUnlocking(),
        const RentalFailure(bikeUnavailableMessage),
      ],
      verify: (_) {
        verify(() => mockCheckRentalEligibility(any())).called(1);
        verify(() => mockStartRental(any())).called(1);
      },
    );
  });

  group('RentalDurationTicked', () {
    blocTest<RentalBloc, RentalState>(
      'emits RentalActive with same rental when in active state',
      build: () => bloc,
      seed: () => RentalActive(
        tRental,
        refreshedAt: DateTime(2024, 1, 1), // Fixed past timestamp
      ),
      act: (bloc) => bloc.add(const RentalDurationTicked()),
      expect: () => [isA<RentalActive>().having((s) => s.rental, 'rental', tRental)],
    );

    blocTest<RentalBloc, RentalState>(
      'emits RentalPaused with same rental when in paused state',
      build: () => bloc,
      seed: () => RentalPaused(
        tPausedRental,
        refreshedAt: DateTime(2024, 1, 1), // Fixed past timestamp
      ),
      act: (bloc) => bloc.add(const RentalDurationTicked()),
      expect: () => [isA<RentalPaused>().having((s) => s.rental, 'rental', tPausedRental)],
    );

    blocTest<RentalBloc, RentalState>(
      'does not emit when in initial state',
      build: () => bloc,
      act: (bloc) => bloc.add(const RentalDurationTicked()),
      expect: () => <RentalState>[],
    );

    blocTest<RentalBloc, RentalState>(
      'does not emit when in loading state',
      build: () => bloc,
      seed: () => const RentalLoading(),
      act: (bloc) => bloc.add(const RentalDurationTicked()),
      expect: () => <RentalState>[],
    );
  });

  group('Duration timer behavior', () {
    test('timer starts when rental becomes active via RentalStarted', () async {
      when(
        () => mockStartRental(any()),
      ).thenAnswer((_) async => Right(tRental));

      bloc.add(
        const RentalStarted(bikeId: 'bike-123', method: RentalLaunchMethod.qr),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const RentalStarting(),
          const RentalUnlocking(),
          isA<RentalActive>(),
        ]),
      );

      // Wait for timer to tick once
      await Future<void>.delayed(const Duration(seconds: 1, milliseconds: 100));

      // Verify we received another RentalActive state from the timer
      expect(bloc.state, isA<RentalActive>());
    });

    test('timer stops when bloc is closed', () async {
      when(
        () => mockStartRental(any()),
      ).thenAnswer((_) async => Right(tRental));

      bloc.add(
        const RentalStarted(bikeId: 'bike-123', method: RentalLaunchMethod.qr),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const RentalStarting(),
          const RentalUnlocking(),
          isA<RentalActive>(),
        ]),
      );

      // Close the bloc - this should stop the timer without errors
      await bloc.close();

      // Wait to ensure no timer errors occur after close
      await Future<void>.delayed(const Duration(seconds: 1, milliseconds: 100));
    });

    test('timer stops when rental ends', () async {
      when(
        () => mockEndRental(any()),
      ).thenAnswer((_) async => Right(tFinishedRental));

      // Start with an active rental
      bloc.emit(RentalActive(tRental));

      // End the rental
      bloc.add(const RentalEndRequested(rentalId: 'rental-123'));

      await expectLater(
        bloc.stream,
        emitsInOrder([const RentalEnding(), RentalEnded(tFinishedRental)]),
      );

      // Wait to verify no more ticks occur
      final statesAfterEnd = <RentalState>[];
      final subscription = bloc.stream.listen(statesAfterEnd.add);

      await Future<void>.delayed(const Duration(seconds: 1, milliseconds: 100));
      await subscription.cancel();

      expect(statesAfterEnd, isEmpty);
    });
  });
}
