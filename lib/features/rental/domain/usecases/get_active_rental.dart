import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rental.dart';
import '../repositories/rental_repository.dart';

/// Use case for getting the current user's active rental.
@lazySingleton
class GetActiveRental implements UseCase<Rental?, NoParams> {
  final RentalRepository repository;

  GetActiveRental(this.repository);

  @override
  FutureEither<Rental?> call(NoParams params) async {
    return await repository.getActiveRental();
  }
}
