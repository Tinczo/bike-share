import 'package:bike_app/features/account/data/models/fault_report_model.dart';
import 'package:bike_app/features/account/domain/entities/fault_report.dart';
import 'package:bike_app/features/account/domain/entities/fault_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tTimestamp = DateTime(2024, 1, 15, 10, 30);
  final tVerificationDate = DateTime(2024, 1, 16, 14, 0);

  final tFaultReportModel = FaultReportModel(
    id: 'fault-123',
    bikeId: 'bike-456',
    userId: 'user-789',
    type: FaultType.flatTire,
    description: null,
    timestamp: tTimestamp,
    isVerified: false,
    isConfirmed: false,
    verificationDate: null,
    rewardAmount: null,
  );

  group('FaultReportModel', () {
    test('should be a subclass of FaultReport entity', () {
      expect(tFaultReportModel, isA<FaultReport>());
    });

    group('fromJson', () {
      test('should parse Polish backend format correctly', () {
        final json = {
          'id_zgloszenia': 'fault-123',
          'id_roweru': 'bike-456',
          'id_uzytkownika': 'user-789',
          'typ_usterki': 'PRZEBITA_OPONA',
          'opis': null,
          'data_zgloszenia': '2024-01-15T10:30:00',
          'czy_zweryfikowane': false,
          'czy_potwierdzone': false,
          'data_weryfikacji': null,
          'kwota_nagrody': null,
        };

        final result = FaultReportModel.fromJson(json);

        expect(result.id, 'fault-123');
        expect(result.bikeId, 'bike-456');
        expect(result.userId, 'user-789');
        expect(result.type, FaultType.flatTire);
        expect(result.isVerified, false);
        expect(result.isConfirmed, false);
      });

      test('should parse English format correctly', () {
        final json = {
          'id': 'fault-123',
          'bikeId': 'bike-456',
          'userId': 'user-789',
          'type': 'FLAT_TIRE',
          'description': 'Front tire punctured',
          'timestamp': '2024-01-15T10:30:00',
          'isVerified': true,
          'isConfirmed': true,
          'verificationDate': '2024-01-16T14:00:00',
          'rewardAmount': 5.0,
        };

        final result = FaultReportModel.fromJson(json);

        expect(result.id, 'fault-123');
        expect(result.bikeId, 'bike-456');
        expect(result.type, FaultType.flatTire);
        expect(result.description, 'Front tire punctured');
        expect(result.isVerified, true);
        expect(result.isConfirmed, true);
        expect(result.rewardAmount, 5.0);
      });

      test('should parse verified fault report with reward', () {
        final json = {
          'id_zgloszenia': 'fault-123',
          'id_roweru': 'bike-456',
          'id_uzytkownika': 'user-789',
          'typ_usterki': 'ZERWANY_LANCUCH',
          'opis': 'Chain completely broken',
          'data_zgloszenia': '2024-01-15T10:30:00',
          'czy_zweryfikowane': true,
          'czy_potwierdzone': true,
          'data_weryfikacji': '2024-01-16T14:00:00',
          'kwota_nagrody': 5.0,
        };

        final result = FaultReportModel.fromJson(json);

        expect(result.type, FaultType.brokenChain);
        expect(result.description, 'Chain completely broken');
        expect(result.isVerified, true);
        expect(result.isConfirmed, true);
        expect(result.verificationDate, tVerificationDate);
        expect(result.rewardAmount, 5.0);
      });

      test('should parse all fault types correctly', () {
        final testCases = {
          'PRZEBITA_OPONA': FaultType.flatTire,
          'ZERWANY_LANCUCH': FaultType.brokenChain,
          'USZKODZONE_HAMULCE': FaultType.faultyBrakes,
          'USZKODZONA_RAMA': FaultType.damagedFrame,
          'ZEPSUTY_DZWONEK': FaultType.brokenBell,
          'USZKODZONE_SWIATLA': FaultType.damagedLights,
          'INNE': FaultType.other,
        };

        testCases.forEach((apiValue, expectedType) {
          final json = {
            'id': 'fault-1',
            'bikeId': 'bike-1',
            'userId': 'user-1',
            'type': apiValue,
            'isVerified': false,
            'isConfirmed': false,
          };

          final result = FaultReportModel.fromJson(json);
          expect(result.type, expectedType);
        });
      });

      test('should handle integer reward amount', () {
        final json = {
          'id': 'fault-123',
          'bikeId': 'bike-456',
          'userId': 'user-789',
          'type': 'FLAT_TIRE',
          'isVerified': true,
          'isConfirmed': true,
          'rewardAmount': 5,
        };

        final result = FaultReportModel.fromJson(json);

        expect(result.rewardAmount, 5.0);
      });
    });

    group('toJson', () {
      test('should convert to JSON correctly', () {
        final model = FaultReportModel(
          id: 'fault-123',
          bikeId: 'bike-456',
          userId: 'user-789',
          type: FaultType.flatTire,
          description: 'Test description',
          timestamp: tTimestamp,
          isVerified: true,
          isConfirmed: true,
          verificationDate: tVerificationDate,
          rewardAmount: 5.0,
        );

        final json = model.toJson();

        expect(json['id'], 'fault-123');
        expect(json['bikeId'], 'bike-456');
        expect(json['userId'], 'user-789');
        expect(json['type'], 'PRZEBITA_OPONA');
        expect(json['description'], 'Test description');
        expect(json['isVerified'], true);
        expect(json['isConfirmed'], true);
        expect(json['rewardAmount'], 5.0);
      });

      test('should handle null optional fields', () {
        final model = FaultReportModel(
          id: 'fault-123',
          bikeId: 'bike-456',
          userId: 'user-789',
          type: FaultType.other,
          isVerified: false,
          isConfirmed: false,
        );

        final json = model.toJson();

        expect(json['description'], isNull);
        expect(json['timestamp'], isNull);
        expect(json['verificationDate'], isNull);
        expect(json['rewardAmount'], isNull);
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        final entity = FaultReport(
          id: 'fault-123',
          bikeId: 'bike-456',
          userId: 'user-789',
          type: FaultType.flatTire,
          description: 'Test',
          timestamp: tTimestamp,
          isVerified: true,
          isConfirmed: false,
          verificationDate: tVerificationDate,
          rewardAmount: 10.0,
        );

        final model = FaultReportModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.bikeId, entity.bikeId);
        expect(model.userId, entity.userId);
        expect(model.type, entity.type);
        expect(model.description, entity.description);
        expect(model.timestamp, entity.timestamp);
        expect(model.isVerified, entity.isVerified);
        expect(model.isConfirmed, entity.isConfirmed);
        expect(model.verificationDate, entity.verificationDate);
        expect(model.rewardAmount, entity.rewardAmount);
      });
    });
  });
}
