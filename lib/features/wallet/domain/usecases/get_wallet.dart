import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet.dart';
import '../repositories/wallet_repository.dart';

/// Use case for retrieving the current user's wallet.
@lazySingleton
class GetWallet implements UseCase<Wallet, NoParams> {
  final WalletRepository repository;

  GetWallet(this.repository);

  @override
  FutureEither<Wallet> call(NoParams params) async {
    return await repository.getWallet();
  }
}
