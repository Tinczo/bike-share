import 'package:bike_app/features/wallet/data/models/wallet_model.dart';
import 'package:bike_app/features/wallet/domain/entities/wallet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tWalletModel = WalletModel(
    balance: 150.50,
    status: WalletStatus.active,
    hasCard: true,
  );

  test('should be a subclass of Wallet entity', () {
    expect(tWalletModel, isA<Wallet>());
  });

  group('fromJson', () {
    test('should return a valid model from Polish backend format', () {
      // arrange
      final json = {
        'saldo': 150.50,
        'status': 'ACTIVE',
        'ma_podpieta_karte': true,
      };

      // act
      final result = WalletModel.fromJson(json);

      // assert
      expect(result, tWalletModel);
    });

    test('should return a valid model from English format', () {
      // arrange
      final json = {'balance': 150.50, 'status': 'ACTIVE', 'hasCard': true};

      // act
      final result = WalletModel.fromJson(json);

      // assert
      expect(result, tWalletModel);
    });

    test('should parse DEBT status correctly', () {
      // arrange
      final json = {
        'saldo': -25.0,
        'status': 'DEBT',
        'ma_podpieta_karte': false,
      };

      // act
      final result = WalletModel.fromJson(json);

      // assert
      expect(result.status, WalletStatus.debt);
      expect(result.balance, -25.0);
    });

    test('should parse INACTIVE status correctly', () {
      // arrange
      final json = {
        'saldo': 0.0,
        'status': 'INACTIVE',
        'ma_podpieta_karte': false,
      };

      // act
      final result = WalletModel.fromJson(json);

      // assert
      expect(result.status, WalletStatus.inactive);
    });

    test('should default to active status for unknown values', () {
      // arrange
      final json = {
        'saldo': 100.0,
        'status': 'UNKNOWN',
        'ma_podpieta_karte': true,
      };

      // act
      final result = WalletModel.fromJson(json);

      // assert
      expect(result.status, WalletStatus.active);
    });

    test('should handle integer balance', () {
      // arrange
      final json = {
        'saldo': 100,
        'status': 'ACTIVE',
        'ma_podpieta_karte': true,
      };

      // act
      final result = WalletModel.fromJson(json);

      // assert
      expect(result.balance, 100.0);
    });
  });

  group('toJson', () {
    test('should return a JSON map with proper values', () {
      // arrange
      const model = WalletModel(
        balance: 150.50,
        status: WalletStatus.active,
        hasCard: true,
      );

      // act
      final result = model.toJson();

      // assert
      expect(result, {'balance': 150.50, 'status': 'ACTIVE', 'hasCard': true});
    });

    test('should convert DEBT status correctly', () {
      // arrange
      const model = WalletModel(
        balance: -25.0,
        status: WalletStatus.debt,
        hasCard: false,
      );

      // act
      final result = model.toJson();

      // assert
      expect(result['status'], 'DEBT');
    });
  });
}
