import 'package:equatable/equatable.dart';

/// Represents a completed rental in the user's history.
class RentalHistoryItem extends Equatable {
  /// Unique identifier for the rental.
  final String id;

  /// ID of the rented bike.
  final String bikeId;

  /// Start time of the rental.
  final DateTime startTime;

  /// End time of the rental.
  final DateTime endTime;

  /// Total cost of the rental in PLN.
  final double cost;

  /// Name of the station where the rental started.
  final String? startStationName;

  /// Name of the station where the rental ended.
  final String? endStationName;

  const RentalHistoryItem({
    required this.id,
    required this.bikeId,
    required this.startTime,
    required this.endTime,
    required this.cost,
    this.startStationName,
    this.endStationName,
  });

  /// Calculates the duration of the rental.
  Duration get duration => endTime.difference(startTime);

  /// Creates a copy of this item with the given fields replaced.
  RentalHistoryItem copyWith({
    String? id,
    String? bikeId,
    DateTime? startTime,
    DateTime? endTime,
    double? cost,
    String? startStationName,
    String? endStationName,
  }) {
    return RentalHistoryItem(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cost: cost ?? this.cost,
      startStationName: startStationName ?? this.startStationName,
      endStationName: endStationName ?? this.endStationName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bikeId,
    startTime,
    endTime,
    cost,
    startStationName,
    endStationName,
  ];
}
