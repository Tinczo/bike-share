import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/usecases/cancel_reservation.dart';
import '../../domain/usecases/create_reservation.dart';
import '../../domain/usecases/get_active_reservation.dart';

part 'reservation_event.dart';
part 'reservation_state.dart';

const String serverFailureMessage = 'Server error. Please try again later.';
const String networkFailureMessage = 'No internet connection';
const String insufficientFundsMessage = 'Insufficient funds. Please top up.';
const String bikeUnavailableMessage = 'This bike is currently unavailable.';
const String reservationExpiredMessage = 'Reservation has expired.';
const String unknownFailureMessage = 'An unexpected error occurred';

@lazySingleton
class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final CreateReservation createReservation;
  final CancelReservation cancelReservation;
  final GetActiveReservation getActiveReservation;

  Timer? _countdownTimer;

  ReservationBloc({
    required this.createReservation,
    required this.cancelReservation,
    required this.getActiveReservation,
  }) : super(const ReservationInitial()) {
    on<ReservationCreated>(_onReservationCreated);
    on<ReservationCancelled>(_onReservationCancelled);
    on<ReservationTimerTicked>(_onReservationTimerTicked);
    on<ActiveReservationLoaded>(_onActiveReservationLoaded);
    on<ReservationCleared>(_onReservationCleared);
  }

  Future<void> _onReservationCreated(
    ReservationCreated event,
    Emitter<ReservationState> emit,
  ) async {
    emit(const ReservationLoading());

    final result = await createReservation(
      CreateReservationParams(bikeId: event.bikeId),
    );

    result.fold(
      (failure) => emit(ReservationFailure(_mapFailureToMessage(failure))),
      (reservation) {
        _startCountdownTimer(reservation);
        emit(
          ReservationActiveState(
            reservation: reservation,
            remainingTime: reservation.remainingTime,
          ),
        );
      },
    );
  }

  Future<void> _onReservationCancelled(
    ReservationCancelled event,
    Emitter<ReservationState> emit,
  ) async {
    emit(const ReservationLoading());
    _stopCountdownTimer();

    final result = await cancelReservation(
      CancelReservationParams(reservationId: event.reservationId),
    );

    result.fold((failure) {
      if (failure is ReservationExpiredFailure) {
        emit(const ReservationExpiredState());
      } else {
        emit(ReservationFailure(_mapFailureToMessage(failure)));
      }
    }, (_) => emit(const ReservationCancelledState()));
  }

  void _onReservationTimerTicked(
    ReservationTimerTicked event,
    Emitter<ReservationState> emit,
  ) {
    final currentState = state;
    if (currentState is ReservationActiveState) {
      final remaining = currentState.reservation.remainingTime;

      if (remaining <= Duration.zero) {
        _stopCountdownTimer();
        emit(const ReservationExpiredState());
      } else {
        emit(
          ReservationActiveState(
            reservation: currentState.reservation,
            remainingTime: remaining,
          ),
        );
      }
    }
  }

  Future<void> _onActiveReservationLoaded(
    ActiveReservationLoaded event,
    Emitter<ReservationState> emit,
  ) async {
    emit(const ReservationLoading());

    final result = await getActiveReservation(NoParams());

    result.fold(
      (failure) => emit(ReservationFailure(_mapFailureToMessage(failure))),
      (reservation) {
        if (reservation == null) {
          emit(const ReservationInitial());
        } else if (reservation.isExpired) {
          emit(const ReservationExpiredState());
        } else {
          _startCountdownTimer(reservation);
          emit(
            ReservationActiveState(
              reservation: reservation,
              remainingTime: reservation.remainingTime,
            ),
          );
        }
      },
    );
  }

  void _startCountdownTimer(Reservation reservation) {
    _stopCountdownTimer();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const ReservationTimerTicked()),
    );
  }

  void _stopCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _onReservationCleared(
    ReservationCleared event,
    Emitter<ReservationState> emit,
  ) {
    _stopCountdownTimer();
    emit(const ReservationInitial());
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      NetworkFailure() => networkFailureMessage,
      ServerFailure() => serverFailureMessage,
      InsufficientFundsFailure() => insufficientFundsMessage,
      BikeUnavailableFailure() => bikeUnavailableMessage,
      ReservationExpiredFailure() => reservationExpiredMessage,
      _ => unknownFailureMessage,
    };
  }

  @override
  Future<void> close() {
    _stopCountdownTimer();
    return super.close();
  }
}
