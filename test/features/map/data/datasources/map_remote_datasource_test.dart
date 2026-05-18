import 'package:bike_app/core/config/base_url_provider.dart';
import 'package:bike_app/core/error/exceptions.dart';
import 'package:bike_app/features/map/data/datasources/map_remote_datasource.dart';
import 'package:bike_app/features/map/data/models/bike_model.dart';
import 'package:bike_app/features/map/data/models/location_model.dart';
import 'package:bike_app/features/map/data/models/station_model.dart';
import 'package:bike_app/features/map/domain/entities/bike_status.dart';
import 'package:bike_app/features/options/domain/entities/api_options.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockBaseUrlProvider extends Mock implements BaseUrlProvider {}

void main() {
  late MapRemoteDataSourceImpl dataSource;
  late MockDio mockDio;
  late MockBaseUrlProvider mockBaseUrlProvider;

  setUp(() {
    mockDio = MockDio();
    mockBaseUrlProvider = MockBaseUrlProvider();
    when(() => mockBaseUrlProvider.getBaseUrlSync(DataSourceType.map))
        .thenReturn(defaultBaseUrl);
    dataSource = MapRemoteDataSourceImpl(
      dio: mockDio,
      baseUrlProvider: mockBaseUrlProvider,
    );
  });

  group('getNearbyBikes', () {
    const tLatitude = 51.1079;
    const tLongitude = 17.0385;
    const tRadiusKm = 5.0;

    final tBikesJson = {
      'bikes': [
        {
          'id_roweru': '1',
          'kod_qr': 'BIKE001',
          'status': 'AVAILABLE',
          'poziom_baterii': 85,
          'lokalizacja_szerokosc': 51.1080,
          'lokalizacja_dlugosc': 17.0390,
          'zasieg_km': 25,
        },
        {
          'id_roweru': '2',
          'kod_qr': 'BIKE002',
          'status': 'RENTED',
          'poziom_baterii': 60,
          'lokalizacja_szerokosc': 51.1075,
          'lokalizacja_dlugosc': 17.0380,
          'zasieg_km': 18,
        },
      ],
    };

    final tExpectedBikes = [
      const BikeModel(
        id: '1',
        qrCode: 'BIKE001',
        status: BikeStatus.available,
        batteryLevel: 85,
        location: LocationModel(latitude: 51.1080, longitude: 17.0390),
        rangeKm: 25,
      ),
      const BikeModel(
        id: '2',
        qrCode: 'BIKE002',
        status: BikeStatus.rented,
        batteryLevel: 60,
        location: LocationModel(latitude: 51.1075, longitude: 17.0380),
        rangeKm: 18,
      ),
    ];

    test(
      'should return list of BikeModel when the response code is 200',
      () async {
        // arrange
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: tBikesJson,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // act
        final result = await dataSource.getNearbyBikes(
          latitude: tLatitude,
          longitude: tLongitude,
          radiusKm: tRadiusKm,
        );

        // assert
        expect(result, tExpectedBikes);
        verify(
          () => mockDio.get(
            any(that: contains('/map/bikes')),
            queryParameters: {
              'lat': tLatitude,
              'lng': tLongitude,
              'radius': tRadiusKm,
            },
          ),
        ).called(1);
      },
    );

    test('should return empty list when response contains no bikes', () async {
      // arrange
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          data: {'bikes': <Map<String, dynamic>>[]},
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      // act
      final result = await dataSource.getNearbyBikes(
        latitude: tLatitude,
        longitude: tLongitude,
        radiusKm: tRadiusKm,
      );

      // assert
      expect(result, isEmpty);
    });

    test('should throw ServerException when response code is not 200', () {
      // arrange
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async =>
            Response(statusCode: 500, requestOptions: RequestOptions()),
      );

      // act
      final call = dataSource.getNearbyBikes(
        latitude: tLatitude,
        longitude: tLongitude,
        radiusKm: tRadiusKm,
      );

      // assert
      expect(call, throwsA(isA<ServerException>()));
    });

    test('should throw ServerException when DioException occurs', () {
      // arrange
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(DioException(requestOptions: RequestOptions()));

      // act
      final call = dataSource.getNearbyBikes(
        latitude: tLatitude,
        longitude: tLongitude,
        radiusKm: tRadiusKm,
      );

      // assert
      expect(call, throwsA(isA<ServerException>()));
    });
  });

  group('getStations', () {
    final tStationsJson = {
      'stations': [
        {
          'id_stacji': '1',
          'nazwa': 'Rynek Główny',
          'lokalizacja_szerokosc': 51.1100,
          'lokalizacja_dlugosc': 17.0300,
          'pojemnosc': 20,
          'dostepne_rowery': 12,
          'dostepne_stojaki': 8,
        },
        {
          'id_stacji': '2',
          'nazwa': 'Dworzec Główny',
          'lokalizacja_szerokosc': 51.0990,
          'lokalizacja_dlugosc': 17.0350,
          'pojemnosc': 30,
          'dostepne_rowery': 18,
          'dostepne_stojaki': 12,
        },
      ],
    };

    final tExpectedStations = [
      const StationModel(
        id: '1',
        name: 'Rynek Główny',
        location: LocationModel(latitude: 51.1100, longitude: 17.0300),
        capacity: 20,
        availableBikes: 12,
        availableStands: 8,
      ),
      const StationModel(
        id: '2',
        name: 'Dworzec Główny',
        location: LocationModel(latitude: 51.0990, longitude: 17.0350),
        capacity: 30,
        availableBikes: 18,
        availableStands: 12,
      ),
    ];

    test(
      'should return list of StationModel when the response code is 200',
      () async {
        // arrange
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: tStationsJson,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // act
        final result = await dataSource.getStations();

        // assert
        expect(result, tExpectedStations);
        verify(
          () => mockDio.get(any(that: contains('/map/stations'))),
        ).called(1);
      },
    );

    test(
      'should return empty list when response contains no stations',
      () async {
        // arrange
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: {'stations': <Map<String, dynamic>>[]},
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        // act
        final result = await dataSource.getStations();

        // assert
        expect(result, isEmpty);
      },
    );

    test('should throw ServerException when response code is not 200', () {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async =>
            Response(statusCode: 500, requestOptions: RequestOptions()),
      );

      // act
      final call = dataSource.getStations();

      // assert
      expect(call, throwsA(isA<ServerException>()));
    });

    test('should throw ServerException when DioException occurs', () {
      // arrange
      when(
        () => mockDio.get(any()),
      ).thenThrow(DioException(requestOptions: RequestOptions()));

      // act
      final call = dataSource.getStations();

      // assert
      expect(call, throwsA(isA<ServerException>()));
    });
  });
}
