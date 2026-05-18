part of 'wallet_bloc.dart';

sealed class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load wallet data (balance, transactions, payment methods).
final class WalletLoadRequested extends WalletEvent {
  const WalletLoadRequested();
}

/// Request to top up the wallet with specified amount and method.
final class TopUpRequested extends WalletEvent {
  final double amount;
  final String method;

  const TopUpRequested({required this.amount, required this.method});

  @override
  List<Object?> get props => [amount, method];
}

/// Request to load payment methods only.
final class PaymentMethodsLoadRequested extends WalletEvent {
  const PaymentMethodsLoadRequested();
}

/// Request to load transactions only.
final class TransactionsLoadRequested extends WalletEvent {
  const TransactionsLoadRequested();
}
