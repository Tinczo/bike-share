import 'package:bike_app/core/config/base_url_provider.dart';
import 'package:bike_app/core/error/exceptions.dart';
import 'package:bike_app/features/account/data/datasources/account_remote_datasource.dart';
import 'package:bike_app/features/account/data/models/fault_report_model.dart';
import 'package:bike_app/features/account/data/models/rental_history_item_model.dart';
import 'package:bike_app/features/account/domain/entities/fault_type.dart';
import 'package:bike_app/features/options/domain/entities/api_options.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockBaseUrlProvider extends Mock implements BaseUrlProvider {}

void main() {
  late AccountRemoteDataSourceImpl dataSource;
  late MockDio mockDio;
  late MockBaseUrlProvider mockBaseUrlProvider;

  setUp(() {
    mockDio = MockDio();
    mockBaseUrlProvider = MockBaseUrlProvider();
    when(() => mockBaseUrlProvider.getBaseUrlSync(DataSourceType.account))
        .thenReturn(defaultBaseUrl);
    dataSource = AccountRemoteDataSourceImpl(
      dio: mockDio,
      baseUrlProvider: mockBaseUrlProvider,
    );
  });

  group('getRentalHistory', () {
    final tRentalHistoryJson = [
      {
        'id': 'rental-1',
        'bikeId': 'bike-1',
        'startTime': '2024-01-15T10:00:00',
        'endTime': '2024-01-15T11:30:00',
        'cost': 4.5,
        'startStationName': 'Station A',
        'endStationName': 'Station B',
      },
      {
        'id': 'rental-2',
        'bikeId': 'bike-2',
        'startTime': '2024-01-14T08:00:00',
        'endTime': '2024-01-14T09:00:00',
        'cost': 3.0,
      },
    ];

    test('should return list of RentalHistoryItemModel when response is 200',
        () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {'rentals': tRentalHistoryJson},
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      // act
      final result = await dataSource.getRentalHistory();

      // assert
      expect(result, isA<List<RentalHistoryItemModel>>());
      expect(result.length, 2);
      expect(result[0].id, 'rental-1');
      expect(result[1].id, 'rental-2');
    });

    test('should return empty list when no rentals exist', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {'rentals': []},
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      // act
      final result = await dataSource.getRentalHistory();

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
        () => dataSource.getRentalHistory(),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException on DioException', () async {
      // arrange
      when(() => mockDio.get(any())).thenThrow(
        DioException(requestOptions: RequestOptions()),
      );

      // act & assert
      expect(
        () => dataSource.getRentalHistory(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getFaultReportHistory', () {
    final tFaultReportJson = [
      {
        'id': 'fault-1',
        'bikeId': 'bike-1',
        'userId': 'user-1',
        'type': 'FLAT_TIRE',
        'timestamp': '2024-01-15T10:00:00',
        'isVerified': true,
        'isConfirmed': true,
        'verificationDate': '2024-01-16T14:00:00',
        'rewardAmount': 5.0,
      },
      {
        'id': 'fault-2',
        'bikeId': 'bike-2',
        'userId': 'user-1',
        'type': 'BROKEN_CHAIN',
        'isVerified': false,
        'isConfirmed': false,
      },
    ];

    test('should return list of FaultReportModel when response is 200',
        () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {'faults': tFaultReportJson},
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      // act
      final result = await dataSource.getFaultReportHistory();

      // assert
      expect(result, isA<List<FaultReportModel>>());
      expect(result.length, 2);
      expect(result[0].id, 'fault-1');
      expect(result[0].type, FaultType.flatTire);
      expect(result[1].id, 'fault-2');
      expect(result[1].type, FaultType.brokenChain);
    });

    test('should return empty list when no fault reports exist', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {'faults': []},
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      // act
      final result = await dataSource.getFaultReportHistory();

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
        () => dataSource.getFaultReportHistory(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('reportFault', () {
    const tBikeId = 'bike-123';
    const tFaultType = FaultType.flatTire;
    const tDescription = 'Front tire is flat';

    final tFaultReportJson = {
      'id': 'fault-123',
      'bikeId': tBikeId,
      'userId': 'user-123',
      'type': 'PRZEBITA_OPONA',
      'description': tDescription,
      'timestamp': '2024-01-15T10:30:00',
      'isVerified': false,
      'isConfirmed': false,
    };

    test('should return FaultReportModel when response is 201', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: {'fault': tFaultReportJson},
          statusCode: 201,
          requestOptions: RequestOptions(),
        ),
      );

      // act
      final result = await dataSource.reportFault(
        bikeId: tBikeId,
        type: tFaultType,
        description: tDescription,
      );

      // assert
      expect(result, isA<FaultReportModel>());
      expect(result.id, 'fault-123');
      expect(result.bikeId, tBikeId);
      expect(result.type, FaultType.flatTire);
    });

    test('should send correct data to server', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: {'fault': tFaultReportJson},
          statusCode: 201,
          requestOptions: RequestOptions(),
        ),
      );

      // act
      await dataSource.reportFault(
        bikeId: tBikeId,
        type: tFaultType,
        description: tDescription,
      );

      // assert
      verify(
        () => mockDio.post(
          any(),
          data: {
            'bikeId': tBikeId,
            'type': 'PRZEBITA_OPONA',
            'description': tDescription,
          },
        ),
      ).called(1);
    });

    test('should handle null description', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: {'fault': tFaultReportJson},
          statusCode: 201,
          requestOptions: RequestOptions(),
        ),
      );

      // act
      await dataSource.reportFault(bikeId: tBikeId, type: tFaultType);

      // assert
      verify(
        () => mockDio.post(
          any(),
          data: {'bikeId': tBikeId, 'type': 'PRZEBITA_OPONA', 'description': null},
        ),
      ).called(1);
    });

    test('should throw ServerException when response is not 200/201', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 500,
          requestOptions: RequestOptions(),
        ),
      );

      // act & assert
      expect(
        () => dataSource.reportFault(bikeId: tBikeId, type: tFaultType),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException on DioException', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(requestOptions: RequestOptions()),
      );

      // act & assert
      expect(
        () => dataSource.reportFault(bikeId: tBikeId, type: tFaultType),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
