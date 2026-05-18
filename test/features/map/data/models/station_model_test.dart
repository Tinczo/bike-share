import 'dart:convert';

import 'package:bike_app/features/map/data/models/location_model.dart';
import 'package:bike_app/features/map/data/models/station_model.dart';
import 'package:bike_app/features/map/domain/entities/station.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tLocation = LocationModel(latitude: 51.1100, longitude: 17.0300);
  const tStationModel = StationModel(
    id: '1',
    name: 'Rynek Główny',
    location: tLocation,
    capacity: 20,
    availableBikes: 12,
    availableStands: 8,
  );

  test('should be a subclass of Station entity', () {
    expect(tStationModel, isA<Station>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON with backend field names', () {
      // arrange
      final jsonMap = {
        'id_stacji': '1',
        'nazwa': 'Rynek Główny',
        'lokalizacja_szerokosc': 51.1100,
        'lokalizacja_dlugosc': 17.0300,
        'pojemnosc': 20,
        'dostepne_rowery': 12,
        'dostepne_stojaki': 8,
      };

      // act
      final result = StationModel.fromJson(jsonMap);

      // assert
      expect(result, tStationModel);
    });

    test('should handle alternative id field name', () {
      // arrange
      final jsonMap = {
        'id': '1',
        'nazwa': 'Rynek Główny',
        'lokalizacja_szerokosc': 51.1100,
        'lokalizacja_dlugosc': 17.0300,
        'pojemnosc': 20,
        'dostepne_rowery': 12,
        'dostepne_stojaki': 8,
      };

      // act
      final result = StationModel.fromJson(jsonMap);

      // assert
      expect(result.id, '1');
    });

    test('should handle alternative name field', () {
      // arrange
      final jsonMap = {
        'id_stacji': '1',
        'name': 'Rynek Główny',
        'lokalizacja_szerokosc': 51.1100,
        'lokalizacja_dlugosc': 17.0300,
        'pojemnosc': 20,
        'dostepne_rowery': 12,
        'dostepne_stojaki': 8,
      };

      // act
      final result = StationModel.fromJson(jsonMap);

      // assert
      expect(result.name, 'Rynek Główny');
    });

    test('should handle alternative capacity field names', () {
      // arrange
      final jsonMap = {
        'id_stacji': '1',
        'nazwa': 'Rynek Główny',
        'lokalizacja_szerokosc': 51.1100,
        'lokalizacja_dlugosc': 17.0300,
        'capacity': 20,
        'availableBikes': 12,
        'availableStands': 8,
      };

      // act
      final result = StationModel.fromJson(jsonMap);

      // assert
      expect(result.capacity, 20);
      expect(result.availableBikes, 12);
      expect(result.availableStands, 8);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      // act
      final result = tStationModel.toJson();

      // assert
      expect(result['id'], '1');
      expect(result['name'], 'Rynek Główny');
      expect(result['location'], isA<Map<String, dynamic>>());
      expect(result['capacity'], 20);
      expect(result['availableBikes'], 12);
      expect(result['availableStands'], 8);
    });
  });

  group('JSON string conversion', () {
    test('should correctly deserialize from JSON string', () {
      // arrange
      const jsonString = '''
        {
          "id_stacji": "1",
          "nazwa": "Rynek Główny",
          "lokalizacja_szerokosc": 51.1100,
          "lokalizacja_dlugosc": 17.0300,
          "pojemnosc": 20,
          "dostepne_rowery": 12,
          "dostepne_stojaki": 8
        }
      ''';

      // act
      final result = StationModel.fromJson(
        json.decode(jsonString) as Map<String, dynamic>,
      );

      // assert
      expect(result, tStationModel);
    });

    test('should correctly serialize to JSON string', () {
      // act
      final jsonString = json.encode(tStationModel.toJson());

      // assert
      expect(jsonString, contains('"id":"1"'));
      expect(jsonString, contains('"name":"Rynek Główny"'));
    });
  });

  group('locationModel getter', () {
    test('should return LocationModel from location', () {
      // act
      final result = tStationModel.locationModel;

      // assert
      expect(result, isA<LocationModel>());
      expect(result.latitude, tLocation.latitude);
      expect(result.longitude, tLocation.longitude);
    });
  });
}
