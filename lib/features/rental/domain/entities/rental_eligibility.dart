import 'package:equatable/equatable.dart';

/// Represents a user's eligibility to rent a bike.
class RentalEligibility extends Equatable {
  /// Whether the user is eligible to rent.
  final bool isEligible;

  /// Whether the user has the minimum required balance.
  final bool hasMinimumBalance;

  /// Whether the user has a linked payment card.
  final bool hasLinkedCard;

  /// Whether the user has an active subscription.
  final bool hasActiveSubscription;

  /// Whether the user is a debtor (has outstanding debt).
  final bool isDebtor;

  /// Reason for ineligibility (if not eligible).
  final String? reason;

  const RentalEligibility({
    required this.isEligible,
    required this.hasMinimumBalance,
    required this.hasLinkedCard,
    required this.hasActiveSubscription,
    required this.isDebtor,
    this.reason,
  });

  /// Creates a copy of this eligibility with the given fields replaced.
  RentalEligibility copyWith({
    bool? isEligible,
    bool? hasMinimumBalance,
    bool? hasLinkedCard,
    bool? hasActiveSubscription,
    bool? isDebtor,
    String? reason,
  }) {
    return RentalEligibility(
      isEligible: isEligible ?? this.isEligible,
      hasMinimumBalance: hasMinimumBalance ?? this.hasMinimumBalance,
      hasLinkedCard: hasLinkedCard ?? this.hasLinkedCard,
      hasActiveSubscription:
          hasActiveSubscription ?? this.hasActiveSubscription,
      isDebtor: isDebtor ?? this.isDebtor,
      reason: reason ?? this.reason,
    );
  }

  @override
  List<Object?> get props => [
    isEligible,
    hasMinimumBalance,
    hasLinkedCard,
    hasActiveSubscription,
    isDebtor,
    reason,
  ];
}
