import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/config/base_url_provider.dart';
import '../../../../core/error/exceptions.dart';
import '../../../options/domain/entities/api_options.dart';
import '../../domain/entities/payment_method.dart';
import '../models/payment_method_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

/// Remote data source for wallet operations.
abstract class WalletRemoteDataSource {
  /// Fetches the current user's wallet.
  ///
  /// Throws [ServerException] on server error.
  Future<WalletModel> getWallet();

  /// Fetches the transaction history.
  ///
  /// Throws [ServerException] on server error.
  Future<List<TransactionModel>> getTransactions();

  /// Tops up the wallet with the specified amount.
  ///
  /// Throws [ServerException] on server error.
  Future<void> topUpWallet({required double amount, required String method});

  /// Fetches saved payment methods.
  ///
  /// Throws [ServerException] on server error.
  Future<List<PaymentMethodModel>> getPaymentMethods();

  /// Adds a new payment method.
  ///
  /// Throws [ServerException] on server error.
  Future<void> addPaymentMethod(PaymentMethod method);
}

@LazySingleton(as: WalletRemoteDataSource)
class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final Dio dio;
  final BaseUrlProvider baseUrlProvider;

  WalletRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrlProvider,
  });

  String get _baseUrl => baseUrlProvider.getBaseUrlSync(DataSourceType.wallet);

  @override
  Future<WalletModel> getWallet() async {
    try {
      final response = await dio.get('$_baseUrl/wallet');

      if (response.statusCode == 200) {
        final walletData = response.data['wallet'] as Map<String, dynamic>;
        return WalletModel.fromJson(walletData);
      }
      throw ServerException();
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await dio.get('$_baseUrl/wallet/transactions');

      if (response.statusCode == 200) {
        final transactionsData = response.data['transactions'] as List<dynamic>;
        return transactionsData
            .map(
              (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      throw ServerException();
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<void> topUpWallet({
    required double amount,
    required String method,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/wallet/topup',
        data: {'amount': amount, 'method': method},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }
      throw ServerException();
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await dio.get('$_baseUrl/wallet/payment-methods');

      if (response.statusCode == 200) {
        final methodsData = response.data['methods'] as List<dynamic>;
        return methodsData
            .map(
              (json) =>
                  PaymentMethodModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      throw ServerException();
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<void> addPaymentMethod(PaymentMethod method) async {
    try {
      final methodModel = PaymentMethodModel(
        id: method.id,
        type: method.type,
        lastFourDigits: method.lastFourDigits,
        cardBrand: method.cardBrand,
      );

      final response = await dio.post(
        '$_baseUrl/wallet/payment-methods',
        data: methodModel.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }
      throw ServerException();
    } on DioException {
      throw ServerException();
    }
  }
}
