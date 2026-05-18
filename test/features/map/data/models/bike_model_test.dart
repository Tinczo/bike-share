import 'dart:convert';

import 'package:bike_app/features/map/data/models/bike_model.dart';
import 'package:bike_app/features/map/data/models/location_model.dart';
import 'package:bike_app/features/map/domain/entities/bike.dart';
import 'package:bike_app/features/map/domain/entities/bike_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tLocation = LocationModel(latitude: 51.1079, longitude: 17.0385);
  const tBikeModel = BikeModel(
    id: '1',
    qrCode: 'BIKE001',
    status: BikeStatus.available,
    batteryLevel: 85,
    location: tLocation,
    rangeKm: 25,
  );

  test('should be a subclass of Bike entity', () {
    expect(tBikeModel, isA<Bike>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON with backend field names', () {
      // arrange
      final jsonMap = {
        'id_roweru': '1',
        'kod_qr': 'BIKE001',
        'status': 'AVAILABLE',
        'poziom_baterii': 85,
        'lokalizacja_szerokosc': 51.1079,
        'lokalizacja_dlugosc': 17.0385,
        'zasieg_km': 25,
      };

      // act
      final result = BikeModel.fromJson(jsonMap);

      // assert
      expect(result, tBikeModel);
    });

    test('should handle all bike statuses correctly', () {
      const statusMap = {
        'AVAILABLE': BikeStatus.available,
        'RENTED': BikeStatus.rented,
        'RESERVED': BikeStatus.reserved,
        'BROKEN': BikeStatus.broken,
      };

      for (final entry in statusMap.entries) {
        final jsonMap = {
          'id_roweru': '1',
          'kod_qr': 'BIKE001',
          'status': entry.key,
          'lokalizacja_szerokosc': 51.1079,
          'lokalizacja_dlugosc': 17.0385,
        };

        final result = BikeModel.fromJson(jsonMap);
        expect(result.status, entry.value);
      }
    });

    test('should handle nullable fields', () {
      // arrange
      final jsonMap = {
        'id_roweru': '1',
        'kod_qr': 'BIKE001',
        'status': 'AVAILABLE',
        'lokalizacja_szerokosc': 51.1079,
        'lokalizacja_dlugosc': 17.0385,
      };

      // act
      final result = BikeModel.fromJson(jsonMap);

      // assert
      expect(result.batteryLevel, isNull);
      expect(result.rangeKm, isNull);
    });

    test('should handle alternative id field name', () {
      // arrange
      final jsonMap = {
        'id': '1',
        'kod_qr': 'BIKE001',
        'status': 'AVAILABLE',
        'lokalizacja_szerokosc': 51.1079,
        'lokalizacja_dlugosc': 17.0385,
      };

      // act
      final result = BikeModel.fromJson(jsonMap);

      // assert
      expect(result.id, '1');
    });

    test('should default to available status when status is unknown', () {
      // arrange
      final jsonMap = {
        'id_roweru': '1',
        'kod_qr': 'BIKE001',
        'status': 'UNKNOWN_STATUS',
        'lokalizacja_szerokosc': 51.1079,
        'lokalizacja_dlugosc': 17.0385,
      };

      // act
      final result = BikeModel.fromJson(jsonMap);

      // assert
      expect(result.status, BikeStatus.available);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      // act
      final result = tBikeModel.toJson();

      // assert
      expect(result['id'], '1');
      expect(result['qrCode'], 'BIKE001');
      expect(result['status'], 'available');
      expect(result['batteryLevel'], 85);
      expect(result['location'], isA<Map<String, dynamic>>());
      expect(result['rangeKm'], 25);
    });
  });

  group('JSON string conversion', () {
    test('should correctly deserialize from JSON string', () {
      // arrange
      const jsonString = '''
        {
          "id_roweru": "1",
          "kod_qr": "BIKE001",
          "status": "AVAILABLE",
          "poziom_baterii": 85,
          "lokalizacja_szerokosc": 51.1079,
          "lokalizacja_dlugosc": 17.0385,
          "zasieg_km": 25
        }
      ''';

      // act
      final result = BikeModel.fromJson(
        json.decode(jsonString) as Map<String, dynamic>,
      );

      // assert
      expect(result, tBikeModel);
    });
  });

  group('locationModel getter', () {
    test('should return LocationModel from location', () {
      // act
      final result = tBikeModel.locationModel;

      // assert
      expect(result, isA<LocationModel>());
      expect(result.latitude, tLocation.latitude);
      expect(result.longitude, tLocation.longitude);
    });
  });
}
