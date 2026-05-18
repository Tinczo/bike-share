import '../../domain/entities/rental.dart';
import '../../domain/entities/rental_status.dart';

/// Data model for [Rental] entity.
///
/// Handles JSON serialization/deserialization with backend field mapping.
class RentalModel extends Rental {
  const RentalModel({
    required super.id,
    required super.bikeId,
    required super.userId,
    required super.startTime,
    super.endTime,
    required super.cost,
    required super.status,
  });

  /// Creates a [RentalModel] from a JSON map.
  ///
  /// Supports both Polish backend format and English format.
  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: (json['id_wypozyczenia'] ?? json['id']) as String,
      bikeId: (json['id_roweru'] ?? json['bikeId']) as String,
      userId: (json['id_uzytkownika'] ?? json['userId'] ?? 'unknown') as String,
      startTime: _parseDateTime(
        json['data_rozpoczecia'] ??
            json['czas_rozpoczecia'] ??
            json['startTime'],
      ),
      endTime: _parseNullableDateTime(
        json['data_zakonczenia'] ?? json['czas_zakonczenia'] ?? json['endTime'],
      ),
      cost: _parseDoubleOrZero(
        json['koszt_calkowity'] ?? json['koszt'] ?? json['cost'],
      ),
      status: _parseStatus(json['status'] as String),
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bikeId': bikeId,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'cost': cost,
      'status': _statusToString(status),
    };
  }

  /// Creates a [RentalModel] from a [Rental] entity.
  factory RentalModel.fromEntity(Rental rental) {
    return RentalModel(
      id: rental.id,
      bikeId: rental.bikeId,
      userId: rental.userId,
      startTime: rental.startTime,
      endTime: rental.endTime,
      cost: rental.cost,
      status: rental.status,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.parse(value).toLocal();
    }
    if (value is DateTime) {
      return value.toLocal();
    }
    throw FormatException('Cannot parse DateTime from: $value');
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return DateTime.parse(value).toLocal();
    }
    if (value is DateTime) {
      return value.toLocal();
    }
    return null;
  }

  static double _parseDoubleOrZero(dynamic value) {
    if (value == null) {
      return 0.0;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

  static RentalStatus _parseStatus(String status) {
    return switch (status.toUpperCase()) {
      'ACTIVE' || 'AKTYWNE' => RentalStatus.active,
      'PAUSED' || 'WSTRZYMANE' => RentalStatus.paused,
      'FINISHED' || 'ZAKONCZONE' => RentalStatus.finished,
      _ => RentalStatus.active,
    };
  }

  static String _statusToString(RentalStatus status) {
    return switch (status) {
      RentalStatus.active => 'ACTIVE',
      RentalStatus.paused => 'PAUSED',
      RentalStatus.finished => 'FINISHED',
    };
  }
}
