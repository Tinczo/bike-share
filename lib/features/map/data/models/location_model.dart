import '../../domain/entities/location.dart';

/// Data model for [Location] entity.
///
/// Handles JSON serialization/deserialization with backend field mapping.
class LocationModel extends Location {
  const LocationModel({required super.latitude, required super.longitude});

  /// Creates a [LocationModel] from a JSON map.
  ///
  /// Supports multiple field naming conventions:
  /// - Backend format: 'lokalizacja_szerokosc', 'lokalizacja_dlugosc'
  /// - Alternative: 'szer_geo', 'dl_geo'
  /// - Standard: 'latitude', 'longitude'
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final lat =
        json['lokalizacja_szerokosc'] ?? json['szer_geo'] ?? json['latitude'];
    final lng =
        json['lokalizacja_dlugosc'] ?? json['dl_geo'] ?? json['longitude'];

    return LocationModel(
      latitude: (lat as num).toDouble(),
      longitude: (lng as num).toDouble(),
    );
  }

  /// Creates a [LocationModel] from a [Location] entity.
  factory LocationModel.fromEntity(Location location) {
    return LocationModel(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}
