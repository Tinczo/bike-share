import 'package:bike_app/features/account/data/models/rental_history_item_model.dart';
import 'package:bike_app/features/account/domain/entities/rental_history_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tStartTime = DateTime(2024, 1, 15, 10, 0);
  final tEndTime = DateTime(2024, 1, 15, 11, 30);

  final tRentalHistoryItemModel = RentalHistoryItemModel(
    id: 'rental-123',
    bikeId: 'bike-456',
    startTime: tStartTime,
    endTime: tEndTime,
    cost: 4.5,
    startStationName: 'Station A',
    endStationName: 'Station B',
  );

  group('RentalHistoryItemModel', () {
    test('should be a subclass of RentalHistoryItem entity', () {
      expect(tRentalHistoryItemModel, isA<RentalHistoryItem>());
    });

    group('fromJson', () {
      test('should parse Polish backend format correctly', () {
        final json = {
          'id_wypozyczenia': 'rental-123',
          'id_roweru': 'bike-456',
          'data_rozpoczecia': '2024-01-15T10:00:00',
          'data_zakonczenia': '2024-01-15T11:30:00',
          'koszt_calkowity': 4.5,
          'nazwa_stacji_start': 'Station A',
          'nazwa_stacji_koniec': 'Station B',
        };

        final result = RentalHistoryItemModel.fromJson(json);

        expect(result.id, 'rental-123');
        expect(result.bikeId, 'bike-456');
        expect(result.startTime, tStartTime);
        expect(result.endTime, tEndTime);
        expect(result.cost, 4.5);
        expect(result.startStationName, 'Station A');
        expect(result.endStationName, 'Station B');
      });

      test('should parse English format correctly', () {
        final json = {
          'id': 'rental-123',
          'bikeId': 'bike-456',
          'startTime': '2024-01-15T10:00:00',
          'endTime': '2024-01-15T11:30:00',
          'cost': 4.5,
          'startStationName': 'Station A',
          'endStationName': 'Station B',
        };

        final result = RentalHistoryItemModel.fromJson(json);

        expect(result.id, 'rental-123');
        expect(result.bikeId, 'bike-456');
        expect(result.startTime, tStartTime);
        expect(result.endTime, tEndTime);
        expect(result.cost, 4.5);
        expect(result.startStationName, 'Station A');
        expect(result.endStationName, 'Station B');
      });

      test('should handle null station names', () {
        final json = {
          'id': 'rental-123',
          'bikeId': 'bike-456',
          'startTime': '2024-01-15T10:00:00',
          'endTime': '2024-01-15T11:30:00',
          'cost': 4.5,
        };

        final result = RentalHistoryItemModel.fromJson(json);

        expect(result.startStationName, isNull);
        expect(result.endStationName, isNull);
      });

      test('should handle integer cost', () {
        final json = {
          'id': 'rental-123',
          'bikeId': 'bike-456',
          'startTime': '2024-01-15T10:00:00',
          'endTime': '2024-01-15T11:30:00',
          'cost': 5,
        };

        final result = RentalHistoryItemModel.fromJson(json);

        expect(result.cost, 5.0);
      });

      test('should handle alternative Polish field names', () {
        final json = {
          'id_wypozyczenia': 'rental-123',
          'id_roweru': 'bike-456',
          'czas_rozpoczecia': '2024-01-15T10:00:00',
          'czas_zakonczenia': '2024-01-15T11:30:00',
          'koszt': 4.5,
        };

        final result = RentalHistoryItemModel.fromJson(json);

        expect(result.id, 'rental-123');
        expect(result.startTime, tStartTime);
        expect(result.endTime, tEndTime);
        expect(result.cost, 4.5);
      });
    });

    group('toJson', () {
      test('should convert to JSON correctly', () {
        final json = tRentalHistoryItemModel.toJson();

        expect(json['id'], 'rental-123');
        expect(json['bikeId'], 'bike-456');
        expect(json['startTime'], '2024-01-15T10:00:00.000');
        expect(json['endTime'], '2024-01-15T11:30:00.000');
        expect(json['cost'], 4.5);
        expect(json['startStationName'], 'Station A');
        expect(json['endStationName'], 'Station B');
      });

      test('should handle null station names', () {
        final model = RentalHistoryItemModel(
          id: 'rental-123',
          bikeId: 'bike-456',
          startTime: tStartTime,
          endTime: tEndTime,
          cost: 4.5,
        );

        final json = model.toJson();

        expect(json['startStationName'], isNull);
        expect(json['endStationName'], isNull);
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        final entity = RentalHistoryItem(
          id: 'rental-123',
          bikeId: 'bike-456',
          startTime: tStartTime,
          endTime: tEndTime,
          cost: 4.5,
          startStationName: 'Station A',
          endStationName: 'Station B',
        );

        final model = RentalHistoryItemModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.bikeId, entity.bikeId);
        expect(model.startTime, entity.startTime);
        expect(model.endTime, entity.endTime);
        expect(model.cost, entity.cost);
        expect(model.startStationName, entity.startStationName);
        expect(model.endStationName, entity.endStationName);
      });
    });
  });
}
