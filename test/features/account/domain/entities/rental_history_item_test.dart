import 'package:bike_app/features/account/domain/entities/rental_history_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tStartTime = DateTime(2024, 1, 15, 10, 0);
  final tEndTime = DateTime(2024, 1, 15, 11, 30);

  final tRentalHistoryItem = RentalHistoryItem(
    id: 'rental-123',
    bikeId: 'bike-456',
    startTime: tStartTime,
    endTime: tEndTime,
    cost: 4.5,
    startStationName: 'Station A',
    endStationName: 'Station B',
  );

  group('RentalHistoryItem', () {
    test('should be a valid entity with required fields', () {
      expect(tRentalHistoryItem.id, 'rental-123');
      expect(tRentalHistoryItem.bikeId, 'bike-456');
      expect(tRentalHistoryItem.startTime, tStartTime);
      expect(tRentalHistoryItem.endTime, tEndTime);
      expect(tRentalHistoryItem.cost, 4.5);
    });

    test('should support optional station names', () {
      expect(tRentalHistoryItem.startStationName, 'Station A');
      expect(tRentalHistoryItem.endStationName, 'Station B');
    });

    test('should handle null station names', () {
      final itemWithoutStations = RentalHistoryItem(
        id: 'rental-123',
        bikeId: 'bike-456',
        startTime: tStartTime,
        endTime: tEndTime,
        cost: 4.5,
        startStationName: null,
        endStationName: null,
      );

      expect(itemWithoutStations.startStationName, isNull);
      expect(itemWithoutStations.endStationName, isNull);
    });

    test('should support value equality', () {
      final item1 = RentalHistoryItem(
        id: 'rental-123',
        bikeId: 'bike-456',
        startTime: tStartTime,
        endTime: tEndTime,
        cost: 4.5,
        startStationName: 'Station A',
        endStationName: 'Station B',
      );

      final item2 = RentalHistoryItem(
        id: 'rental-123',
        bikeId: 'bike-456',
        startTime: tStartTime,
        endTime: tEndTime,
        cost: 4.5,
        startStationName: 'Station A',
        endStationName: 'Station B',
      );

      expect(item1, equals(item2));
    });

    test('should not be equal when id differs', () {
      final item1 = RentalHistoryItem(
        id: 'rental-123',
        bikeId: 'bike-456',
        startTime: tStartTime,
        endTime: tEndTime,
        cost: 4.5,
        startStationName: null,
        endStationName: null,
      );

      final item2 = RentalHistoryItem(
        id: 'rental-999',
        bikeId: 'bike-456',
        startTime: tStartTime,
        endTime: tEndTime,
        cost: 4.5,
        startStationName: null,
        endStationName: null,
      );

      expect(item1, isNot(equals(item2)));
    });

    test('props should contain all fields', () {
      expect(tRentalHistoryItem.props, [
        'rental-123',
        'bike-456',
        tStartTime,
        tEndTime,
        4.5,
        'Station A',
        'Station B',
      ]);
    });

    test('duration should calculate time difference correctly', () {
      expect(tRentalHistoryItem.duration, const Duration(hours: 1, minutes: 30));
    });

    test('copyWith should create copy with updated fields', () {
      final updated = tRentalHistoryItem.copyWith(cost: 10.0);

      expect(updated.id, 'rental-123');
      expect(updated.cost, 10.0);
      expect(updated.startStationName, 'Station A');
    });
  });
}
