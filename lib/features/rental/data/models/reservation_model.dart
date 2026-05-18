import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_status.dart';

/// Data model for [Reservation] entity.
///
/// Handles JSON serialization/deserialization with backend field mapping.
class ReservationModel extends Reservation {
  const ReservationModel({
    required super.id,
    required super.bikeId,
    required super.userId,
    required super.createdAt,
    required super.expiresAt,
    required super.status,
  });

  /// Creates a [ReservationModel] from a JSON map.
  ///
  /// Supports both Polish backend format and English format.
  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: (json['id_rezerwacji'] ?? json['id']) as String,
      bikeId: (json['id_roweru'] ?? json['bikeId']) as String,
      userId: (json['id_uzytkownika'] ?? json['userId'] ?? 'unknown') as String,
      createdAt: _parseDateTime(
        json['data_utworzenia'] ?? json['czas_utworzenia'] ?? json['createdAt'],
      ),
      expiresAt: _parseDateTime(
        json['data_wygasniecia'] ??
            json['czas_wygasniecia'] ??
            json['expiresAt'],
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
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'status': _statusToString(status),
    };
  }

  /// Creates a [ReservationModel] from a [Reservation] entity.
  factory ReservationModel.fromEntity(Reservation reservation) {
    return ReservationModel(
      id: reservation.id,
      bikeId: reservation.bikeId,
      userId: reservation.userId,
      createdAt: reservation.createdAt,
      expiresAt: reservation.expiresAt,
      status: reservation.status,
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

  static ReservationStatus _parseStatus(String status) {
    return switch (status.toUpperCase()) {
      'ACTIVE' || 'AKTYWNA' => ReservationStatus.active,
      'EXPIRED' || 'WYGASLA' => ReservationStatus.expired,
      'CANCELLED' || 'ANULOWANA' => ReservationStatus.cancelled,
      'CONVERTED' || 'PRZEKSZTALCONA' => ReservationStatus.converted,
      _ => ReservationStatus.active,
    };
  }

  static String _statusToString(ReservationStatus status) {
    return switch (status) {
      ReservationStatus.active => 'ACTIVE',
      ReservationStatus.expired => 'EXPIRED',
      ReservationStatus.cancelled => 'CANCELLED',
      ReservationStatus.converted => 'CONVERTED',
    };
  }
}
