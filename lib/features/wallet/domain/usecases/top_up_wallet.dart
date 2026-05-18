import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wallet_repository.dart';

/// Use case for topping up the wallet.
@lazySingleton
class TopUpWallet implements UseCase<Unit, TopUpParams> {
  final WalletRepository repository;

  TopUpWallet(this.repository);

  @override
  FutureEither<Unit> call(TopUpParams params) async {
    return await repository.topUpWallet(
      amount: params.amount,
      method: params.method,
    );
  }
}

/// Parameters for [TopUpWallet] use case.
class TopUpParams extends Equatable {
  /// Amount to top up in PLN.
  final double amount;

  /// Payment method identifier (e.g., 'blik', 'card').
  final String method;

  const TopUpParams({required this.amount, required this.method});

  @override
  List<Object?> get props => [amount, method];
}
