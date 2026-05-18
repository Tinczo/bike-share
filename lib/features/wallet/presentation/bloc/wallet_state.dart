part of 'wallet_bloc.dart';

sealed class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
final class WalletInitial extends WalletState {
  const WalletInitial();
}

/// Loading state while fetching data.
final class WalletLoading extends WalletState {
  const WalletLoading();
}

/// State when all wallet data is successfully loaded.
final class WalletLoaded extends WalletState {
  final Wallet wallet;
  final List<Transaction> transactions;
  final List<PaymentMethod> paymentMethods;

  const WalletLoaded({
    required this.wallet,
    required this.transactions,
    required this.paymentMethods,
  });

  @override
  List<Object?> get props => [wallet, transactions, paymentMethods];
}

/// State when a top-up is in progress.
final class WalletTopUpInProgress extends WalletState {
  const WalletTopUpInProgress();
}

/// State when a top-up is successful.
final class WalletTopUpSuccess extends WalletState {
  const WalletTopUpSuccess();
}

/// State when only payment methods are loaded.
final class PaymentMethodsLoaded extends WalletState {
  final List<PaymentMethod> paymentMethods;

  const PaymentMethodsLoaded(this.paymentMethods);

  @override
  List<Object?> get props => [paymentMethods];
}

/// State when only transactions are loaded.
final class TransactionsLoaded extends WalletState {
  final List<Transaction> transactions;

  const TransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

/// Error state with a message.
final class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
