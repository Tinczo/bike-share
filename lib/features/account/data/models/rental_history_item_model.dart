import '../../domain/entities/rental_history_item.dart';

/// Data model for [RentalHistoryItem] entity.
///
/// Handles JSON serialization/deserialization with backend field mapping.
class RentalHistoryItemModel extends RentalHistoryItem {
  const RentalHistoryItemModel({
    required super.id,
    required super.bikeId,
    required super.startTime,
    required super.endTime,
    required super.cost,
    super.startStationName,
    super.endStationName,
  });

  /// Creates a [RentalHistoryItemModel] from a JSON map.
  ///
  /// Supports both Polish backend format and English format.
  factory RentalHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return RentalHistoryItemModel(
      id: (json['id_wypozyczenia'] ?? json['id']) as String,
      bikeId: (json['id_roweru'] ?? json['bikeId']) as String,
      startTime: _parseDateTime(
        json['data_rozpoczecia'] ??
            json['czas_rozpoczecia'] ??
            json['startTime'],
      ),
      endTime: _parseDateTime(
        json['data_zakonczenia'] ?? json['czas_zakonczenia'] ?? json['endTime'],
      ),
      cost: _parseDouble(
        json['koszt_calkowity'] ?? json['koszt'] ?? json['cost'],
      ),
      startStationName: json['nazwa_stacji_start'] ?? json['startStationName'],
      endStationName: json['nazwa_stacji_koniec'] ?? json['endStationName'],
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bikeId': bikeId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'cost': cost,
      'startStationName': startStationName,
      'endStationName': endStationName,
    };
  }

  /// Creates a [RentalHistoryItemModel] from a [RentalHistoryItem] entity.
  factory RentalHistoryItemModel.fromEntity(RentalHistoryItem entity) {
    return RentalHistoryItemModel(
      id: entity.id,
      bikeId: entity.bikeId,
      startTime: entity.startTime,
      endTime: entity.endTime,
      cost: entity.cost,
      startStationName: entity.startStationName,
      endStationName: entity.endStationName,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) return DateTime.parse(value).toLocal();
    if (value is DateTime) return value.toLocal();
    throw FormatException('Cannot parse DateTime from: $value');
  }

  static double _parseDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return 0.0;
  }
}
