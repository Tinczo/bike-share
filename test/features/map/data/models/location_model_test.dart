import 'dart:convert';

import 'package:bike_app/features/map/data/models/location_model.dart';
import 'package:bike_app/features/map/domain/entities/location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tLocationModel = LocationModel(latitude: 51.1079, longitude: 17.0385);

  test('should be a subclass of Location entity', () {
    expect(tLocationModel, isA<Location>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON with backend field names', () {
      // arrange
      final jsonMap = {
        'lokalizacja_szerokosc': 51.1079,
        'lokalizacja_dlugosc': 17.0385,
      };

      // act
      final result = LocationModel.fromJson(jsonMap);

      // assert
      expect(result, tLocationModel);
    });

    test(
      'should return a valid model from JSON with alternative field names',
      () {
        // arrange
        final jsonMap = {'szer_geo': 51.1079, 'dl_geo': 17.0385};

        // act
        final result = LocationModel.fromJson(jsonMap);

        // assert
        expect(result, tLocationModel);
      },
    );

    test('should return a valid model from JSON with standard field names', () {
      // arrange
      final jsonMap = {'latitude': 51.1079, 'longitude': 17.0385};

      // act
      final result = LocationModel.fromJson(jsonMap);

      // assert
      expect(result, tLocationModel);
    });

    test('should handle integer values by converting to double', () {
      // arrange
      final jsonMap = {'latitude': 51, 'longitude': 17};

      // act
      final result = LocationModel.fromJson(jsonMap);

      // assert
      expect(result.latitude, 51.0);
      expect(result.longitude, 17.0);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      // act
      final result = tLocationModel.toJson();

      // assert
      final expectedMap = {'latitude': 51.1079, 'longitude': 17.0385};
      expect(result, expectedMap);
    });
  });

  group('JSON string conversion', () {
    test('should correctly deserialize from JSON string', () {
      // arrange
      const jsonString =
          '{"lokalizacja_szerokosc":51.1079,"lokalizacja_dlugosc":17.0385}';

      // act
      final result = LocationModel.fromJson(
        json.decode(jsonString) as Map<String, dynamic>,
      );

      // assert
      expect(result, tLocationModel);
    });

    test('should correctly serialize to JSON string', () {
      // act
      final jsonString = json.encode(tLocationModel.toJson());

      // assert
      expect(jsonString, contains('"latitude":51.1079'));
      expect(jsonString, contains('"longitude":17.0385'));
    });
  });
}
