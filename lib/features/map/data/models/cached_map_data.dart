import 'bike_model.dart';
import 'station_model.dart';

/// Cached bikes data with timestamp for TTL-based invalidation.
class CachedBikesData {
  final List<BikeModel> bikes;
  final DateTime cachedAt;

  CachedBikesData({required this.bikes, required this.cachedAt});

  /// Returns true if the cache is older than the given TTL.
  bool isExpired(Duration ttl) => DateTime.now().difference(cachedAt) > ttl;

  /// Creates a [CachedBikesData] from a JSON map.
  factory CachedBikesData.fromJson(Map<String, dynamic> json) {
    return CachedBikesData(
      bikes: (json['bikes'] as List<dynamic>)
          .map((e) => BikeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'bikes': bikes.map((b) => b.toJson()).toList(),
      'cachedAt': cachedAt.toUtc().toIso8601String(),
    };
  }
}

/// Cached stations data with timestamp for TTL-based invalidation.
class CachedStationsData {
  final List<StationModel> stations;
  final DateTime cachedAt;

  CachedStationsData({required this.stations, required this.cachedAt});

  /// Returns true if the cache is older than the given TTL.
  bool isExpired(Duration ttl) => DateTime.now().difference(cachedAt) > ttl;

  /// Creates a [CachedStationsData] from a JSON map.
  factory CachedStationsData.fromJson(Map<String, dynamic> json) {
    return CachedStationsData(
      stations: (json['stations'] as List<dynamic>)
          .map((e) => StationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'stations': stations.map((s) => s.toJson()).toList(),
      'cachedAt': cachedAt.toUtc().toIso8601String(),
    };
  }
}
