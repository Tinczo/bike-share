import 'package:bike_app/features/map/data/models/bike_model.dart';
import 'package:bike_app/features/map/data/models/cached_map_data.dart';
import 'package:bike_app/features/map/data/models/location_model.dart';
import 'package:bike_app/features/map/data/models/station_model.dart';
import 'package:bike_app/features/map/domain/entities/bike_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CachedBikesData', () {
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

    test('isExpired should return false when cache is within TTL', () {
      // arrange
      final cachedData = CachedBikesData(
        bikes: tBikes,
        cachedAt: DateTime.now(),
      );

      // act
      final result = cachedData.isExpired(const Duration(minutes: 3));

      // assert
      expect(result, false);
    });

    test('isExpired should return true when cache is older than TTL', () {
      // arrange
      final cachedData = CachedBikesData(
        bikes: tBikes,
        cachedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      // act
      final result = cachedData.isExpired(const Duration(minutes: 3));

      // assert
      expect(result, true);
    });

    test('fromJson should correctly parse JSON data', () {
      // arrange - use backend format field names as expected by BikeModel
      final json = {
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
        ],
        'cachedAt': '2024-01-01T12:00:00.000Z',
      };

      // act
      final result = CachedBikesData.fromJson(json);

      // assert
      expect(result.bikes.length, 1);
      expect(result.bikes.first.id, '1');
      expect(result.cachedAt, DateTime.utc(2024, 1, 1, 12, 0, 0));
    });

    test('toJson should correctly serialize to JSON', () {
      // arrange
      final cachedData = CachedBikesData(
        bikes: tBikes,
        cachedAt: DateTime.utc(2024, 1, 1, 12, 0, 0),
      );

      // act
      final result = cachedData.toJson();

      // assert
      expect(result['bikes'], isA<List>());
      expect((result['bikes'] as List).length, 1);
      expect(result['cachedAt'], '2024-01-01T12:00:00.000Z');
    });
  });

  group('CachedStationsData', () {
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

    test('isExpired should return false when cache is within TTL', () {
      // arrange
      final cachedData = CachedStationsData(
        stations: tStations,
        cachedAt: DateTime.now(),
      );

      // act
      final result = cachedData.isExpired(const Duration(minutes: 10));

      // assert
      expect(result, false);
    });

    test('isExpired should return true when cache is older than TTL', () {
      // arrange
      final cachedData = CachedStationsData(
        stations: tStations,
        cachedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      );

      // act
      final result = cachedData.isExpired(const Duration(minutes: 10));

      // assert
      expect(result, true);
    });

    test('fromJson should correctly parse JSON data', () {
      // arrange - use backend format field names as expected by StationModel
      final json = {
        'stations': [
          {
            'id_stacji': '1',
            'nazwa': 'Station 1',
            'lokalizacja_szerokosc': 51.1100,
            'lokalizacja_dlugosc': 17.0300,
            'pojemnosc': 20,
            'dostepne_rowery': 12,
            'dostepne_stojaki': 8,
          },
        ],
        'cachedAt': '2024-01-01T12:00:00.000Z',
      };

      // act
      final result = CachedStationsData.fromJson(json);

      // assert
      expect(result.stations.length, 1);
      expect(result.stations.first.id, '1');
      expect(result.cachedAt, DateTime.utc(2024, 1, 1, 12, 0, 0));
    });

    test('toJson should correctly serialize to JSON', () {
      // arrange
      final cachedData = CachedStationsData(
        stations: tStations,
        cachedAt: DateTime.utc(2024, 1, 1, 12, 0, 0),
      );

      // act
      final result = cachedData.toJson();

      // assert
      expect(result['stations'], isA<List>());
      expect((result['stations'] as List).length, 1);
      expect(result['cachedAt'], '2024-01-01T12:00:00.000Z');
    });
  });
}
