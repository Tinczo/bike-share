import 'package:equatable/equatable.dart';

import 'rental_status.dart';

/// Represents a bike rental in the system.
class Rental extends Equatable {
  /// Unique identifier for the rental.
  final String id;

  /// ID of the rented bike.
  final String bikeId;

  /// ID of the user who rented the bike.
  final String userId;

  /// Start time of the rental.
  final DateTime startTime;

  /// End time of the rental (null if still active).
  final DateTime? endTime;

  /// Current cost of the rental in PLN.
  final double cost;

  /// Current status of the rental.
  final RentalStatus status;

  const Rental({
    required this.id,
    required this.bikeId,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.cost,
    required this.status,
  });

  /// Creates a copy of this rental with the given fields replaced.
  Rental copyWith({
    String? id,
    String? bikeId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    double? cost,
    RentalStatus? status,
  }) {
    return Rental(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cost: cost ?? this.cost,
      status: status ?? this.status,
    );
  }

  /// Calculates the duration of the rental.
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  @override
  List<Object?> get props => [
    id,
    bikeId,
    userId,
    startTime,
    endTime,
    cost,
    status,
  ];
}
