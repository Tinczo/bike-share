import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rental_eligibility.dart';
import '../repositories/rental_repository.dart';

/// Use case for checking if the current user is eligible to rent a bike.
@lazySingleton
class CheckRentalEligibility implements UseCase<RentalEligibility, NoParams> {
  final RentalRepository repository;

  CheckRentalEligibility(this.repository);

  @override
  FutureEither<RentalEligibility> call(NoParams params) async {
    return await repository.checkEligibility();
  }
}
