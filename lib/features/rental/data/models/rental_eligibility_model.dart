import '../../domain/entities/rental_eligibility.dart';

/// Data model for [RentalEligibility] entity.
///
/// Handles JSON serialization/deserialization with backend field mapping.
class RentalEligibilityModel extends RentalEligibility {
  const RentalEligibilityModel({
    required super.isEligible,
    required super.hasMinimumBalance,
    required super.hasLinkedCard,
    required super.hasActiveSubscription,
    required super.isDebtor,
    super.reason,
  });

  /// Creates a [RentalEligibilityModel] from a JSON map.
  ///
  /// Supports both Polish backend format and English format.
  factory RentalEligibilityModel.fromJson(Map<String, dynamic> json) {
    return RentalEligibilityModel(
      isEligible: (json['uprawniony'] ??
              json['czy_moze_wypozyczac'] ??
              json['isEligible'] ??
              false)
          as bool,
      hasMinimumBalance:
          (json['ma_minimalne_saldo'] ?? json['hasMinimumBalance'] ?? false)
              as bool,
      hasLinkedCard:
          (json['ma_podpieta_karte'] ?? json['hasLinkedCard'] ?? false) as bool,
      hasActiveSubscription:
          (json['ma_aktywna_subskrypcje'] ??
                  json['hasActiveSubscription'] ??
                  false)
              as bool,
      isDebtor: (json['jest_dluznikiem'] ?? json['isDebtor'] ?? false) as bool,
      reason: (json['powod'] ?? json['reason']) as String?,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'isEligible': isEligible,
      'hasMinimumBalance': hasMinimumBalance,
      'hasLinkedCard': hasLinkedCard,
      'hasActiveSubscription': hasActiveSubscription,
      'isDebtor': isDebtor,
      'reason': reason,
    };
  }

  /// Creates a [RentalEligibilityModel] from a [RentalEligibility] entity.
  factory RentalEligibilityModel.fromEntity(RentalEligibility eligibility) {
    return RentalEligibilityModel(
      isEligible: eligibility.isEligible,
      hasMinimumBalance: eligibility.hasMinimumBalance,
      hasLinkedCard: eligibility.hasLinkedCard,
      hasActiveSubscription: eligibility.hasActiveSubscription,
      isDebtor: eligibility.isDebtor,
      reason: eligibility.reason,
    );
  }
}
