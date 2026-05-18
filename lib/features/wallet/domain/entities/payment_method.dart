import 'package:equatable/equatable.dart';

/// Type of payment method.
enum PaymentMethodType {
  /// Credit or debit card.
  card,

  /// BLIK instant payment (Polish payment system).
  blik,

  /// Bank transfer.
  transfer,
}

/// Represents a payment method that can be used for wallet top-ups.
class PaymentMethod extends Equatable {
  /// Unique identifier for the payment method.
  final String id;

  /// Type of payment method.
  final PaymentMethodType type;

  /// Last four digits of the card number (only for card type).
  final String? lastFourDigits;

  /// Card brand like Visa or Mastercard (only for card type).
  final String? cardBrand;

  const PaymentMethod({
    required this.id,
    required this.type,
    this.lastFourDigits,
    this.cardBrand,
  });

  @override
  List<Object?> get props => [id, type, lastFourDigits, cardBrand];
}
