import 'package:equatable/equatable.dart';

import 'location.dart';

/// Represents a bike docking station.
class Station extends Equatable {
  /// Unique identifier for the station.
  final String id;

  /// Display name of the station.
  final String name;

  /// Geographic location of the station.
  final Location location;

  /// Total capacity (number of bike stands).
  final int capacity;

  /// Number of bikes currently available at this station.
  final int availableBikes;

  /// Number of empty stands available for bike returns.
  final int availableStands;

  const Station({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.availableBikes,
    required this.availableStands,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    location,
    capacity,
    availableBikes,
    availableStands,
  ];
}
