import 'package:bike_app/features/rental/data/models/rental_model.dart';
import 'package:bike_app/features/rental/domain/entities/rental.dart';
import 'package:bike_app/features/rental/domain/entities/rental_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tStartTime = DateTime(2024, 1, 15, 10, 0);
  final tEndTime = DateTime(2024, 1, 15, 11, 30);

  final tRentalModel = RentalModel(
    id: 'rental-123',
    bikeId: 'bike-456',
    userId: 'user-789',
    startTime: tStartTime,
    endTime: tEndTime,
    cost: 15.50,
    status: RentalStatus.finished,
  );

  test('should be a subclass of Rental entity', () {
    expect(tRentalModel, isA<Rental>());
  });

  group('fromJson', () {
    test('should return a valid model from Polish backend format', () {
      // arrange
      final json = {
        'id_wypozyczenia': 'rental-123',
        'id_roweru': 'bike-456',
        'id_uzytkownika': 'user-789',
        'czas_rozpoczecia': '2024-01-15T10:00:00.000',
        'czas_zakonczenia': '2024-01-15T11:30:00.000',
        'koszt': 15.50,
        'status': 'ZAKONCZONE',
      };

      // act
      final result = RentalModel.fromJson(json);

      // assert
      expect(result, tRentalModel);
    });

    test('should return a valid model from English format', () {
      // arrange
      final json = {
        'id': 'rental-123',
        'bikeId': 'bike-456',
        'userId': 'user-789',
        'startTime': '2024-01-15T10:00:00.000',
        'endTime': '2024-01-15T11:30:00.000',
        'cost': 15.50,
        'status': 'FINISHED',
      };

      // act
      final result = RentalModel.fromJson(json);

      // assert
      expect(result, tRentalModel);
    });

    test('should parse ACTIVE status correctly', () {
      // arrange
      final json = {
        'id': 'rental-123',
        'bikeId': 'bike-456',
        'userId': 'user-789',
        'startTime': '2024-01-15T10:00:00.000',
        'cost': 5.0,
        'status': 'ACTIVE',
      };

      // act
      final result = RentalModel.fromJson(json);

      // assert
      expect(result.status, RentalStatus.active);
    });

    test('should parse PAUSED status correctly', () {
      // arrange
      final json = {
        'id': 'rental-123',
        'bikeId': 'bike-456',
        'userId': 'user-789',
        'startTime': '2024-01-15T10:00:00.000',
        'cost': 5.0,
        'status': 'WSTRZYMANE',
      };

      // act
      final result = RentalModel.fromJson(json);

      // assert
      expect(result.status, RentalStatus.paused);
    });

    test('should handle null endTime', () {
      // arrange
      final json = {
        'id': 'rental-123',
        'bikeId': 'bike-456',
        'userId': 'user-789',
        'startTime': '2024-01-15T10:00:00.000',
        'cost': 5.0,
        'status': 'ACTIVE',
      };

      // act
      final result = RentalModel.fromJson(json);

      // assert
      expect(result.endTime, isNull);
    });

    test('should handle integer cost', () {
      // arrange
      final json = {
        'id': 'rental-123',
        'bikeId': 'bike-456',
        'userId': 'user-789',
        'startTime': '2024-01-15T10:00:00.000',
        'cost': 15,
        'status': 'ACTIVE',
      };

      // act
      final result = RentalModel.fromJson(json);

      // assert
      expect(result.cost, 15.0);
    });
  });

  group('toJson', () {
    test('should return a JSON map with proper values', () {
      // act
      final result = tRentalModel.toJson();

      // assert
      expect(result, {
        'id': 'rental-123',
        'bikeId': 'bike-456',
        'userId': 'user-789',
        'startTime': '2024-01-15T10:00:00.000',
        'endTime': '2024-01-15T11:30:00.000',
        'cost': 15.50,
        'status': 'FINISHED',
      });
    });

    test('should handle null endTime', () {
      // arrange
      final model = RentalModel(
        id: 'rental-123',
        bikeId: 'bike-456',
        userId: 'user-789',
        startTime: tStartTime,
        cost: 5.0,
        status: RentalStatus.active,
      );

      // act
      final result = model.toJson();

      // assert
      expect(result['endTime'], isNull);
    });
  });

  group('fromEntity', () {
    test('should create a RentalModel from a Rental entity', () {
      // arrange
      final entity = Rental(
        id: 'rental-123',
        bikeId: 'bike-456',
        userId: 'user-789',
        startTime: tStartTime,
        endTime: tEndTime,
        cost: 15.50,
        status: RentalStatus.finished,
      );

      // act
      final result = RentalModel.fromEntity(entity);

      // assert
      expect(result, tRentalModel);
    });
  });
}
