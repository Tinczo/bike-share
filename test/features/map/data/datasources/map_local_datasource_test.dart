import 'dart:convert';

import 'package:bike_app/core/error/exceptions.dart';
import 'package:bike_app/features/map/data/datasources/map_local_datasource.dart';
import 'package:bike_app/features/map/data/models/bike_model.dart';
import 'package:bike_app/features/map/data/models/cached_map_data.dart';
import 'package:bike_app/features/map/data/models/location_model.dart';
import 'package:bike_app/features/map/data/models/station_model.dart';
import 'package:bike_app/features/map/domain/entities/bike_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MapLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = MapLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('cacheBikes', () {
    const tBikes = [
      BikeModel(
        id: '1',
        qrCode: 'BIKE001',
        status: BikeStatus.available,
        batteryLevel: 85,
        location: LocationModel(latitude: 51.1080, longitude: 17.0390),
        rangeKm: 25,
      ),
    ];

    test('should call SharedPreferences to cache the bikes data', () async {
      // arrange
      when(
        () => mockSharedPreferences.setString(any(), any()),
      ).thenAnswer((_) async => true);

      // act
      await dataSource.cacheBikes(tBikes);

      // assert
      final jsonString =
          verify(
                () => mockSharedPreferences.setString(
                  cachedBikesKey,
                  captureAny(),
                ),
              ).captured.single
              as String;

      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(decoded['bikes'], isA<List>());
      expect((decoded['bikes'] as List).length, 1);
      expect(decoded['cachedAt'], isA<String>());
    });
  });

  group('getCachedBikes', () {
    const tBikes = [
      BikeModel(
        id: '1',
        qrCode: 'BIKE001',
        status: BikeStatus.available,
        batteryLevel: 85,
        location: LocationModel(latitude: 51.1080, longitude: 17.0390),
        rangeKm: 25,
      ),
    ];

    test(
      'should return List<BikeModel> when there is valid cached data',
      () async {
        // arrange
        final cachedData = CachedBikesData(
          bikes: tBikes,
          cachedAt: DateTime.now(),
        );
        when(
          () => mockSharedPreferences.getString(cachedBikesKey),
        ).thenReturn(jsonEncode(cachedData.toJson()));

        // act
        final result = await dataSource.getCachedBikes();

        // assert
        expect(result, tBikes);
      },
    );

    test('should throw CacheException when there is no cached data', () async {
      // arrange
      when(
        () => mockSharedPreferences.getString(cachedBikesKey),
      ).thenReturn(null);

      // act
      final call = dataSource.getCachedBikes;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('isBikesCacheValid', () {
    test('should return true when cache exists and is within TTL', () async {
      // arrange
      final cachedData = CachedBikesData(
        bikes: const [],
        cachedAt: DateTime.now(),
      );
      when(
        () => mockSharedPreferences.getString(cachedBikesKey),
      ).thenReturn(jsonEncode(cachedData.toJson()));

      // act
      final result = await dataSource.isBikesCacheValid();

      // assert
      expect(result, true);
    });

    test('should return false when cache exists but is expired', () async {
      // arrange
      final cachedData = CachedBikesData(
        bikes: const [],
        cachedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      when(
        () => mockSharedPreferences.getString(cachedBikesKey),
      ).thenReturn(jsonEncode(cachedData.toJson()));

      // act
      final result = await dataSource.isBikesCacheValid();

      // assert
      expect(result, false);
    });

    test('should return false when there is no cached data', () async {
      // arrange
      when(
        () => mockSharedPreferences.getString(cachedBikesKey),
      ).thenReturn(null);

      // act
      final result = await dataSource.isBikesCacheValid();

      // assert
      expect(result, false);
    });
  });

  group('cacheStations', () {
    const tStations = [
      StationModel(
        id: '1',
        name: 'Station 1',
        location: LocationModel(latitude: 51.1100, longitude: 17.0300),
        capacity: 20,
        availableBikes: 12,
        availableStands: 8,
      ),
    ];

    test('should call SharedPreferences to cache the stations data', () async {
      // arrange
      when(
        () => mockSharedPreferences.setString(any(), any()),
      ).thenAnswer((_) async => true);

      // act
      await dataSource.cacheStations(tStations);

      // assert
      final jsonString =
          verify(
                () => mockSharedPreferences.setString(
                  cachedStationsKey,
                  captureAny(),
                ),
              ).captured.single
              as String;

      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(decoded['stations'], isA<List>());
      expect((decoded['stations'] as List).length, 1);
      expect(decoded['cachedAt'], isA<String>());
    });
  });

  group('getCachedStations', () {
    const tStations = [
      StationModel(
        id: '1',
        name: 'Station 1',
        location: LocationModel(latitude: 51.1100, longitude: 17.0300),
        capacity: 20,
        availableBikes: 12,
        availableStands: 8,
      ),
    ];

    test(
      'should return List<StationModel> when there is valid cached data',
      () async {
        // arrange
        final cachedData = CachedStationsData(
          stations: tStations,
          cachedAt: DateTime.now(),
        );
        when(
          () => mockSharedPreferences.getString(cachedStationsKey),
        ).thenReturn(jsonEncode(cachedData.toJson()));

        // act
        final result = await dataSource.getCachedStations();

        // assert
        expect(result, tStations);
      },
    );

    test('should throw CacheException when there is no cached data', () async {
      // arrange
      when(
        () => mockSharedPreferences.getString(cachedStationsKey),
      ).thenReturn(null);

      // act
      final call = dataSource.getCachedStations;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('isStationsCacheValid', () {
    test('should return true when cache exists and is within TTL', () async {
      // arrange
      final cachedData = CachedStationsData(
        stations: const [],
        cachedAt: DateTime.now(),
      );
      when(
        () => mockSharedPreferences.getString(cachedStationsKey),
      ).thenReturn(jsonEncode(cachedData.toJson()));

      // act
      final result = await dataSource.isStationsCacheValid();

      // assert
      expect(result, true);
    });

    test('should return false when cache exists but is expired', () async {
      // arrange
      final cachedData = CachedStationsData(
        stations: const [],
        cachedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      );
      when(
        () => mockSharedPreferences.getString(cachedStationsKey),
      ).thenReturn(jsonEncode(cachedData.toJson()));

      // act
      final result = await dataSource.isStationsCacheValid();

      // assert
      expect(result, false);
    });

    test('should return false when there is no cached data', () async {
      // arrange
      when(
        () => mockSharedPreferences.getString(cachedStationsKey),
      ).thenReturn(null);

      // act
      final result = await dataSource.isStationsCacheValid();

      // assert
      expect(result, false);
    });
  });
}
