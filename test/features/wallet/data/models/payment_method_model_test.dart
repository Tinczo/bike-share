import 'package:bike_app/features/wallet/data/models/payment_method_model.dart';
import 'package:bike_app/features/wallet/domain/entities/payment_method.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tCardModel = PaymentMethodModel(
    id: 'pm_123',
    type: PaymentMethodType.card,
    lastFourDigits: '4242',
    cardBrand: 'Visa',
  );

  const tBlikModel = PaymentMethodModel(
    id: 'pm_456',
    type: PaymentMethodType.blik,
  );

  test('should be a subclass of PaymentMethod entity', () {
    expect(tCardModel, isA<PaymentMethod>());
    expect(tBlikModel, isA<PaymentMethod>());
  });

  group('fromJson', () {
    test('should return a valid card model from Polish backend format', () {
      // arrange
      final json = {
        'id_metody': 'pm_123',
        'typ': 'CARD',
        'ostatnie_cztery': '4242',
        'marka_karty': 'Visa',
      };

      // act
      final result = PaymentMethodModel.fromJson(json);

      // assert
      expect(result, tCardModel);
    });

    test('should return a valid card model from English format', () {
      // arrange
      final json = {
        'id': 'pm_123',
        'type': 'CARD',
        'lastFourDigits': '4242',
        'cardBrand': 'Visa',
      };

      // act
      final result = PaymentMethodModel.fromJson(json);

      // assert
      expect(result, tCardModel);
    });

    test('should return a valid BLIK model', () {
      // arrange
      final json = {'id_metody': 'pm_456', 'typ': 'BLIK'};

      // act
      final result = PaymentMethodModel.fromJson(json);

      // assert
      expect(result, tBlikModel);
    });

    test('should parse TRANSFER type correctly', () {
      // arrange
      final json = {'id_metody': 'pm_789', 'typ': 'TRANSFER'};

      // act
      final result = PaymentMethodModel.fromJson(json);

      // assert
      expect(result.type, PaymentMethodType.transfer);
    });

    test('should default to card type for unknown values', () {
      // arrange
      final json = {'id_metody': 'pm_101', 'typ': 'UNKNOWN'};

      // act
      final result = PaymentMethodModel.fromJson(json);

      // assert
      expect(result.type, PaymentMethodType.card);
    });

    test('should handle null optional fields', () {
      // arrange
      final json = {
        'id_metody': 'pm_102',
        'typ': 'CARD',
        'ostatnie_cztery': null,
        'marka_karty': null,
      };

      // act
      final result = PaymentMethodModel.fromJson(json);

      // assert
      expect(result.lastFourDigits, isNull);
      expect(result.cardBrand, isNull);
    });
  });

  group('toJson', () {
    test('should return a JSON map for card with all values', () {
      // act
      final result = tCardModel.toJson();

      // assert
      expect(result, {
        'id': 'pm_123',
        'type': 'CARD',
        'lastFourDigits': '4242',
        'cardBrand': 'Visa',
      });
    });

    test('should return a JSON map for BLIK without card fields', () {
      // act
      final result = tBlikModel.toJson();

      // assert
      expect(result, {
        'id': 'pm_456',
        'type': 'BLIK',
        'lastFourDigits': null,
        'cardBrand': null,
      });
    });

    test('should convert TRANSFER type correctly', () {
      // arrange
      const model = PaymentMethodModel(
        id: 'pm_789',
        type: PaymentMethodType.transfer,
      );

      // act
      final result = model.toJson();

      // assert
      expect(result['type'], 'TRANSFER');
    });
  });
}
