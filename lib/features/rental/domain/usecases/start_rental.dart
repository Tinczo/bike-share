import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rental.dart';
import '../entities/rental_launch_method.dart';
import '../repositories/rental_repository.dart';

/// Use case for starting a new bike rental.
@lazySingleton
class StartRental implements UseCase<Rental, StartRentalParams> {
  final RentalRepository repository;

  StartRental(this.repository);

  @override
  FutureEither<Rental> call(StartRentalParams params) async {
    return await repository.startRental(
      bikeId: params.bikeId,
      method: params.method,
    );
  }
}

/// Parameters for [StartRental] use case.
class StartRentalParams extends Equatable {
  /// ID of the bike to rent.
  final String bikeId;

  /// Method used to start the rental.
  final RentalLaunchMethod method;

  const StartRentalParams({required this.bikeId, required this.method});

  @override
  List<Object?> get props => [bikeId, method];
}
