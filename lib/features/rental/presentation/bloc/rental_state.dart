part of 'rental_bloc.dart';

sealed class RentalState extends Equatable {
  const RentalState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any rental action.
final class RentalInitial extends RentalState {
  const RentalInitial();
}

/// Loading state while fetching data.
final class RentalLoading extends RentalState {
  const RentalLoading();
}

/// State while checking eligibility.
final class RentalEligibilityChecking extends RentalState {
  const RentalEligibilityChecking();
}

/// User is eligible to rent.
final class RentalEligible extends RentalState {
  final RentalEligibility eligibility;

  const RentalEligible(this.eligibility);

  @override
  List<Object?> get props => [eligibility];
}

/// User is not eligible to rent.
final class RentalIneligible extends RentalState {
  final RentalEligibility eligibility;

  const RentalIneligible(this.eligibility);

  @override
  List<Object?> get props => [eligibility];
}

/// Rental is being started.
final class RentalStarting extends RentalState {
  const RentalStarting();
}

/// Bike is being unlocked.
final class RentalUnlocking extends RentalState {
  const RentalUnlocking();
}

/// Rental is active.
final class RentalActive extends RentalState {
  final Rental rental;

  /// Timestamp to force UI rebuilds for duration updates.
  final DateTime refreshedAt;

  RentalActive(this.rental, {DateTime? refreshedAt})
    : refreshedAt = refreshedAt ?? DateTime.now();

  @override
  List<Object?> get props => [rental, refreshedAt];
}

/// Rental is being paused.
final class RentalPausing extends RentalState {
  const RentalPausing();
}

/// Rental is paused.
final class RentalPaused extends RentalState {
  final Rental rental;

  /// Timestamp to force UI rebuilds for duration updates.
  final DateTime refreshedAt;

  RentalPaused(this.rental, {DateTime? refreshedAt})
    : refreshedAt = refreshedAt ?? DateTime.now();

  @override
  List<Object?> get props => [rental, refreshedAt];
}

/// Rental is being resumed.
final class RentalResuming extends RentalState {
  const RentalResuming();
}

/// Rental is being ended.
final class RentalEnding extends RentalState {
  const RentalEnding();
}

/// Rental has ended.
final class RentalEnded extends RentalState {
  final Rental rental;

  const RentalEnded(this.rental);

  @override
  List<Object?> get props => [rental];
}

/// Error state with a message.
final class RentalFailure extends RentalState {
  final String message;

  const RentalFailure(this.message);

  @override
  List<Object?> get props => [message];
}
