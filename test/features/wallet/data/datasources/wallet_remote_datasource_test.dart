import 'package:bike_app/core/config/base_url_provider.dart';
import 'package:bike_app/core/error/exceptions.dart';
import 'package:bike_app/features/options/domain/entities/api_options.dart';
import 'package:bike_app/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:bike_app/features/wallet/data/models/payment_method_model.dart';
import 'package:bike_app/features/wallet/data/models/transaction_model.dart';
import 'package:bike_app/features/wallet/data/models/wallet_model.dart';
import 'package:bike_app/features/wallet/domain/entities/payment_method.dart';
import 'package:bike_app/features/wallet/domain/entities/transaction.dart';
import 'package:bike_app/features/wallet/domain/entities/wallet.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockBaseUrlProvider extends Mock implements BaseUrlProvider {}

void main() {
  late WalletRemoteDataSourceImpl dataSource;
  late MockDio mockDio;
  late MockBaseUrlProvider mockBaseUrlProvider;

  setUp(() {
    mockDio = MockDio();
    mockBaseUrlProvider = MockBaseUrlProvider();
    when(
      () => mockBaseUrlProvider.getBaseUrlSync(DataSourceType.wallet),
    ).thenReturn(defaultBaseUrl);
    dataSource = WalletRemoteDataSourceImpl(
      dio: mockDio,
      baseUrlProvider: mockBaseUrlProvider,
    );
  });

  group('getWallet', () {
    final tWalletJson = {
      'wallet': {'saldo': 42.5, 'status': 'ACTIVE', 'ma_podpieta_karte': true},
    };

    const tExpectedWallet = WalletModel(
      balance: 42.5,
      status: WalletStatus.active,
      hasCard: true,
    );

    test('should return WalletModel when the response code is 200', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tWalletJson,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      // act
      final result = await dataSource.getWallet();

      // assert
      expect(result, tExpectedWallet);
      verify(() => mockDio.get(any(that: contains('/wallet'))));
    });

    test('should parse a wallet in debt with no card attached', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {
            'wallet': {
              'saldo': -12.0,
              'status': 'DEBT',
              'ma_podpieta_karte': false,
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      // act
      final result = await dataSource.getWallet();

      // assert
      expect(result.balance, -12.0);
      expect(result.status, WalletStatus.debt);
      expect(result.hasCard, false);
    });

    test('should throw ServerException when response is not 200', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 500,
          requestOptions: RequestOptions(),
        ),
      );

      // act & assert
      expect(() => dataSource.getWallet(), throwsA(isA<ServerException>()));
    });

    test('should throw ServerException on DioException', () async {
      // arrange
      when(
        () => mockDio.get(any()),
      ).thenThrow(DioException(requestOptions: RequestOptions()));

      // act & assert
      expect(() => dataSource.getWallet(), throwsA(isA<ServerException>()));
    });
  });

  group('getTransactions', () {
    final tTransactionsJson = {
      'transactions': [
        {
          'id_transakcji': 'tx-1',
          'kwota': 50.0,
          'typ': 'TOP_UP',
          'czas_rejestracji': '2026-01-15T10:00:00.000',
          'opis': 'Doładowanie konta',
        },
        {
          'id_transakcji': 'tx-2',
          'kwota': 7.5,
          'typ': 'FEE',
          'czas_rejestracji': '2026-01-16T14:30:00.000',
          'opis': 'Opłata za przejazd',
        },
      ],
    };

    final tExpectedTransactions = [
      TransactionModel(
        id: 'tx-1',
        amount: 50.0,
        type: TransactionType.topUp,
        date: DateTime.parse('2026-01-15T10:00:00.000'),
        description: 'Doładowanie konta',
      ),
      TransactionModel(
        id: 'tx-2',
        amount: 7.5,
        type: TransactionType.fee,
        date: DateTime.parse('2026-01-16T14:30:00.000'),
        description: 'Opłata za przejazd',
      ),
    ];

    test(
      'should return list of TransactionModel when the response code is 200',
      () async {
        // arrange
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: tTransactionsJson,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // act
        final result = await dataSource.getTransactions();

        // assert
        expect(result, tExpectedTransactions);
        verify(() => mockDio.get(any(that: contains('/wallet/transactions'))));
      },
    );

    test('should return an empty list when there are no transactions', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {'transactions': <dynamic>[]},
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      // act
      final result = await dataSource.getTransactions();

      // assert
      expect(result, isEmpty);
    });

    test('should throw ServerException when response is not 200', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 404,
          requestOptions: RequestOptions(),
        ),
      );

      // act & assert
      expect(
        () => dataSource.getTransactions(),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException on DioException', () async {
      // arrange
      when(
        () => mockDio.get(any()),
      ).thenThrow(DioException(requestOptions: RequestOptions()));

      // act & assert
      expect(
        () => dataSource.getTransactions(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('topUpWallet', () {
    const tAmount = 50.0;
    const tMethod = 'CARD';

    test('should complete normally when the response code is 200', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      // act
      await dataSource.topUpWallet(amount: tAmount, method: tMethod);

      // assert
      verify(
        () => mockDio.post(
          any(that: contains('/wallet/topup')),
          data: {'amount': tAmount, 'method': tMethod},
        ),
      );
    });

    test('should complete normally when the response code is 201', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 201,
          requestOptions: RequestOptions(),
        ),
      );

      // act & assert
      await expectLater(
        dataSource.topUpWallet(amount: tAmount, method: tMethod),
        completes,
      );
    });

    test('should throw ServerException when response is not 200/201', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 402,
          requestOptions: RequestOptions(),
        ),
      );

      // act & assert
      expect(
        () => dataSource.topUpWallet(amount: tAmount, method: tMethod),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException on DioException', () async {
      // arrange
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(DioException(requestOptions: RequestOptions()));

      // act & assert
      expect(
        () => dataSource.topUpWallet(amount: tAmount, method: tMethod),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getPaymentMethods', () {
    final tMethodsJson = {
      'methods': [
        {
          'id_metody': 'pm-1',
          'typ': 'CARD',
          'ostatnie_cztery': '4242',
          'marka_karty': 'Visa',
        },
        {'id_metody': 'pm-2', 'typ': 'BLIK'},
      ],
    };

    final tExpectedMethods = [
      const PaymentMethodModel(
        id: 'pm-1',
        type: PaymentMethodType.card,
        lastFourDigits: '4242',
        cardBrand: 'Visa',
      ),
      const PaymentMethodModel(id: 'pm-2', type: PaymentMethodType.blik),
    ];

    test(
      'should return list of PaymentMethodModel when the response code is 200',
      () async {
        // arrange
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: tMethodsJson,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // act
        final result = await dataSource.getPaymentMethods();

        // assert
        expect(result, tExpectedMethods);
        verify(
          () => mockDio.get(any(that: contains('/wallet/payment-methods'))),
        );
      },
    );

    test('should return an empty list when no methods are saved', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {'methods': <dynamic>[]},
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      // act
      final result = await dataSource.getPaymentMethods();

      // assert
      expect(result, isEmpty);
    });

    test('should throw ServerException when response is not 200', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 500,
          requestOptions: RequestOptions(),
        ),
      );

      // act & assert
      expect(
        () => dataSource.getPaymentMethods(),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException on DioException', () async {
      // arrange
      when(
        () => mockDio.get(any()),
      ).thenThrow(DioException(requestOptions: RequestOptions()));

      // act & assert
      expect(
        () => dataSource.getPaymentMethods(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('addPaymentMethod', () {
    const tPaymentMethod = PaymentMethod(
      id: 'pm-1',
      type: PaymentMethodType.card,
      lastFourDigits: '4242',
      cardBrand: 'Visa',
    );

    test('should complete normally when the response code is 201', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 201,
          requestOptions: RequestOptions(),
        ),
      );

      // act
      await dataSource.addPaymentMethod(tPaymentMethod);

      // assert
      verify(
        () => mockDio.post(
          any(that: contains('/wallet/payment-methods')),
          data: {
            'id': 'pm-1',
            'type': 'CARD',
            'lastFourDigits': '4242',
            'cardBrand': 'Visa',
          },
        ),
      );
    });

    test('should complete normally when the response code is 200', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      // act & assert
      await expectLater(
        dataSource.addPaymentMethod(tPaymentMethod),
        completes,
      );
    });

    test('should throw ServerException when response is not 200/201', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 400,
          requestOptions: RequestOptions(),
        ),
      );

      // act & assert
      expect(
        () => dataSource.addPaymentMethod(tPaymentMethod),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException on DioException', () async {
      // arrange
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(DioException(requestOptions: RequestOptions()));

      // act & assert
      expect(
        () => dataSource.addPaymentMethod(tPaymentMethod),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
