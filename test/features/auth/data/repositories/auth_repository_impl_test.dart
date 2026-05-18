import 'package:bike_app/core/error/exceptions.dart';
import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/network/network_info.dart';
import 'package:bike_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bike_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bike_app/features/auth/data/models/user_model.dart';
import 'package:bike_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  /// Sets up test fixtures before any tests in this suite run.
  ///
  /// Registers a fallback value for the [UserModel] type to be used by Mockito
  /// when creating mock objects. This ensures that any mock that returns a
  /// [UserModel] will have a default value available if no specific mock
  /// behavior is defined.
  ///
  /// The fallback [UserModel] instance uses:
  /// - id: '1'
  /// - email: 'test@test.com'
  setUpAll(() {
    registerFallbackValue(const UserModel(id: '1', email: 'test@test.com'));
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUserModel = UserModel(id: '123', email: tEmail);

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('login', () {
    runTestsOnline(() {
      test('should return remote data when login is successful '
          'and cache user', () async {
        // arrange
        when(
          () => mockRemoteDataSource.login(email: tEmail, password: tPassword),
        ).thenAnswer((_) async => tUserModel);
        when(
          () => mockLocalDataSource.cacheUser(any()),
        ).thenAnswer((_) async {});

        // act
        final result = await repository.login(
          email: tEmail,
          password: tPassword,
        );

        // assert
        verify(
          () => mockRemoteDataSource.login(email: tEmail, password: tPassword),
        ).called(1);
        verify(() => mockLocalDataSource.cacheUser(tUserModel)).called(1);
        expect(result, equals(const Right(tUserModel)));
      });

      test(
        'should return InvalidCredentialsFailure when credentials invalid',
        () async {
          // arrange
          when(
            () =>
                mockRemoteDataSource.login(email: tEmail, password: tPassword),
          ).thenThrow(InvalidCredentialsException());

          // act
          final result = await repository.login(
            email: tEmail,
            password: tPassword,
          );

          // assert
          verify(
            () =>
                mockRemoteDataSource.login(email: tEmail, password: tPassword),
          ).called(1);
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(InvalidCredentialsFailure())));
        },
      );

      test('should return ServerFailure when server error occurs', () async {
        // arrange
        when(
          () => mockRemoteDataSource.login(email: tEmail, password: tPassword),
        ).thenThrow(ServerException());

        // act
        final result = await repository.login(
          email: tEmail,
          password: tPassword,
        );

        // assert
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.login(
          email: tEmail,
          password: tPassword,
        );

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(Left(NetworkFailure())));
      });
    });
  });

  group('register', () {
    runTestsOnline(() {
      test('should return remote data when registration is successful '
          'and cache user', () async {
        // arrange
        when(
          () =>
              mockRemoteDataSource.register(email: tEmail, password: tPassword),
        ).thenAnswer((_) async => tUserModel);
        when(
          () => mockLocalDataSource.cacheUser(any()),
        ).thenAnswer((_) async {});

        // act
        final result = await repository.register(
          email: tEmail,
          password: tPassword,
        );

        // assert
        verify(
          () =>
              mockRemoteDataSource.register(email: tEmail, password: tPassword),
        ).called(1);
        verify(() => mockLocalDataSource.cacheUser(tUserModel)).called(1);
        expect(result, equals(const Right(tUserModel)));
      });

      test(
        'should return EmailAlreadyInUseFailure when email already in use',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.register(
              email: tEmail,
              password: tPassword,
            ),
          ).thenThrow(EmailAlreadyInUseException());

          // act
          final result = await repository.register(
            email: tEmail,
            password: tPassword,
          );

          // assert
          expect(result, equals(Left(EmailAlreadyInUseFailure())));
        },
      );

      test('should return ServerFailure when server error occurs', () async {
        // arrange
        when(
          () =>
              mockRemoteDataSource.register(email: tEmail, password: tPassword),
        ).thenThrow(ServerException());

        // act
        final result = await repository.register(
          email: tEmail,
          password: tPassword,
        );

        // assert
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.register(
          email: tEmail,
          password: tPassword,
        );

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(Left(NetworkFailure())));
      });
    });
  });

  group('logout', () {
    test('should clear cached user and token on logout', () async {
      // arrange
      when(() => mockLocalDataSource.clearUser()).thenAnswer((_) async {});
      when(() => mockLocalDataSource.clearToken()).thenAnswer((_) async {});

      // act
      final result = await repository.logout();

      // assert
      verify(() => mockLocalDataSource.clearUser()).called(1);
      verify(() => mockLocalDataSource.clearToken()).called(1);
      expect(result, equals(const Right(unit)));
    });

    test('should return CacheFailure when clearing cache fails', () async {
      // arrange
      when(() => mockLocalDataSource.clearUser()).thenThrow(CacheException());

      // act
      final result = await repository.logout();

      // assert
      expect(result, equals(Left(CacheFailure())));
    });
  });

  group('getCurrentUser', () {
    test('should return cached user when available', () async {
      // arrange
      when(
        () => mockLocalDataSource.getCachedUser(),
      ).thenAnswer((_) async => tUserModel);

      // act
      final result = await repository.getCurrentUser();

      // assert
      verify(() => mockLocalDataSource.getCachedUser()).called(1);
      expect(result, equals(const Right(tUserModel)));
    });

    test('should return null when no cached user', () async {
      // arrange
      when(
        () => mockLocalDataSource.getCachedUser(),
      ).thenThrow(CacheException());

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, equals(const Right(null)));
    });
  });
}
