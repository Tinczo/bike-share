import 'package:equatable/equatable.dart';

import 'bike_status.dart';
import 'location.dart';

/// Represents a bike in the fleet management system.
class Bike extends Equatable {
  /// Unique identifier for the bike.
  final String id;

  /// QR code used for bike identification/scanning.
  final String qrCode;

  /// Current status of the bike.
  final BikeStatus status;

  /// Battery level percentage (for electric bikes).
  final int? batteryLevel;

  /// Current geographic location of the bike.
  final Location location;

  /// Estimated range in kilometers (for electric bikes).
  final int? rangeKm;

  /// Indicates if the bike has been flagged as potentially damaged.
  final bool isPotentiallyDamaged;

  const Bike({
    required this.id,
    required this.qrCode,
    required this.status,
    this.batteryLevel,
    required this.location,
    this.rangeKm,
    this.isPotentiallyDamaged = false,
  });

  @override
  List<Object?> get props => [
    id,
    qrCode,
    status,
    batteryLevel,
    location,
    rangeKm,
    isPotentiallyDamaged,
  ];
}
