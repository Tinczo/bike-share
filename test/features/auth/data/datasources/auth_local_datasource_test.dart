import 'dart:convert';

import 'package:bike_app/core/error/exceptions.dart';
import 'package:bike_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bike_app/features/auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    dataSource = AuthLocalDataSourceImpl(secureStorage: mockSecureStorage);
  });

  const tToken = 'test_token';
  const tUserModel = UserModel(id: '123', email: 'test@example.com');

  group('cacheToken', () {
    test('should call secure storage to cache the token', () async {
      // arrange
      when(
        () => mockSecureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      // act
      await dataSource.cacheToken(tToken);

      // assert
      verify(
        () => mockSecureStorage.write(key: 'CACHED_AUTH_TOKEN', value: tToken),
      ).called(1);
    });
  });

  group('getToken', () {
    test('should return token when there is one cached', () async {
      // arrange
      when(
        () => mockSecureStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => tToken);

      // act
      final result = await dataSource.getToken();

      // assert
      expect(result, tToken);
    });

    test('should return null when there is no cached token', () async {
      // arrange
      when(
        () => mockSecureStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      // act
      final result = await dataSource.getToken();

      // assert
      expect(result, null);
    });
  });

  group('clearToken', () {
    test('should call secure storage to delete the token', () async {
      // arrange
      when(
        () => mockSecureStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      // act
      await dataSource.clearToken();

      // assert
      verify(
        () => mockSecureStorage.delete(key: 'CACHED_AUTH_TOKEN'),
      ).called(1);
    });
  });

  group('cacheUser', () {
    test('should call secure storage to cache the user', () async {
      // arrange
      when(
        () => mockSecureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      // act
      await dataSource.cacheUser(tUserModel);

      // assert
      final expectedJsonString = json.encode(tUserModel.toJson());
      verify(
        () => mockSecureStorage.write(
          key: 'CACHED_USER',
          value: expectedJsonString,
        ),
      ).called(1);
    });
  });

  group('getCachedUser', () {
    test('should return UserModel when there is one cached', () async {
      // arrange
      when(
        () => mockSecureStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => json.encode(tUserModel.toJson()));

      // act
      final result = await dataSource.getCachedUser();

      // assert
      expect(result, tUserModel);
    });

    test('should throw CacheException when there is no cached user', () async {
      // arrange
      when(
        () => mockSecureStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      // act
      final call = dataSource.getCachedUser;

      // assert
      expect(call, throwsA(isA<CacheException>()));
    });
  });

  group('clearUser', () {
    test('should call secure storage to delete the user', () async {
      // arrange
      when(
        () => mockSecureStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      // act
      await dataSource.clearUser();

      // assert
      verify(() => mockSecureStorage.delete(key: 'CACHED_USER')).called(1);
    });
  });
}
