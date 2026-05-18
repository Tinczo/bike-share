import 'package:dartz/dartz.dart';

import '../../../../core/type_defs.dart';
import '../entities/bike.dart';
import '../entities/location.dart';
import '../entities/station.dart';

/// Contract for map-related data operations.
///
/// This interface defines all map-related operations that must be
/// implemented by the data layer.
abstract class MapRepository {
  /// Retrieves bikes near a specific location within a given radius.
  ///
  /// [center] is the center point for the search.
  /// [radiusKm] is the search radius in kilometers.
  ///
  /// Returns [List<Bike>] on success or [Failure] on error.
  FutureEither<List<Bike>> getNearbyBikes({
    required Location center,
    required double radiusKm,
  });

  // TODO: Think about fetching with a given radius.
  /// Retrieves all bike stations.
  ///
  /// Returns [List<Station>] on success or [Failure] on error.
  FutureEither<List<Station>> getStations();

  /// Invalidates the local map data cache.
  ///
  /// This forces subsequent calls to [getNearbyBikes] and [getStations]
  /// to fetch fresh data from the network.
  ///
  /// Returns [Unit] on success or [Failure] on error.
  FutureEither<Unit> invalidateCache();
}
