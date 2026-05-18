import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reservation.dart';
import '../repositories/rental_repository.dart';

/// Use case for creating a bike reservation.
@lazySingleton
class CreateReservation
    implements UseCase<Reservation, CreateReservationParams> {
  final RentalRepository repository;

  CreateReservation(this.repository);

  @override
  FutureEither<Reservation> call(CreateReservationParams params) async {
    return await repository.createReservation(bikeId: params.bikeId);
  }
}

/// Parameters for [CreateReservation] use case.
class CreateReservationParams extends Equatable {
  /// ID of the bike to reserve.
  final String bikeId;

  const CreateReservationParams({required this.bikeId});

  @override
  List<Object?> get props => [bikeId];
}
