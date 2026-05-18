import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/wallet_repository.dart';

/// Use case for retrieving the transaction history.
@lazySingleton
class GetTransactions implements UseCase<List<Transaction>, NoParams> {
  final WalletRepository repository;

  GetTransactions(this.repository);

  @override
  FutureEither<List<Transaction>> call(NoParams params) async {
    return await repository.getTransactions();
  }
}
