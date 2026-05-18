import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rental_history_item.dart';
import '../repositories/account_repository.dart';

/// Use case for retrieving the user's rental history.
@lazySingleton
class GetRentalHistory implements UseCase<List<RentalHistoryItem>, NoParams> {
  final AccountRepository repository;

  GetRentalHistory(this.repository);

  @override
  FutureEither<List<RentalHistoryItem>> call(NoParams params) async {
    return await repository.getRentalHistory();
  }
}
