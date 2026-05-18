import 'package:equatable/equatable.dart';

import 'reservation_status.dart';

/// Represents a bike reservation in the system.
///
/// Reservations hold a bike for a user for up to 15 minutes.
class Reservation extends Equatable {
  /// Unique identifier for the reservation.
  final String id;

  /// ID of the reserved bike.
  final String bikeId;

  /// ID of the user who made the reservation.
  final String userId;

  /// Time when the reservation was created.
  final DateTime createdAt;

  /// Time when the reservation expires.
  final DateTime expiresAt;

  /// Current status of the reservation.
  final ReservationStatus status;

  const Reservation({
    required this.id,
    required this.bikeId,
    required this.userId,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
  });

  /// Creates a copy of this reservation with the given fields replaced.
  Reservation copyWith({
    String? id,
    String? bikeId,
    String? userId,
    DateTime? createdAt,
    DateTime? expiresAt,
    ReservationStatus? status,
  }) {
    return Reservation(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
    );
  }

  /// Calculates the remaining time until expiration.
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) {
      return Duration.zero;
    }
    return expiresAt.difference(now);
  }

  /// Whether the reservation has expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [id, bikeId, userId, createdAt, expiresAt, status];
}
