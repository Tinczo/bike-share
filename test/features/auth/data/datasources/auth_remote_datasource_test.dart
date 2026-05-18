import 'package:bike_app/core/config/base_url_provider.dart';
import 'package:bike_app/core/error/exceptions.dart';
import 'package:bike_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bike_app/features/auth/data/models/user_model.dart';
import 'package:bike_app/features/options/domain/entities/api_options.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockBaseUrlProvider extends Mock implements BaseUrlProvider {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockDio mockDio;
  late MockBaseUrlProvider mockBaseUrlProvider;

  setUp(() {
    mockDio = MockDio();
    mockBaseUrlProvider = MockBaseUrlProvider();
    when(() => mockBaseUrlProvider.getBaseUrlSync(DataSourceType.auth))
        .thenReturn(defaultBaseUrl);
    dataSource = AuthRemoteDataSourceImpl(
      dio: mockDio,
      baseUrlProvider: mockBaseUrlProvider,
    );
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUserModel = UserModel(id: '123', email: tEmail);

  group('login', () {
    test('should return UserModel when login is successful (200)', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: {
            'user': {'id_uzytkownika': '123', 'email': tEmail},
            'token': 'test_token',
          },
        ),
      );

      // act
      final result = await dataSource.login(email: tEmail, password: tPassword);

      // assert
      expect(result, tUserModel);
    });

    test(
      'should throw InvalidCredentialsException when status is 401',
      () async {
        // arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 401,
            ),
          ),
        );

        // act
        final call = dataSource.login;

        // assert
        expect(
          () => call(email: tEmail, password: tPassword),
          throwsA(isA<InvalidCredentialsException>()),
        );
      },
    );

    test('should throw ServerException when other error occurs', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          response: Response(requestOptions: RequestOptions(), statusCode: 500),
        ),
      );

      // act
      final call = dataSource.login;

      // assert
      expect(
        () => call(email: tEmail, password: tPassword),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('register', () {
    test(
      'should return UserModel when registration is successful (201)',
      () async {
        // arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 201,
            data: {
              'user': {'id_uzytkownika': '123', 'email': tEmail},
              'token': 'test_token',
            },
          ),
        );

        // act
        final result = await dataSource.register(
          email: tEmail,
          password: tPassword,
        );

        // assert
        expect(result, tUserModel);
      },
    );

    test(
      'should throw EmailAlreadyInUseException when status is 409',
      () async {
        // arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 409,
            ),
          ),
        );

        // act
        final call = dataSource.register;

        // assert
        expect(
          () => call(email: tEmail, password: tPassword),
          throwsA(isA<EmailAlreadyInUseException>()),
        );
      },
    );

    test('should throw ServerException when other error occurs', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          response: Response(requestOptions: RequestOptions(), statusCode: 500),
        ),
      );

      // act
      final call = dataSource.register;

      // assert
      expect(
        () => call(email: tEmail, password: tPassword),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
