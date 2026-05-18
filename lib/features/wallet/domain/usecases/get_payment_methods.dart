import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_method.dart';
import '../repositories/wallet_repository.dart';

/// Use case for retrieving saved payment methods.
@lazySingleton
class GetPaymentMethods implements UseCase<List<PaymentMethod>, NoParams> {
  final WalletRepository repository;

  GetPaymentMethods(this.repository);

  @override
  FutureEither<List<PaymentMethod>> call(NoParams params) async {
    return await repository.getPaymentMethods();
  }
}
