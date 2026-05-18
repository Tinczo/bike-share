import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/config/base_url_provider.dart';
import '../../../../core/error/exceptions.dart';
import '../../../options/domain/entities/api_options.dart';
import '../models/user_model.dart';

/// Remote data source for authentication operations.
abstract class AuthRemoteDataSource {
  /// Authenticates a user with email and password.
  ///
  /// Throws [InvalidCredentialsException] if credentials are invalid.
  /// Throws [ServerException] on server error.
  Future<UserModel> login({required String email, required String password});

  /// Registers a new user with email and password.
  ///
  /// Throws [EmailAlreadyInUseException] if email is already registered.
  /// Throws [ServerException] on server error.
  Future<UserModel> register({required String email, required String password});
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final BaseUrlProvider baseUrlProvider;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrlProvider,
  });

  String get _baseUrl => baseUrlProvider.getBaseUrlSync(DataSourceType.auth);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'] as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      }
      throw ServerException();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw InvalidCredentialsException();
      }
      throw ServerException();
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/auth/register',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = response.data['user'] as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      }
      throw ServerException();
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw EmailAlreadyInUseException();
      }
      throw ServerException();
    }
  }
}
