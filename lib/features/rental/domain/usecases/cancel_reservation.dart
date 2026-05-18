import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/rental_repository.dart';

/// Use case for cancelling a bike reservation.
@lazySingleton
class CancelReservation implements UseCase<Unit, CancelReservationParams> {
  final RentalRepository repository;

  CancelReservation(this.repository);

  @override
  FutureEither<Unit> call(CancelReservationParams params) async {
    return await repository.cancelReservation(
      reservationId: params.reservationId,
    );
  }
}

/// Parameters for [CancelReservation] use case.
class CancelReservationParams extends Equatable {
  /// ID of the reservation to cancel.
  final String reservationId;

  const CancelReservationParams({required this.reservationId});

  @override
  List<Object?> get props => [reservationId];
}
