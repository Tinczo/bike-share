import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reservation.dart';
import '../repositories/rental_repository.dart';

/// Use case for getting the current user's active reservation.
@lazySingleton
class GetActiveReservation implements UseCase<Reservation?, NoParams> {
  final RentalRepository repository;

  GetActiveReservation(this.repository);

  @override
  FutureEither<Reservation?> call(NoParams params) async {
    return await repository.getActiveReservation();
  }
}
