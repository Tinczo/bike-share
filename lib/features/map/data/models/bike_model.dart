import '../../domain/entities/bike.dart';
import '../../domain/entities/bike_status.dart';
import '../../domain/entities/location.dart';
import 'location_model.dart';

/// Data model for [Bike] entity.
///
/// Handles JSON serialization/deserialization with backend field mapping.
class BikeModel extends Bike {
  const BikeModel({
    required super.id,
    required super.qrCode,
    required super.status,
    super.batteryLevel,
    required super.location,
    super.rangeKm,
    super.isPotentiallyDamaged,
  });

  /// Creates a [BikeModel] from a JSON map.
  ///
  /// Supports both backend format and normalized format (from toJson):
  /// - 'id_roweru' or 'id' -> id
  /// - 'kod_qr' or 'qrCode' -> qrCode
  /// - 'status' -> status (parsed from uppercase string)
  /// - 'poziom_baterii' or 'batteryLevel' -> batteryLevel
  /// - 'lokalizacja_szerokosc', 'lokalizacja_dlugosc' or 'location' -> location
  /// - 'zasieg_km' or 'rangeKm' -> rangeKm
  factory BikeModel.fromJson(Map<String, dynamic> json) {
    // Support nested location object from toJson format
    final locationJson = json['location'] as Map<String, dynamic>?;
    final Location location;
    if (locationJson != null) {
      location = LocationModel.fromJson(locationJson);
    } else {
      location = LocationModel.fromJson(json);
    }

    return BikeModel(
      id: (json['id_roweru'] ?? json['id']) as String,
      qrCode: (json['kod_qr'] ?? json['qrCode']) as String,
      status: _parseStatus(json['status'] as String),
      batteryLevel: (json['poziom_baterii'] ?? json['batteryLevel']) as int?,
      location: location,
      rangeKm: (json['zasieg_km'] ?? json['rangeKm']) as int?,
      isPotentiallyDamaged:
          (json['potencjalnie_uszkodzony'] ??
                  json['isPotentiallyDamaged'] ??
                  false)
              as bool,
    );
  }

  /// Parses a status string to [BikeStatus] enum.
  static BikeStatus _parseStatus(String status) {
    return switch (status.toUpperCase()) {
      'AVAILABLE' => BikeStatus.available,
      'RENTED' => BikeStatus.rented,
      'RESERVED' => BikeStatus.reserved,
      'BROKEN' => BikeStatus.broken,
      _ => BikeStatus.available,
    };
  }

  /// Returns the location as a [LocationModel].
  LocationModel get locationModel => LocationModel.fromEntity(location);

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qrCode': qrCode,
      'status': status.name,
      'batteryLevel': batteryLevel,
      'location': locationModel.toJson(),
      'rangeKm': rangeKm,
      'isPotentiallyDamaged': isPotentiallyDamaged,
    };
  }
}
