import 'package:bike_app/core/config/base_url_provider.dart';
import 'package:bike_app/core/error/exceptions.dart';
import 'package:bike_app/features/options/domain/entities/api_options.dart';
import 'package:bike_app/features/rental/data/datasources/rental_remote_datasource.dart';
import 'package:bike_app/features/rental/data/models/rental_eligibility_model.dart';
import 'package:bike_app/features/rental/data/models/rental_model.dart';
import 'package:bike_app/features/rental/data/models/reservation_model.dart';
import 'package:bike_app/features/rental/domain/entities/rental_launch_method.dart';
import 'package:bike_app/features/rental/domain/entities/rental_status.dart';
import 'package:bike_app/features/rental/domain/entities/reservation_status.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockBaseUrlProvider extends Mock implements BaseUrlProvider {}

void main() {
  late RentalRemoteDataSourceImpl dataSource;
  late MockDio mockDio;
  late MockBaseUrlProvider mockBaseUrlProvider;

  setUp(() {
    mockDio = MockDio();
    mockBaseUrlProvider = MockBaseUrlProvider();
    when(() => mockBaseUrlProvider.getBaseUrlSync(DataSourceType.rental))
        .thenReturn(defaultBaseUrl);
    dataSource = RentalRemoteDataSourceImpl(
      dio: mockDio,
      baseUrlProvider: mockBaseUrlProvider,
    );
  });

  const baseUrl = defaultBaseUrl;

  group('checkEligibility', () {
    final tEligibilityJson = {
      'eligibility': {
        'isEligible': true,
        'hasMinimumBalance': true,
        'hasLinkedCard': true,
        'hasActiveSubscription': false,
        'isDebtor': false,
      },
    };

    test('should return RentalEligibilityModel when response is 200', () async {
      // Arrange
      when(() => mockDio.get('$baseUrl/rental/eligibility')).thenAnswer(
        (_) async => Response(
          data: tEligibilityJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      final result = await dataSource.checkEligibility();

      // Assert
      expect(result, isA<RentalEligibilityModel>());
      expect(result.isEligible, true);
      verify(() => mockDio.get('$baseUrl/rental/eligibility')).called(1);
    });

    test('should throw ServerException when response is not 200', () async {
      // Arrange
      when(() => mockDio.get('$baseUrl/rental/eligibility')).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 500,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.checkEligibility(),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException on DioException', () async {
      // Arrange
      when(
        () => mockDio.get('$baseUrl/rental/eligibility'),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      // Act & Assert
      expect(
        () => dataSource.checkEligibility(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('startRental', () {
    const tBikeId = 'bike_123';
    final tRentalJson = {
      'rental': {
        'id': 'rental_001',
        'bikeId': tBikeId,
        'userId': 'user_001',
        'status': 'ACTIVE',
        'startTime': '2024-01-15T10:00:00.000Z',
        'cost': 0.0,
      },
    };

    test('should return RentalModel when response is 201', () async {
      // Arrange
      when(
        () => mockDio.post('$baseUrl/rental/start', data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response(
          data: tRentalJson,
          statusCode: 201,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      final result = await dataSource.startRental(
        bikeId: tBikeId,
        method: RentalLaunchMethod.qr,
      );

      // Assert
      expect(result, isA<RentalModel>());
      expect(result.bikeId, tBikeId);
      expect(result.status, RentalStatus.active);
    });

    test('should throw PaymentRequiredException on 402', () async {
      // Arrange
      when(
        () => mockDio.post('$baseUrl/rental/start', data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 402,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.startRental(
          bikeId: tBikeId,
          method: RentalLaunchMethod.qr,
        ),
        throwsA(isA<PaymentRequiredException>()),
      );
    });

    test('should throw BikeUnavailableException on 409', () async {
      // Arrange
      when(
        () => mockDio.post('$baseUrl/rental/start', data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 409,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.startRental(
          bikeId: tBikeId,
          method: RentalLaunchMethod.manual,
        ),
        throwsA(isA<BikeUnavailableException>()),
      );
    });

    test('should throw IoTTimeoutException on 504', () async {
      // Arrange
      when(
        () => mockDio.post('$baseUrl/rental/start', data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 504,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.startRental(
          bikeId: tBikeId,
          method: RentalLaunchMethod.qr,
        ),
        throwsA(isA<IoTTimeoutException>()),
      );
    });

    test('should throw ServerException on other errors', () async {
      // Arrange
      when(
        () => mockDio.post('$baseUrl/rental/start', data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.startRental(
          bikeId: tBikeId,
          method: RentalLaunchMethod.qr,
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('pauseRental', () {
    const tRentalId = 'rental_001';
    final tRentalJson = {
      'rental': {
        'id': tRentalId,
        'bikeId': 'bike_123',
        'userId': 'user_001',
        'status': 'PAUSED',
        'startTime': '2024-01-15T10:00:00.000Z',
        'cost': 0.0,
      },
    };

    test('should return RentalModel with paused status', () async {
      // Arrange
      when(() => mockDio.post('$baseUrl/rental/$tRentalId/pause')).thenAnswer(
        (_) async => Response(
          data: tRentalJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      final result = await dataSource.pauseRental(rentalId: tRentalId);

      // Assert
      expect(result, isA<RentalModel>());
      expect(result.status, RentalStatus.paused);
    });

    test('should throw ServerException on error', () async {
      // Arrange
      when(
        () => mockDio.post('$baseUrl/rental/$tRentalId/pause'),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      // Act & Assert
      expect(
        () => dataSource.pauseRental(rentalId: tRentalId),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('endRental', () {
    const tRentalId = 'rental_001';
    final tRentalJson = {
      'rental': {
        'id': tRentalId,
        'bikeId': 'bike_123',
        'userId': 'user_001',
        'status': 'FINISHED',
        'startTime': '2024-01-15T10:00:00.000Z',
        'endTime': '2024-01-15T11:00:00.000Z',
        'cost': 15.0,
      },
    };

    test('should return RentalModel with finished status and cost', () async {
      // Arrange
      when(() => mockDio.post('$baseUrl/rental/$tRentalId/end')).thenAnswer(
        (_) async => Response(
          data: tRentalJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      final result = await dataSource.endRental(rentalId: tRentalId);

      // Assert
      expect(result, isA<RentalModel>());
      expect(result.status, RentalStatus.finished);
      expect(result.cost, 15.0);
    });

    test('should throw ServerException on error', () async {
      // Arrange
      when(
        () => mockDio.post('$baseUrl/rental/$tRentalId/end'),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      // Act & Assert
      expect(
        () => dataSource.endRental(rentalId: tRentalId),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getActiveRental', () {
    final tRentalJson = {
      'rental': {
        'id': 'rental_001',
        'bikeId': 'bike_123',
        'userId': 'user_001',
        'status': 'ACTIVE',
        'startTime': '2024-01-15T10:00:00.000Z',
        'cost': 0.0,
      },
    };

    test('should return RentalModel when active rental exists', () async {
      // Arrange
      when(() => mockDio.get('$baseUrl/rental/active')).thenAnswer(
        (_) async => Response(
          data: tRentalJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      final result = await dataSource.getActiveRental();

      // Assert
      expect(result, isA<RentalModel>());
      expect(result!.status, RentalStatus.active);
    });

    test('should return null when no active rental (404)', () async {
      // Arrange
      when(() => mockDio.get('$baseUrl/rental/active')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      // Act
      final result = await dataSource.getActiveRental();

      // Assert
      expect(result, isNull);
    });

    test('should return null when rental data is null', () async {
      // Arrange
      when(() => mockDio.get('$baseUrl/rental/active')).thenAnswer(
        (_) async => Response(
          data: {'rental': null},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      final result = await dataSource.getActiveRental();

      // Assert
      expect(result, isNull);
    });

    test('should throw ServerException on other errors', () async {
      // Arrange
      when(() => mockDio.get('$baseUrl/rental/active')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.getActiveRental(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('createReservation', () {
    const tBikeId = 'bike_123';
    final tReservationJson = {
      'reservation': {
        'id': 'res_001',
        'bikeId': tBikeId,
        'userId': 'user_001',
        'status': 'ACTIVE',
        'createdAt': '2024-01-15T10:00:00.000Z',
        'expiresAt': '2024-01-15T10:15:00.000Z',
      },
    };

    test('should return ReservationModel when response is 201', () async {
      // Arrange
      when(
        () => mockDio.post(
          '$baseUrl/rental/reservation',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: tReservationJson,
          statusCode: 201,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      final result = await dataSource.createReservation(bikeId: tBikeId);

      // Assert
      expect(result, isA<ReservationModel>());
      expect(result.bikeId, tBikeId);
      expect(result.status, ReservationStatus.active);
    });

    test('should throw PaymentRequiredException on 402', () async {
      // Arrange
      when(
        () => mockDio.post(
          '$baseUrl/rental/reservation',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 402,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.createReservation(bikeId: tBikeId),
        throwsA(isA<PaymentRequiredException>()),
      );
    });

    test('should throw BikeUnavailableException on 409', () async {
      // Arrange
      when(
        () => mockDio.post(
          '$baseUrl/rental/reservation',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 409,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.createReservation(bikeId: tBikeId),
        throwsA(isA<BikeUnavailableException>()),
      );
    });
  });

  group('cancelReservation', () {
    const tReservationId = 'res_001';

    test('should complete successfully on 200', () async {
      // Arrange
      when(
        () => mockDio.delete('$baseUrl/rental/reservation/$tReservationId'),
      ).thenAnswer(
        (_) async =>
            Response(statusCode: 200, requestOptions: RequestOptions(path: '')),
      );

      // Act & Assert
      await expectLater(
        dataSource.cancelReservation(reservationId: tReservationId),
        completes,
      );
    });

    test('should complete successfully on 204', () async {
      // Arrange
      when(
        () => mockDio.delete('$baseUrl/rental/reservation/$tReservationId'),
      ).thenAnswer(
        (_) async =>
            Response(statusCode: 204, requestOptions: RequestOptions(path: '')),
      );

      // Act & Assert
      await expectLater(
        dataSource.cancelReservation(reservationId: tReservationId),
        completes,
      );
    });

    test('should throw ReservationExpiredException on 410', () async {
      // Arrange
      when(
        () => mockDio.delete('$baseUrl/rental/reservation/$tReservationId'),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 410,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.cancelReservation(reservationId: tReservationId),
        throwsA(isA<ReservationExpiredException>()),
      );
    });

    test('should throw ServerException on other errors', () async {
      // Arrange
      when(
        () => mockDio.delete('$baseUrl/rental/reservation/$tReservationId'),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.cancelReservation(reservationId: tReservationId),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getActiveReservation', () {
    final tReservationJson = {
      'reservation': {
        'id': 'res_001',
        'bikeId': 'bike_123',
        'userId': 'user_001',
        'status': 'ACTIVE',
        'createdAt': '2024-01-15T10:00:00.000Z',
        'expiresAt': '2024-01-15T10:15:00.000Z',
      },
    };

    test(
      'should return ReservationModel when active reservation exists',
      () async {
        // Arrange
        when(
          () => mockDio.get('$baseUrl/rental/reservation/active'),
        ).thenAnswer(
          (_) async => Response(
            data: tReservationJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final result = await dataSource.getActiveReservation();

        // Assert
        expect(result, isA<ReservationModel>());
        expect(result!.status, ReservationStatus.active);
      },
    );

    test('should return null when no active reservation (404)', () async {
      // Arrange
      when(() => mockDio.get('$baseUrl/rental/reservation/active')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      // Act
      final result = await dataSource.getActiveReservation();

      // Assert
      expect(result, isNull);
    });

    test('should return null when reservation data is null', () async {
      // Arrange
      when(() => mockDio.get('$baseUrl/rental/reservation/active')).thenAnswer(
        (_) async => Response(
          data: {'reservation': null},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      final result = await dataSource.getActiveReservation();

      // Assert
      expect(result, isNull);
    });

    test('should throw ServerException on other errors', () async {
      // Arrange
      when(() => mockDio.get('$baseUrl/rental/reservation/active')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.getActiveReservation(),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
