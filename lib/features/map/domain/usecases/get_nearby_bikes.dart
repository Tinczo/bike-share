import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/bike.dart';
import '../entities/location.dart';
import '../repositories/map_repository.dart';

/// Retrieves bikes near a specific location.
@lazySingleton
class GetNearbyBikes implements UseCase<List<Bike>, GetNearbyBikesParams> {
  final MapRepository repository;

  GetNearbyBikes(this.repository);

  @override
  FutureEither<List<Bike>> call(GetNearbyBikesParams params) async {
    return await repository.getNearbyBikes(
      center: params.center,
      radiusKm: params.radiusKm,
    );
  }
}

/// Parameters for [GetNearbyBikes] use case.
class GetNearbyBikesParams extends Equatable {
  /// Center point of the search area.
  final Location center;

  /// Search radius in kilometers.
  final double radiusKm;

  const GetNearbyBikesParams({required this.center, required this.radiusKm});

  @override
  List<Object?> get props => [center, radiusKm];
}
