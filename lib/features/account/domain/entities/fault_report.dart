import 'package:equatable/equatable.dart';

import 'fault_type.dart';

/// Represents a fault report submitted by a user for a bike.
class FaultReport extends Equatable {
  /// Unique identifier for the fault report.
  final String id;

  /// ID of the bike with the reported fault.
  final String bikeId;

  /// ID of the user who submitted the report.
  final String userId;

  /// Type of fault reported.
  final FaultType type;

  /// Optional description, required for [FaultType.other].
  final String? description;

  /// Timestamp when the report was submitted.
  final DateTime? timestamp;

  /// Whether the fault has been verified by staff.
  final bool isVerified;

  /// Whether the fault was confirmed as valid.
  final bool isConfirmed;

  /// Date when the fault was verified.
  final DateTime? verificationDate;

  /// Reward amount in PLN if the report was confirmed.
  final double? rewardAmount;

  const FaultReport({
    required this.id,
    required this.bikeId,
    required this.userId,
    required this.type,
    this.description,
    this.timestamp,
    required this.isVerified,
    required this.isConfirmed,
    this.verificationDate,
    this.rewardAmount,
  });

  /// Creates a copy of this fault report with the given fields replaced.
  FaultReport copyWith({
    String? id,
    String? bikeId,
    String? userId,
    FaultType? type,
    String? description,
    DateTime? timestamp,
    bool? isVerified,
    bool? isConfirmed,
    DateTime? verificationDate,
    double? rewardAmount,
  }) {
    return FaultReport(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isVerified: isVerified ?? this.isVerified,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      verificationDate: verificationDate ?? this.verificationDate,
      rewardAmount: rewardAmount ?? this.rewardAmount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bikeId,
    userId,
    type,
    description,
    timestamp,
    isVerified,
    isConfirmed,
    verificationDate,
    rewardAmount,
  ];
}
