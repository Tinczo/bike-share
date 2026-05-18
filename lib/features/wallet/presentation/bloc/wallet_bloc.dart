import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/usecases/add_payment_method.dart';
import '../../domain/usecases/get_payment_methods.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/get_wallet.dart';
import '../../domain/usecases/top_up_wallet.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

const String serverFailureMessage = 'Server error. Please try again later.';
const String networkFailureMessage = 'No internet connection';
const String cacheFailureMessage = 'Failed to load cached data';

@lazySingleton
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWallet getWallet;
  final GetTransactions getTransactions;
  final TopUpWallet topUpWallet;
  final GetPaymentMethods getPaymentMethods;
  final AddPaymentMethod addPaymentMethod;

  WalletBloc({
    required this.getWallet,
    required this.getTransactions,
    required this.topUpWallet,
    required this.getPaymentMethods,
    required this.addPaymentMethod,
  }) : super(const WalletInitial()) {
    on<WalletLoadRequested>(_onWalletLoadRequested);
    on<TopUpRequested>(_onTopUpRequested);
    on<PaymentMethodsLoadRequested>(_onPaymentMethodsLoadRequested);
    on<TransactionsLoadRequested>(_onTransactionsLoadRequested);
  }

  Future<void> _onWalletLoadRequested(
    WalletLoadRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    final walletResult = await getWallet(NoParams());

    await walletResult.fold(
      (failure) async => emit(WalletError(_mapFailureToMessage(failure))),
      (wallet) async {
        final transactionsResult = await getTransactions(NoParams());
        final paymentMethodsResult = await getPaymentMethods(NoParams());

        transactionsResult.fold(
          (failure) => emit(WalletError(_mapFailureToMessage(failure))),
          (transactions) {
            paymentMethodsResult.fold(
              (failure) => emit(WalletError(_mapFailureToMessage(failure))),
              (paymentMethods) => emit(
                WalletLoaded(
                  wallet: wallet,
                  transactions: transactions,
                  paymentMethods: paymentMethods,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onTopUpRequested(
    TopUpRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletTopUpInProgress());

    final result = await topUpWallet(
      TopUpParams(amount: event.amount, method: event.method),
    );

    result.fold(
      (failure) => emit(WalletError(_mapFailureToMessage(failure))),
      (_) => emit(const WalletTopUpSuccess()),
    );
  }

  Future<void> _onPaymentMethodsLoadRequested(
    PaymentMethodsLoadRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    final result = await getPaymentMethods(NoParams());

    result.fold(
      (failure) => emit(WalletError(_mapFailureToMessage(failure))),
      (methods) => emit(PaymentMethodsLoaded(methods)),
    );
  }

  Future<void> _onTransactionsLoadRequested(
    TransactionsLoadRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    final result = await getTransactions(NoParams());

    result.fold(
      (failure) => emit(WalletError(_mapFailureToMessage(failure))),
      (transactions) => emit(TransactionsLoaded(transactions)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      NetworkFailure() => networkFailureMessage,
      ServerFailure() => serverFailureMessage,
      CacheFailure() => cacheFailureMessage,
      _ => 'An unexpected error occurred',
    };
  }
}
