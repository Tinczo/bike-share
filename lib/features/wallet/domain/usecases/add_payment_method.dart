import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_method.dart';
import '../repositories/wallet_repository.dart';

/// Use case for adding a new payment method.
@lazySingleton
class AddPaymentMethod implements UseCase<Unit, AddPaymentMethodParams> {
  final WalletRepository repository;

  AddPaymentMethod(this.repository);

  @override
  FutureEither<Unit> call(AddPaymentMethodParams params) async {
    return await repository.addPaymentMethod(params.paymentMethod);
  }
}

/// Parameters for [AddPaymentMethod] use case.
class AddPaymentMethodParams extends Equatable {
  /// The payment method to add.
  final PaymentMethod paymentMethod;

  const AddPaymentMethodParams({required this.paymentMethod});

  @override
  List<Object?> get props => [paymentMethod];
}
