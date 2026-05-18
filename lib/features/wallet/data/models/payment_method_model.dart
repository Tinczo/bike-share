import '../../domain/entities/payment_method.dart';

/// Data model for [PaymentMethod] entity.
///
/// Handles JSON serialization/deserialization with backend field mapping.
class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    required super.id,
    required super.type,
    super.lastFourDigits,
    super.cardBrand,
  });

  /// Creates a [PaymentMethodModel] from a JSON map.
  ///
  /// Supports both Polish backend format ('id_metody', 'typ', 'ostatnie_cztery',
  /// 'marka_karty') and English format.
  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: (json['id_metody'] ?? json['id']) as String,
      type: _parseType(json['typ'] ?? json['type'] as String?),
      lastFourDigits:
          (json['ostatnie_cztery'] ?? json['lastFourDigits']) as String?,
      cardBrand: (json['marka_karty'] ?? json['cardBrand']) as String?,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _typeToString(type),
      'lastFourDigits': lastFourDigits,
      'cardBrand': cardBrand,
    };
  }

  static PaymentMethodType _parseType(String? type) {
    return switch (type?.toUpperCase()) {
      'CARD' => PaymentMethodType.card,
      'BLIK' => PaymentMethodType.blik,
      'TRANSFER' => PaymentMethodType.transfer,
      _ => PaymentMethodType.card,
    };
  }

  static String _typeToString(PaymentMethodType type) {
    return switch (type) {
      PaymentMethodType.card => 'CARD',
      PaymentMethodType.blik => 'BLIK',
      PaymentMethodType.transfer => 'TRANSFER',
    };
  }
}
