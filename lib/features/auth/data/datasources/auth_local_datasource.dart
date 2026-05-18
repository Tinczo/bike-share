import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Keys for secure storage.
const cachedAuthToken = 'CACHED_AUTH_TOKEN';
const cachedUser = 'CACHED_USER';

/// Local data source for authentication data.
abstract class AuthLocalDataSource {
  /// Caches the authentication token.
  Future<void> cacheToken(String token);

  /// Returns the cached authentication token, or null if not found.
  Future<String?> getToken();

  /// Clears the cached authentication token.
  Future<void> clearToken();

  /// Caches the user data.
  Future<void> cacheUser(UserModel user);

  /// Returns the cached user.
  ///
  /// Throws [CacheException] if no user is cached.
  Future<UserModel> getCachedUser();

  /// Clears the cached user data.
  Future<void> clearUser();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheToken(String token) async {
    await secureStorage.write(key: cachedAuthToken, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: cachedAuthToken);
  }

  @override
  Future<void> clearToken() async {
    await secureStorage.delete(key: cachedAuthToken);
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final jsonString = json.encode(user.toJson());
    await secureStorage.write(key: cachedUser, value: jsonString);
  }

  @override
  Future<UserModel> getCachedUser() async {
    final jsonString = await secureStorage.read(key: cachedUser);
    if (jsonString == null) {
      throw CacheException();
    }
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return UserModel.fromJson(jsonMap);
  }

  @override
  Future<void> clearUser() async {
    await secureStorage.delete(key: cachedUser);
  }
}
