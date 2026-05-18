import 'package:dartz/dartz.dart';

import '../../../../core/type_defs.dart';
import '../entities/payment_method.dart';
import '../entities/transaction.dart';
import '../entities/wallet.dart';

/// Contract for wallet operations.
///
/// This interface defines all wallet-related operations that must be
/// implemented by the data layer.
abstract class WalletRepository {
  /// Retrieves the current user's wallet balance and status.
  ///
  /// Returns [Wallet] on success or [Failure] on error.
  FutureEither<Wallet> getWallet();

  /// Retrieves the transaction history for the current user.
  ///
  /// Returns a list of [Transaction] on success or [Failure] on error.
  FutureEither<List<Transaction>> getTransactions();

  /// Tops up the wallet with the specified amount using the given method.
  ///
  /// [amount] - The amount to add to the wallet in PLN.
  /// [method] - The payment method identifier to use.
  ///
  /// Returns [Unit] on success or [Failure] on error.
  FutureEither<Unit> topUpWallet({
    required double amount,
    required String method,
  });

  /// Retrieves all saved payment methods for the current user.
  ///
  /// Returns a list of [PaymentMethod] on success or [Failure] on error.
  FutureEither<List<PaymentMethod>> getPaymentMethods();

  /// Adds a new payment method for the current user.
  ///
  /// [method] - The payment method to add.
  ///
  /// Returns [Unit] on success or [Failure] on error.
  FutureEither<Unit> addPaymentMethod(PaymentMethod method);
}
