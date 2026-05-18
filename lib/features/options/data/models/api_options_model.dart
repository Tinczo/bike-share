import '../../domain/entities/api_options.dart';

/// Data model for API options, with JSON serialization support.
class ApiOptionsModel extends ApiOptions {
  const ApiOptionsModel({
    required super.sameForAll,
    required super.globalBaseUrl,
    required super.authBaseUrl,
    required super.mapBaseUrl,
    required super.rentalBaseUrl,
    required super.walletBaseUrl,
    required super.accountBaseUrl,
  });

  /// Creates default model with all URLs set to default.
  const ApiOptionsModel.defaults()
      : super(
          sameForAll: true,
          globalBaseUrl: defaultBaseUrl,
          authBaseUrl: defaultBaseUrl,
          mapBaseUrl: defaultBaseUrl,
          rentalBaseUrl: defaultBaseUrl,
          walletBaseUrl: defaultBaseUrl,
          accountBaseUrl: defaultBaseUrl,
        );

  /// Creates a model from a JSON map.
  factory ApiOptionsModel.fromJson(Map<String, dynamic> json) {
    return ApiOptionsModel(
      sameForAll: json['sameForAll'] as bool? ?? true,
      globalBaseUrl: json['globalBaseUrl'] as String? ?? defaultBaseUrl,
      authBaseUrl: json['authBaseUrl'] as String? ?? defaultBaseUrl,
      mapBaseUrl: json['mapBaseUrl'] as String? ?? defaultBaseUrl,
      rentalBaseUrl: json['rentalBaseUrl'] as String? ?? defaultBaseUrl,
      walletBaseUrl: json['walletBaseUrl'] as String? ?? defaultBaseUrl,
      accountBaseUrl: json['accountBaseUrl'] as String? ?? defaultBaseUrl,
    );
  }

  /// Creates a model from an entity.
  factory ApiOptionsModel.fromEntity(ApiOptions entity) {
    return ApiOptionsModel(
      sameForAll: entity.sameForAll,
      globalBaseUrl: entity.globalBaseUrl,
      authBaseUrl: entity.authBaseUrl,
      mapBaseUrl: entity.mapBaseUrl,
      rentalBaseUrl: entity.rentalBaseUrl,
      walletBaseUrl: entity.walletBaseUrl,
      accountBaseUrl: entity.accountBaseUrl,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'sameForAll': sameForAll,
      'globalBaseUrl': globalBaseUrl,
      'authBaseUrl': authBaseUrl,
      'mapBaseUrl': mapBaseUrl,
      'rentalBaseUrl': rentalBaseUrl,
      'walletBaseUrl': walletBaseUrl,
      'accountBaseUrl': accountBaseUrl,
    };
  }
}
