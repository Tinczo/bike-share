import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/type_defs.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  WalletRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  FutureEither<Wallet> getWallet() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final wallet = await remoteDataSource.getWallet();
      return Right(wallet);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  FutureEither<List<Transaction>> getTransactions() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final transactions = await remoteDataSource.getTransactions();
      return Right(transactions);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  FutureEither<Unit> topUpWallet({
    required double amount,
    required String method,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await remoteDataSource.topUpWallet(amount: amount, method: method);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  FutureEither<List<PaymentMethod>> getPaymentMethods() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final methods = await remoteDataSource.getPaymentMethods();
      return Right(methods);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  FutureEither<Unit> addPaymentMethod(PaymentMethod method) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await remoteDataSource.addPaymentMethod(method);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
