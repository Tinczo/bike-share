import '../../domain/entities/location.dart';
import '../../domain/entities/station.dart';
import 'location_model.dart';

/// Data model for [Station] entity.
///
/// Handles JSON serialization/deserialization with backend field mapping.
class StationModel extends Station {
  const StationModel({
    required super.id,
    required super.name,
    required super.location,
    required super.capacity,
    required super.availableBikes,
    required super.availableStands,
  });

  /// Creates a [StationModel] from a JSON map.
  ///
  /// Supports both backend format and normalized format (from toJson):
  /// - 'id_stacji' or 'id' -> id
  /// - 'nazwa' or 'name' -> name
  /// - 'lokalizacja_szerokosc', 'lokalizacja_dlugosc' or 'location' -> location
  /// - 'pojemnosc' or 'capacity' -> capacity
  /// - 'dostepne_rowery' or 'availableBikes' -> availableBikes
  /// - 'dostepne_stojaki' or 'availableStands' -> availableStands
  factory StationModel.fromJson(Map<String, dynamic> json) {
    // Support nested location object from toJson format
    final locationJson = json['location'] as Map<String, dynamic>?;
    final Location location;
    if (locationJson != null) {
      location = LocationModel.fromJson(locationJson);
    } else {
      location = LocationModel.fromJson(json);
    }

    return StationModel(
      id: (json['id_stacji'] ?? json['id']) as String,
      name: (json['nazwa'] ?? json['name']) as String,
      location: location,
      capacity: (json['pojemnosc'] ?? json['capacity']) as int,
      availableBikes:
          (json['dostepne_rowery'] ?? json['availableBikes']) as int,
      availableStands:
          (json['dostepne_stojaki'] ?? json['availableStands']) as int,
    );
  }

  /// Returns the location as a [LocationModel].
  LocationModel get locationModel => LocationModel.fromEntity(location);

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': locationModel.toJson(),
      'capacity': capacity,
      'availableBikes': availableBikes,
      'availableStands': availableStands,
    };
  }
}
