import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/bike_model.dart';
import '../models/cached_map_data.dart';
import '../models/station_model.dart';

/// Cache key for bikes data.
const cachedBikesKey = 'CACHED_BIKES';

/// Cache key for stations data.
const cachedStationsKey = 'CACHED_STATIONS';

/// TTL for bikes cache (3 minutes).
const bikesCacheTtl = Duration(minutes: 3);

/// TTL for stations cache (10 minutes).
const stationsCacheTtl = Duration(minutes: 10);

/// Local data source for map data caching.
abstract class MapLocalDataSource {
  /// Returns the cached list of bikes.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<List<BikeModel>> getCachedBikes();

  /// Caches the given list of bikes with current timestamp.
  Future<void> cacheBikes(List<BikeModel> bikes);

  /// Returns true if bikes cache exists and is within TTL.
  Future<bool> isBikesCacheValid();

  /// Returns the cached list of stations.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<List<StationModel>> getCachedStations();

  /// Caches the given list of stations with current timestamp.
  Future<void> cacheStations(List<StationModel> stations);

  /// Returns true if stations cache exists and is within TTL.
  Future<bool> isStationsCacheValid();

  /// Invalidates both bikes and stations cache.
  ///
  /// This forces the next data request to fetch from network.
  Future<void> invalidateCache();
}

@LazySingleton(as: MapLocalDataSource)
class MapLocalDataSourceImpl implements MapLocalDataSource {
  final SharedPreferences sharedPreferences;

  MapLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<BikeModel>> getCachedBikes() async {
    final jsonString = sharedPreferences.getString(cachedBikesKey);
    if (jsonString == null) {
      throw CacheException();
    }
    final cachedData = CachedBikesData.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
    return cachedData.bikes;
  }

  @override
  Future<void> cacheBikes(List<BikeModel> bikes) async {
    final cachedData = CachedBikesData(bikes: bikes, cachedAt: DateTime.now());
    await sharedPreferences.setString(
      cachedBikesKey,
      jsonEncode(cachedData.toJson()),
    );
  }

  @override
  Future<bool> isBikesCacheValid() async {
    final jsonString = sharedPreferences.getString(cachedBikesKey);
    if (jsonString == null) {
      return false;
    }
    final cachedData = CachedBikesData.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
    return !cachedData.isExpired(bikesCacheTtl);
  }

  @override
  Future<List<StationModel>> getCachedStations() async {
    final jsonString = sharedPreferences.getString(cachedStationsKey);
    if (jsonString == null) {
      throw CacheException();
    }
    final cachedData = CachedStationsData.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
    return cachedData.stations;
  }

  @override
  Future<void> cacheStations(List<StationModel> stations) async {
    final cachedData = CachedStationsData(
      stations: stations,
      cachedAt: DateTime.now(),
    );
    await sharedPreferences.setString(
      cachedStationsKey,
      jsonEncode(cachedData.toJson()),
    );
  }

  @override
  Future<bool> isStationsCacheValid() async {
    final jsonString = sharedPreferences.getString(cachedStationsKey);
    if (jsonString == null) {
      return false;
    }
    final cachedData = CachedStationsData.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
    return !cachedData.isExpired(stationsCacheTtl);
  }

  @override
  Future<void> invalidateCache() async {
    await sharedPreferences.remove(cachedBikesKey);
    await sharedPreferences.remove(cachedStationsKey);
  }
}
