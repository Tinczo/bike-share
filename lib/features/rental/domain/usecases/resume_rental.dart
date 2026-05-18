import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rental.dart';
import '../repositories/rental_repository.dart';

/// Use case for resuming a paused rental.
@lazySingleton
class ResumeRental implements UseCase<Rental, ResumeRentalParams> {
  final RentalRepository repository;

  ResumeRental(this.repository);

  @override
  FutureEither<Rental> call(ResumeRentalParams params) async {
    return await repository.resumeRental(rentalId: params.rentalId);
  }
}

/// Parameters for [ResumeRental] use case.
class ResumeRentalParams extends Equatable {
  /// ID of the rental to resume.
  final String rentalId;

  const ResumeRentalParams({required this.rentalId});

  @override
  List<Object?> get props => [rentalId];
}
