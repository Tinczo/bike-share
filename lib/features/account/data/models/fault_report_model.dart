import '../../domain/entities/fault_report.dart';
import '../../domain/entities/fault_type.dart';

/// Data model for [FaultReport] entity.
///
/// Handles JSON serialization/deserialization with backend field mapping.
class FaultReportModel extends FaultReport {
  const FaultReportModel({
    required super.id,
    required super.bikeId,
    required super.userId,
    required super.type,
    super.description,
    super.timestamp,
    required super.isVerified,
    required super.isConfirmed,
    super.verificationDate,
    super.rewardAmount,
  });

  /// Creates a [FaultReportModel] from a JSON map.
  ///
  /// Supports both Polish backend format and English format.
  factory FaultReportModel.fromJson(Map<String, dynamic> json) {
    return FaultReportModel(
      id: (json['id_zgloszenia'] ?? json['id']) as String,
      bikeId: (json['id_roweru'] ?? json['bikeId']) as String,
      userId: (json['id_uzytkownika'] ?? json['userId']) as String,
      type: _parseType(json['typ_usterki'] ?? json['type']),
      description: json['opis'] ?? json['description'],
      timestamp: _parseNullableDateTime(
        json['data_zgloszenia'] ?? json['timestamp'],
      ),
      isVerified:
          (json['czy_zweryfikowane'] ?? json['isVerified'] ?? false) as bool,
      isConfirmed:
          (json['czy_potwierdzone'] ?? json['isConfirmed'] ?? false) as bool,
      verificationDate: _parseNullableDateTime(
        json['data_weryfikacji'] ?? json['verificationDate'],
      ),
      rewardAmount: _parseNullableDouble(
        json['kwota_nagrody'] ?? json['rewardAmount'],
      ),
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bikeId': bikeId,
      'userId': userId,
      'type': type.apiValue,
      'description': description,
      'timestamp': timestamp?.toIso8601String(),
      'isVerified': isVerified,
      'isConfirmed': isConfirmed,
      'verificationDate': verificationDate?.toIso8601String(),
      'rewardAmount': rewardAmount,
    };
  }

  /// Creates a [FaultReportModel] from a [FaultReport] entity.
  factory FaultReportModel.fromEntity(FaultReport entity) {
    return FaultReportModel(
      id: entity.id,
      bikeId: entity.bikeId,
      userId: entity.userId,
      type: entity.type,
      description: entity.description,
      timestamp: entity.timestamp,
      isVerified: entity.isVerified,
      isConfirmed: entity.isConfirmed,
      verificationDate: entity.verificationDate,
      rewardAmount: entity.rewardAmount,
    );
  }

  static FaultType _parseType(dynamic value) {
    if (value == null) return FaultType.other;
    return FaultTypeExtension.fromApiValue(value as String);
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.parse(value).toLocal();
    if (value is DateTime) return value.toLocal();
    return null;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return null;
  }
}
