part of 'rental_bloc.dart';

sealed class RentalEvent extends Equatable {
  const RentalEvent();

  @override
  List<Object?> get props => [];
}

/// Request to check if the user is eligible to rent.
final class CheckEligibilityRequested extends RentalEvent {
  const CheckEligibilityRequested();
}

/// Request to start a rental for a specific bike.
final class RentalStarted extends RentalEvent {
  final String bikeId;
  final RentalLaunchMethod method;

  const RentalStarted({required this.bikeId, required this.method});

  @override
  List<Object?> get props => [bikeId, method];
}

/// Request to toggle pause state of the current rental.
final class RentalPauseToggled extends RentalEvent {
  final String rentalId;

  const RentalPauseToggled({required this.rentalId});

  @override
  List<Object?> get props => [rentalId];
}

/// Request to end the current rental.
final class RentalEndRequested extends RentalEvent {
  final String rentalId;

  const RentalEndRequested({required this.rentalId});

  @override
  List<Object?> get props => [rentalId];
}

/// Request to load the current active rental.
final class ActiveRentalLoaded extends RentalEvent {
  const ActiveRentalLoaded();
}

/// Request to start a rental with eligibility and active rental checks.
///
/// This event combines eligibility checking with rental start, ensuring:
/// 1. User doesn't have an active rental already.
/// 2. User passes eligibility requirements (wallet balance, linked card, etc.).
/// 3. Then proceeds with starting the rental.
final class RentalStartWithCheckRequested extends RentalEvent {
  final String bikeId;
  final RentalLaunchMethod method;

  const RentalStartWithCheckRequested({
    required this.bikeId,
    required this.method,
  });

  @override
  List<Object?> get props => [bikeId, method];
}

/// Internal event triggered by the duration timer to refresh the UI.
final class RentalDurationTicked extends RentalEvent {
  const RentalDurationTicked();
}
