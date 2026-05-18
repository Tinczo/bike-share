import 'package:bike_app/features/rental/data/models/rental_eligibility_model.dart';
import 'package:bike_app/features/rental/domain/entities/rental_eligibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tEligibilityModel = RentalEligibilityModel(
    isEligible: true,
    hasMinimumBalance: true,
    hasLinkedCard: true,
    hasActiveSubscription: false,
    isDebtor: false,
  );

  test('should be a subclass of RentalEligibility entity', () {
    expect(tEligibilityModel, isA<RentalEligibility>());
  });

  group('fromJson', () {
    test('should return a valid model from Polish backend format', () {
      // arrange
      final json = {
        'czy_moze_wypozyczac': true,
        'ma_minimalne_saldo': true,
        'ma_podpieta_karte': true,
        'ma_aktywna_subskrypcje': false,
        'jest_dluznikiem': false,
      };

      // act
      final result = RentalEligibilityModel.fromJson(json);

      // assert
      expect(result, tEligibilityModel);
    });

    test('should return a valid model from English format', () {
      // arrange
      final json = {
        'isEligible': true,
        'hasMinimumBalance': true,
        'hasLinkedCard': true,
        'hasActiveSubscription': false,
        'isDebtor': false,
      };

      // act
      final result = RentalEligibilityModel.fromJson(json);

      // assert
      expect(result, tEligibilityModel);
    });

    test('should parse reason when provided', () {
      // arrange
      final json = {
        'isEligible': false,
        'hasMinimumBalance': false,
        'hasLinkedCard': true,
        'hasActiveSubscription': false,
        'isDebtor': true,
        'reason': 'Outstanding debt',
      };

      // act
      final result = RentalEligibilityModel.fromJson(json);

      // assert
      expect(result.isEligible, false);
      expect(result.reason, 'Outstanding debt');
    });

    test('should parse Polish reason when provided', () {
      // arrange
      final json = {
        'czy_moze_wypozyczac': false,
        'ma_minimalne_saldo': false,
        'ma_podpieta_karte': true,
        'ma_aktywna_subskrypcje': false,
        'jest_dluznikiem': true,
        'powod': 'Zaleglosci w platnosci',
      };

      // act
      final result = RentalEligibilityModel.fromJson(json);

      // assert
      expect(result.reason, 'Zaleglosci w platnosci');
    });

    test('should default missing boolean values to false', () {
      // arrange
      final json = <String, dynamic>{};

      // act
      final result = RentalEligibilityModel.fromJson(json);

      // assert
      expect(result.isEligible, false);
      expect(result.hasMinimumBalance, false);
      expect(result.hasLinkedCard, false);
      expect(result.hasActiveSubscription, false);
      expect(result.isDebtor, false);
    });

    test('should return a valid model from simplified Polish format with uprawniony', () {
      // arrange
      final json = {
        'uprawniony': true,
        'powod': null,
      };

      // act
      final result = RentalEligibilityModel.fromJson(json);

      // assert
      expect(result.isEligible, true);
      expect(result.reason, null);
    });

    test('should handle uprawniony false with reason', () {
      // arrange
      final json = {
        'uprawniony': false,
        'powod': 'Użytkownik ma aktywne wypożyczenie',
      };

      // act
      final result = RentalEligibilityModel.fromJson(json);

      // assert
      expect(result.isEligible, false);
      expect(result.reason, 'Użytkownik ma aktywne wypożyczenie');
    });
  });

  group('toJson', () {
    test('should return a JSON map with proper values', () {
      // act
      final result = tEligibilityModel.toJson();

      // assert
      expect(result, {
        'isEligible': true,
        'hasMinimumBalance': true,
        'hasLinkedCard': true,
        'hasActiveSubscription': false,
        'isDebtor': false,
        'reason': null,
      });
    });

    test('should include reason when provided', () {
      // arrange
      const model = RentalEligibilityModel(
        isEligible: false,
        hasMinimumBalance: false,
        hasLinkedCard: true,
        hasActiveSubscription: false,
        isDebtor: true,
        reason: 'Outstanding debt',
      );

      // act
      final result = model.toJson();

      // assert
      expect(result['reason'], 'Outstanding debt');
    });
  });

  group('fromEntity', () {
    test('should create a RentalEligibilityModel from an entity', () {
      // arrange
      const entity = RentalEligibility(
        isEligible: true,
        hasMinimumBalance: true,
        hasLinkedCard: true,
        hasActiveSubscription: false,
        isDebtor: false,
      );

      // act
      final result = RentalEligibilityModel.fromEntity(entity);

      // assert
      expect(result, tEligibilityModel);
    });
  });
}
