import 'package:bike_app/features/rental/data/models/reservation_model.dart';
import 'package:bike_app/features/rental/domain/entities/reservation.dart';
import 'package:bike_app/features/rental/domain/entities/reservation_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tCreatedAt = DateTime(2024, 1, 15, 10, 0);
  final tExpiresAt = DateTime(2024, 1, 15, 10, 15);

  final tReservationModel = ReservationModel(
    id: 'reservation-123',
    bikeId: 'bike-456',
    userId: 'user-789',
    createdAt: tCreatedAt,
    expiresAt: tExpiresAt,
    status: ReservationStatus.active,
  );

  test('should be a subclass of Reservation entity', () {
    expect(tReservationModel, isA<Reservation>());
  });

  group('fromJson', () {
    test('should return a valid model from Polish backend format', () {
      // arrange
      final json = {
        'id_rezerwacji': 'reservation-123',
        'id_roweru': 'bike-456',
        'id_uzytkownika': 'user-789',
        'czas_utworzenia': '2024-01-15T10:00:00.000',
        'czas_wygasniecia': '2024-01-15T10:15:00.000',
        'status': 'AKTYWNA',
      };

      // act
      final result = ReservationModel.fromJson(json);

      // assert
      expect(result, tReservationModel);
    });

    test('should return a valid model from English format', () {
      // arrange
      final json = {
        'id': 'reservation-123',
        'bikeId': 'bike-456',
        'userId': 'user-789',
        'createdAt': '2024-01-15T10:00:00.000',
        'expiresAt': '2024-01-15T10:15:00.000',
        'status': 'ACTIVE',
      };

      // act
      final result = ReservationModel.fromJson(json);

      // assert
      expect(result, tReservationModel);
    });

    test('should parse EXPIRED status correctly', () {
      // arrange
      final json = {
        'id': 'reservation-123',
        'bikeId': 'bike-456',
        'userId': 'user-789',
        'createdAt': '2024-01-15T10:00:00.000',
        'expiresAt': '2024-01-15T10:15:00.000',
        'status': 'WYGASLA',
      };

      // act
      final result = ReservationModel.fromJson(json);

      // assert
      expect(result.status, ReservationStatus.expired);
    });

    test('should parse CANCELLED status correctly', () {
      // arrange
      final json = {
        'id': 'reservation-123',
        'bikeId': 'bike-456',
        'userId': 'user-789',
        'createdAt': '2024-01-15T10:00:00.000',
        'expiresAt': '2024-01-15T10:15:00.000',
        'status': 'CANCELLED',
      };

      // act
      final result = ReservationModel.fromJson(json);

      // assert
      expect(result.status, ReservationStatus.cancelled);
    });

    test('should parse CONVERTED status correctly', () {
      // arrange
      final json = {
        'id': 'reservation-123',
        'bikeId': 'bike-456',
        'userId': 'user-789',
        'createdAt': '2024-01-15T10:00:00.000',
        'expiresAt': '2024-01-15T10:15:00.000',
        'status': 'CONVERTED',
      };

      // act
      final result = ReservationModel.fromJson(json);

      // assert
      expect(result.status, ReservationStatus.converted);
    });
  });

  group('toJson', () {
    test('should return a JSON map with proper values', () {
      // act
      final result = tReservationModel.toJson();

      // assert
      expect(result, {
        'id': 'reservation-123',
        'bikeId': 'bike-456',
        'userId': 'user-789',
        'createdAt': '2024-01-15T10:00:00.000',
        'expiresAt': '2024-01-15T10:15:00.000',
        'status': 'ACTIVE',
      });
    });
  });

  group('fromEntity', () {
    test('should create a ReservationModel from a Reservation entity', () {
      // arrange
      final entity = Reservation(
        id: 'reservation-123',
        bikeId: 'bike-456',
        userId: 'user-789',
        createdAt: tCreatedAt,
        expiresAt: tExpiresAt,
        status: ReservationStatus.active,
      );

      // act
      final result = ReservationModel.fromEntity(entity);

      // assert
      expect(result, tReservationModel);
    });
  });
}
