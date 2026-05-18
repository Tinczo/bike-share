import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rental.dart';
import '../repositories/rental_repository.dart';

/// Use case for pausing an active rental.
@lazySingleton
class PauseRental implements UseCase<Rental, PauseRentalParams> {
  final RentalRepository repository;

  PauseRental(this.repository);

  @override
  FutureEither<Rental> call(PauseRentalParams params) async {
    return await repository.pauseRental(rentalId: params.rentalId);
  }
}

/// Parameters for [PauseRental] use case.
class PauseRentalParams extends Equatable {
  /// ID of the rental to pause.
  final String rentalId;

  const PauseRentalParams({required this.rentalId});

  @override
  List<Object?> get props => [rentalId];
}
