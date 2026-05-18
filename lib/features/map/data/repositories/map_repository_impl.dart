import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/type_defs.dart';
import '../../domain/entities/bike.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/station.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_local_datasource.dart';
import '../datasources/map_remote_datasource.dart';

final _log = Logger('MapRepositoryImpl');

@LazySingleton(as: MapRepository)
class MapRepositoryImpl implements MapRepository {
  final MapRemoteDataSource remoteDataSource;
  final MapLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MapRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  FutureEither<List<Bike>> getNearbyBikes({
    required Location center,
    required double radiusKm,
  }) async {
    _log.info('getNearbyBikes called');

    // Step 1: Check cache first
    try {
      final isCacheValid = await localDataSource.isBikesCacheValid();
      _log.info('Bikes cache valid: $isCacheValid');
      if (isCacheValid) {
        final cachedBikes = await localDataSource.getCachedBikes();
        _log.info('Returning ${cachedBikes.length} bikes from cache');
        return Right(cachedBikes);
      }
    } on CacheException catch (e) {
      _log.warning('Cache exception while checking bikes: $e');
    }

    // Step 2: Cache invalid - try network if online
    final isConnected = await networkInfo.isConnected;
    _log.info('Network connected: $isConnected');
    if (isConnected) {
      try {
        _log.info('Fetching bikes from remote...');
        final bikes = await remoteDataSource.getNearbyBikes(
          latitude: center.latitude,
          longitude: center.longitude,
          radiusKm: radiusKm,
        );
        _log.info('Received ${bikes.length} bikes from remote');
        await localDataSource.cacheBikes(bikes);
        _log.info('Bikes cached successfully');
        return Right(bikes);
      } on ServerException catch (e) {
        _log.severe('Server exception: $e');
        return Left(CacheFailure());
      }
    }

    // Step 3: Offline and cache invalid
    _log.warning('Offline and cache invalid - returning CacheFailure');
    return Left(CacheFailure());
  }

  @override
  FutureEither<List<Station>> getStations() async {
    _log.info('getStations called');

    // Step 1: Check cache first
    try {
      final isCacheValid = await localDataSource.isStationsCacheValid();
      _log.info('Stations cache valid: $isCacheValid');
      if (isCacheValid) {
        final cachedStations = await localDataSource.getCachedStations();
        _log.info('Returning ${cachedStations.length} stations from cache');
        return Right(cachedStations);
      }
    } on CacheException catch (e) {
      _log.warning('Cache exception while checking stations: $e');
    }

    // Step 2: Cache invalid - try network if online
    final isConnected = await networkInfo.isConnected;
    _log.info('Network connected: $isConnected');
    if (isConnected) {
      try {
        _log.info('Fetching stations from remote...');
        final stations = await remoteDataSource.getStations();
        _log.info('Received ${stations.length} stations from remote');
        await localDataSource.cacheStations(stations);
        _log.info('Stations cached successfully');
        return Right(stations);
      } on ServerException catch (e) {
        _log.severe('Server exception: $e');
        return Left(CacheFailure());
      }
    }

    // Step 3: Offline and cache invalid
    _log.warning('Offline and cache invalid - returning CacheFailure');
    return Left(CacheFailure());
  }

  @override
  FutureEither<Unit> invalidateCache() async {
    _log.info('invalidateCache called');
    try {
      await localDataSource.invalidateCache();
      _log.info('Cache invalidated successfully');
      return const Right(unit);
    } on CacheException catch (e) {
      _log.severe('Failed to invalidate cache: $e');
      return Left(CacheFailure());
    }
  }
}
