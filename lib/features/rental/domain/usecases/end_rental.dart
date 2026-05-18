import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rental.dart';
import '../repositories/rental_repository.dart';

/// Use case for ending an active rental.
@lazySingleton
class EndRental implements UseCase<Rental, EndRentalParams> {
  final RentalRepository repository;

  EndRental(this.repository);

  @override
  FutureEither<Rental> call(EndRentalParams params) async {
    return await repository.endRental(rentalId: params.rentalId);
  }
}

/// Parameters for [EndRental] use case.
class EndRentalParams extends Equatable {
  /// ID of the rental to end.
  final String rentalId;

  const EndRentalParams({required this.rentalId});

  @override
  List<Object?> get props => [rentalId];
}
