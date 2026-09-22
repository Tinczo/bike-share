import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/rental.dart';
import '../../domain/entities/rental_eligibility.dart';
import '../../domain/entities/rental_launch_method.dart';
import '../../domain/entities/rental_status.dart';
import '../../domain/usecases/check_rental_eligibility.dart';
import '../../domain/usecases/end_rental.dart';
import '../../domain/usecases/get_active_rental.dart';
import '../../domain/usecases/pause_rental.dart';
import '../../domain/usecases/resume_rental.dart';
import '../../domain/usecases/start_rental.dart';

part 'rental_event.dart';
part 'rental_state.dart';

const String serverFailureMessage = 'Server error. Please try again later.';
const String networkFailureMessage = 'No internet connection';
const String insufficientFundsMessage = 'Insufficient funds. Please top up.';
const String bikeUnavailableMessage = 'This bike is currently unavailable.';
const String iotFailureMessage = 'Could not connect to the bike. Try again.';
const String unknownFailureMessage = 'An unexpected error occurred';
const String activeRentalExistsMessage =
    'You already have an active rental. Please end it first.';

@lazySingleton
class RentalBloc extends Bloc<RentalEvent, RentalState> {
  final CheckRentalEligibility checkRentalEligibility;
  final StartRental startRental;
  final PauseRental pauseRental;
  final ResumeRental resumeRental;
  final EndRental endRental;
  final GetActiveRental getActiveRental;

  Timer? _durationTimer;

  RentalBloc({
    required this.checkRentalEligibility,
    required this.startRental,
    required this.pauseRental,
    required this.resumeRental,
    required this.endRental,
    required this.getActiveRental,
  }) : super(const RentalInitial()) {
    on<CheckEligibilityRequested>(_onCheckEligibilityRequested);
    on<RentalStarted>(_onRentalStarted, transformer: droppable());
    on<RentalStartWithCheckRequested>(
      _onRentalStartWithCheckRequested,
      transformer: droppable(),
    );
    on<RentalPauseToggled>(_onRentalPauseToggled);
    on<RentalEndRequested>(_onRentalEndRequested);
    on<ActiveRentalLoaded>(_onActiveRentalLoaded);
    on<RentalDurationTicked>(_onRentalDurationTicked);
  }

  Future<void> _onCheckEligibilityRequested(
    CheckEligibilityRequested event,
    Emitter<RentalState> emit,
  ) async {
    // If user already has an active/paused rental, don't change state.
    // Emitting RentalEligibilityChecking would overwrite the rental state,
    // causing it to "disappear" from the UI.
    if (state is RentalActive || state is RentalPaused) {
      return;
    }

    emit(const RentalEligibilityChecking());

    final result = await checkRentalEligibility(NoParams());

    result.fold(
      (failure) => emit(RentalFailure(_mapFailureToMessage(failure))),
      (eligibility) {
        if (eligibility.isEligible) {
          emit(RentalEligible(eligibility));
        } else {
          emit(RentalIneligible(eligibility));
        }
      },
    );
  }

  Future<void> _onRentalStarted(
    RentalStarted event,
    Emitter<RentalState> emit,
  ) async {
    // If user already has an active/paused rental, don't proceed.
    // This prevents overwriting the existing rental state.
    if (state is RentalActive || state is RentalPaused) {
      return;
    }

    emit(const RentalStarting());
    emit(const RentalUnlocking());

    final result = await startRental(
      StartRentalParams(bikeId: event.bikeId, method: event.method),
    );

    result.fold(
      (failure) => emit(RentalFailure(_mapFailureToMessage(failure))),
      (rental) {
        _startDurationTimer();
        emit(RentalActive(rental));
      },
    );
  }

  Future<void> _onRentalStartWithCheckRequested(
    RentalStartWithCheckRequested event,
    Emitter<RentalState> emit,
  ) async {
    // Check if user already has an active or paused rental.
    // Don't emit RentalFailure here - it would overwrite the rental state.
    // Just silently return; the UI should prevent this case anyway.
    if (state is RentalActive || state is RentalPaused) {
      return;
    }

    // Run eligibility check first.
    emit(const RentalEligibilityChecking());

    final eligibilityResult = await checkRentalEligibility(NoParams());

    final shouldContinue = eligibilityResult.fold(
      (failure) {
        emit(RentalFailure(_mapFailureToMessage(failure)));
        return false;
      },
      (eligibility) {
        if (!eligibility.isEligible) {
          emit(RentalIneligible(eligibility));
          return false;
        }
        return true;
      },
    );

    if (!shouldContinue) return;

    // Proceed with starting the rental.
    emit(const RentalStarting());
    emit(const RentalUnlocking());

    final result = await startRental(
      StartRentalParams(bikeId: event.bikeId, method: event.method),
    );

    result.fold(
      (failure) => emit(RentalFailure(_mapFailureToMessage(failure))),
      (rental) {
        _startDurationTimer();
        emit(RentalActive(rental));
      },
    );
  }

  Future<void> _onRentalPauseToggled(
    RentalPauseToggled event,
    Emitter<RentalState> emit,
  ) async {
    final currentState = state;
    if (currentState is RentalActive) {
      emit(const RentalPausing());

      final result = await pauseRental(
        PauseRentalParams(rentalId: event.rentalId),
      );

      result.fold(
        (failure) => emit(RentalFailure(_mapFailureToMessage(failure))),
        (rental) => emit(RentalPaused(rental)),
      );
    } else if (currentState is RentalPaused) {
      emit(const RentalResuming());

      final result = await resumeRental(
        ResumeRentalParams(rentalId: event.rentalId),
      );

      result.fold(
        (failure) => emit(RentalFailure(_mapFailureToMessage(failure))),
        (rental) {
          _startDurationTimer();
          emit(RentalActive(rental));
        },
      );
    }
  }

  Future<void> _onRentalEndRequested(
    RentalEndRequested event,
    Emitter<RentalState> emit,
  ) async {
    _stopDurationTimer();
    emit(const RentalEnding());

    final result = await endRental(EndRentalParams(rentalId: event.rentalId));

    result.fold(
      (failure) => emit(RentalFailure(_mapFailureToMessage(failure))),
      (rental) => emit(RentalEnded(rental)),
    );
  }

  Future<void> _onActiveRentalLoaded(
    ActiveRentalLoaded event,
    Emitter<RentalState> emit,
  ) async {
    emit(const RentalLoading());

    final result = await getActiveRental(NoParams());

    result.fold(
      (failure) => emit(RentalFailure(_mapFailureToMessage(failure))),
      (rental) {
        if (rental == null) {
          emit(const RentalInitial());
        } else {
          switch (rental.status) {
            case RentalStatus.active:
              _startDurationTimer();
              emit(RentalActive(rental));
            case RentalStatus.paused:
              _startDurationTimer();
              emit(RentalPaused(rental));
            case RentalStatus.finished:
              emit(RentalEnded(rental));
          }
        }
      },
    );
  }

  void _onRentalDurationTicked(
    RentalDurationTicked event,
    Emitter<RentalState> emit,
  ) {
    final currentState = state;
    if (currentState is RentalActive) {
      emit(RentalActive(currentState.rental));
    } else if (currentState is RentalPaused) {
      emit(RentalPaused(currentState.rental));
    }
  }

  void _startDurationTimer() {
    _stopDurationTimer();
    _durationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const RentalDurationTicked()),
    );
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      NetworkFailure() => networkFailureMessage,
      ServerFailure() => serverFailureMessage,
      InsufficientFundsFailure() => insufficientFundsMessage,
      BikeUnavailableFailure() => bikeUnavailableMessage,
      IoTFailure() => iotFailureMessage,
      ActiveRentalExistsFailure() => activeRentalExistsMessage,
      _ => unknownFailureMessage,
    };
  }

  @override
  Future<void> close() {
    _stopDurationTimer();
    return super.close();
  }
}
