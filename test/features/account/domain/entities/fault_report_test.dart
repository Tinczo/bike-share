import 'package:bike_app/features/account/domain/entities/fault_report.dart';
import 'package:bike_app/features/account/domain/entities/fault_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tTimestamp = DateTime(2024, 1, 15, 10, 30);
  final tVerificationDate = DateTime(2024, 1, 16, 14, 0);

  const tFaultReport = FaultReport(
    id: 'fault-123',
    bikeId: 'bike-456',
    userId: 'user-789',
    type: FaultType.flatTire,
    description: null,
    timestamp: null,
    isVerified: false,
    isConfirmed: false,
    verificationDate: null,
    rewardAmount: null,
  );

  group('FaultReport', () {
    test('should be a valid entity with required fields', () {
      expect(tFaultReport.id, 'fault-123');
      expect(tFaultReport.bikeId, 'bike-456');
      expect(tFaultReport.userId, 'user-789');
      expect(tFaultReport.type, FaultType.flatTire);
    });

    test('should support optional fields', () {
      final faultWithOptionals = FaultReport(
        id: 'fault-123',
        bikeId: 'bike-456',
        userId: 'user-789',
        type: FaultType.other,
        description: 'The pedal is broken',
        timestamp: tTimestamp,
        isVerified: true,
        isConfirmed: true,
        verificationDate: tVerificationDate,
        rewardAmount: 5.0,
      );

      expect(faultWithOptionals.description, 'The pedal is broken');
      expect(faultWithOptionals.timestamp, tTimestamp);
      expect(faultWithOptionals.isVerified, true);
      expect(faultWithOptionals.isConfirmed, true);
      expect(faultWithOptionals.verificationDate, tVerificationDate);
      expect(faultWithOptionals.rewardAmount, 5.0);
    });

    test('should support value equality', () {
      const faultReport1 = FaultReport(
        id: 'fault-123',
        bikeId: 'bike-456',
        userId: 'user-789',
        type: FaultType.flatTire,
        description: null,
        timestamp: null,
        isVerified: false,
        isConfirmed: false,
        verificationDate: null,
        rewardAmount: null,
      );

      const faultReport2 = FaultReport(
        id: 'fault-123',
        bikeId: 'bike-456',
        userId: 'user-789',
        type: FaultType.flatTire,
        description: null,
        timestamp: null,
        isVerified: false,
        isConfirmed: false,
        verificationDate: null,
        rewardAmount: null,
      );

      expect(faultReport1, equals(faultReport2));
    });

    test('should not be equal when id differs', () {
      const faultReport1 = FaultReport(
        id: 'fault-123',
        bikeId: 'bike-456',
        userId: 'user-789',
        type: FaultType.flatTire,
        description: null,
        timestamp: null,
        isVerified: false,
        isConfirmed: false,
        verificationDate: null,
        rewardAmount: null,
      );

      const faultReport2 = FaultReport(
        id: 'fault-999',
        bikeId: 'bike-456',
        userId: 'user-789',
        type: FaultType.flatTire,
        description: null,
        timestamp: null,
        isVerified: false,
        isConfirmed: false,
        verificationDate: null,
        rewardAmount: null,
      );

      expect(faultReport1, isNot(equals(faultReport2)));
    });

    test('props should contain all fields', () {
      final faultReport = FaultReport(
        id: 'fault-123',
        bikeId: 'bike-456',
        userId: 'user-789',
        type: FaultType.flatTire,
        description: 'test',
        timestamp: tTimestamp,
        isVerified: true,
        isConfirmed: false,
        verificationDate: tVerificationDate,
        rewardAmount: 10.0,
      );

      expect(faultReport.props, [
        'fault-123',
        'bike-456',
        'user-789',
        FaultType.flatTire,
        'test',
        tTimestamp,
        true,
        false,
        tVerificationDate,
        10.0,
      ]);
    });

    test('copyWith should create copy with updated fields', () {
      const original = FaultReport(
        id: 'fault-123',
        bikeId: 'bike-456',
        userId: 'user-789',
        type: FaultType.flatTire,
        description: null,
        timestamp: null,
        isVerified: false,
        isConfirmed: false,
        verificationDate: null,
        rewardAmount: null,
      );

      final updated = original.copyWith(
        isVerified: true,
        verificationDate: tVerificationDate,
        rewardAmount: 5.0,
      );

      expect(updated.id, 'fault-123');
      expect(updated.isVerified, true);
      expect(updated.verificationDate, tVerificationDate);
      expect(updated.rewardAmount, 5.0);
    });
  });
}
