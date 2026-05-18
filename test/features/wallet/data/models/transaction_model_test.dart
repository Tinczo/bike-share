import 'package:bike_app/features/wallet/data/models/transaction_model.dart';
import 'package:bike_app/features/wallet/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tDate = DateTime(2024, 1, 15, 10, 30);
  final tTransactionModel = TransactionModel(
    id: 'trans_123',
    amount: 50.0,
    type: TransactionType.topUp,
    date: tDate,
    description: 'Top up via BLIK',
  );

  test('should be a subclass of Transaction entity', () {
    expect(tTransactionModel, isA<Transaction>());
  });

  group('fromJson', () {
    test('should return a valid model from Polish backend format', () {
      // arrange
      final json = {
        'id_transakcji': 'trans_123',
        'kwota': 50.0,
        'typ': 'TOP_UP',
        'czas_rejestracji': '2024-01-15T10:30:00.000',
        'opis': 'Top up via BLIK',
      };

      // act
      final result = TransactionModel.fromJson(json);

      // assert
      expect(result, tTransactionModel);
    });

    test('should return a valid model from English format', () {
      // arrange
      final json = {
        'id': 'trans_123',
        'amount': 50.0,
        'type': 'TOP_UP',
        'date': '2024-01-15T10:30:00.000',
        'description': 'Top up via BLIK',
      };

      // act
      final result = TransactionModel.fromJson(json);

      // assert
      expect(result, tTransactionModel);
    });

    test('should parse FEE type correctly', () {
      // arrange
      final json = {
        'id_transakcji': 'trans_456',
        'kwota': -5.0,
        'typ': 'FEE',
        'czas_rejestracji': '2024-01-15T10:30:00.000',
        'opis': 'Rental fee',
      };

      // act
      final result = TransactionModel.fromJson(json);

      // assert
      expect(result.type, TransactionType.fee);
      expect(result.amount, -5.0);
    });

    test('should parse REWARD type correctly', () {
      // arrange
      final json = {
        'id_transakcji': 'trans_789',
        'kwota': 10.0,
        'typ': 'REWARD',
        'czas_rejestracji': '2024-01-15T10:30:00.000',
        'opis': 'Referral bonus',
      };

      // act
      final result = TransactionModel.fromJson(json);

      // assert
      expect(result.type, TransactionType.reward);
    });

    test('should parse PENALTY type correctly', () {
      // arrange
      final json = {
        'id_transakcji': 'trans_101',
        'kwota': -20.0,
        'typ': 'PENALTY',
        'czas_rejestracji': '2024-01-15T10:30:00.000',
        'opis': 'Late return penalty',
      };

      // act
      final result = TransactionModel.fromJson(json);

      // assert
      expect(result.type, TransactionType.penalty);
    });

    test('should default to topUp type for unknown values', () {
      // arrange
      final json = {
        'id_transakcji': 'trans_102',
        'kwota': 25.0,
        'typ': 'UNKNOWN',
        'czas_rejestracji': '2024-01-15T10:30:00.000',
        'opis': 'Unknown transaction',
      };

      // act
      final result = TransactionModel.fromJson(json);

      // assert
      expect(result.type, TransactionType.topUp);
    });

    test('should handle integer amount', () {
      // arrange
      final json = {
        'id_transakcji': 'trans_103',
        'kwota': 100,
        'typ': 'TOP_UP',
        'czas_rejestracji': '2024-01-15T10:30:00.000',
        'opis': 'Top up',
      };

      // act
      final result = TransactionModel.fromJson(json);

      // assert
      expect(result.amount, 100.0);
    });
  });

  group('toJson', () {
    test('should return a JSON map with proper values', () {
      // act
      final result = tTransactionModel.toJson();

      // assert
      expect(result, {
        'id': 'trans_123',
        'amount': 50.0,
        'type': 'TOP_UP',
        'date': '2024-01-15T10:30:00.000',
        'description': 'Top up via BLIK',
      });
    });

    test('should convert FEE type correctly', () {
      // arrange
      final model = TransactionModel(
        id: 'trans_456',
        amount: -5.0,
        type: TransactionType.fee,
        date: tDate,
        description: 'Rental fee',
      );

      // act
      final result = model.toJson();

      // assert
      expect(result['type'], 'FEE');
    });
  });
}
