import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/bike.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/station.dart';
import '../../domain/usecases/get_nearby_bikes.dart';
import '../../domain/usecases/get_stations.dart';
import '../../domain/usecases/invalidate_map_cache.dart';

part 'map_event.dart';
part 'map_state.dart';

const String networkFailureMessage = 'No internet connection';
const String serverFailureMessage = 'Server error. Please try again later.';

@lazySingleton
class MapBloc extends Bloc<MapEvent, MapState> {
  final GetNearbyBikes getNearbyBikes;
  final GetStations getStations;
  final InvalidateMapCache invalidateMapCache;

  MapBloc({
    required this.getNearbyBikes,
    required this.getStations,
    required this.invalidateMapCache,
  }) : super(const MapInitial()) {
    on<LoadMapRequested>(_onLoadMapRequested);
    on<RefreshMapRequested>(_onRefreshMapRequested);
    on<SilentRefreshMapRequested>(_onSilentRefreshMapRequested);
    on<BikeSelected>(_onBikeSelected);
    on<StationSelected>(_onStationSelected);
    on<SelectionCleared>(_onSelectionCleared);
    on<BottomSheetDismissRequested>(_onBottomSheetDismissRequested);
  }

  Future<void> _onLoadMapRequested(
    LoadMapRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());

    final bikesResult = await getNearbyBikes(
      GetNearbyBikesParams(center: event.center, radiusKm: event.radiusKm),
    );

    // Check bikes result first
    final bikesEither = bikesResult.fold((failure) => null, (bikes) => bikes);

    if (bikesEither == null) {
      emit(
        MapError(
          _mapFailureToMessage(
            bikesResult.fold((f) => f, (_) => ServerFailure()),
          ),
        ),
      );
      return;
    }

    final stationsResult = await getStations(NoParams());

    stationsResult.fold(
      (failure) => emit(MapError(_mapFailureToMessage(failure))),
      (stations) => emit(
        MapLoaded(
          bikes: bikesEither,
          stations: stations,
          currentCenter: event.center,
          currentRadiusKm: event.radiusKm,
        ),
      ),
    );
  }

  Future<void> _onRefreshMapRequested(
    RefreshMapRequested event,
    Emitter<MapState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapLoaded) {
      return;
    }

    final center = currentState.currentCenter;
    final radiusKm = currentState.currentRadiusKm;

    if (center == null || radiusKm == null) {
      return;
    }

    emit(const MapLoading());

    // Invalidate cache if force refresh is requested
    await invalidateMapCache(NoParams());

    final bikesResult = await getNearbyBikes(
      GetNearbyBikesParams(center: center, radiusKm: radiusKm),
    );

    final bikesEither = bikesResult.fold((failure) => null, (bikes) => bikes);

    if (bikesEither == null) {
      emit(
        MapError(
          _mapFailureToMessage(
            bikesResult.fold((f) => f, (_) => ServerFailure()),
          ),
        ),
      );
      return;
    }

    final stationsResult = await getStations(NoParams());

    stationsResult.fold(
      (failure) => emit(MapError(_mapFailureToMessage(failure))),
      (stations) => emit(
        MapLoaded(
          bikes: bikesEither,
          stations: stations,
          currentCenter: center,
          currentRadiusKm: radiusKm,
        ),
      ),
    );
  }

  /// Silently refresh map data without showing loading indicator.
  /// Used for background polling - failures are silent, existing data is kept.
  Future<void> _onSilentRefreshMapRequested(
    SilentRefreshMapRequested event,
    Emitter<MapState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MapLoaded) {
      return;
    }

    final center = currentState.currentCenter;
    final radiusKm = currentState.currentRadiusKm;

    if (center == null || radiusKm == null) {
      return;
    }

    // NO MapLoading emission - silent refresh
    await invalidateMapCache(NoParams());

    final bikesResult = await getNearbyBikes(
      GetNearbyBikesParams(center: center, radiusKm: radiusKm),
    );

    final bikesEither = bikesResult.fold((failure) => null, (bikes) => bikes);

    // Silently fail if bikes fetch fails - keep existing data
    if (bikesEither == null) {
      return;
    }

    final stationsResult = await getStations(NoParams());

    stationsResult.fold(
      // Silently fail if stations fetch fails - keep existing data
      (_) {},
      (stations) {
        // Preserve selection by finding updated entities in fresh data
        Bike? updatedSelectedBike;
        Station? updatedSelectedStation;

        if (currentState.selectedBike != null) {
          updatedSelectedBike = bikesEither.cast<Bike?>().firstWhere(
                (b) => b?.id == currentState.selectedBike!.id,
                orElse: () => null,
              );
        }

        if (currentState.selectedStation != null) {
          updatedSelectedStation = stations.cast<Station?>().firstWhere(
                (s) => s?.id == currentState.selectedStation!.id,
                orElse: () => null,
              );
        }

        emit(
          currentState.copyWith(
            bikes: bikesEither,
            stations: stations,
            selectedBike: updatedSelectedBike,
            selectedStation: updatedSelectedStation,
            clearSelectedBike: updatedSelectedBike == null &&
                currentState.selectedBike != null,
            clearSelectedStation: updatedSelectedStation == null &&
                currentState.selectedStation != null,
          ),
        );
      },
    );
  }

  void _onBikeSelected(BikeSelected event, Emitter<MapState> emit) {
    final currentState = state;
    if (currentState is MapLoaded) {
      emit(
        currentState.copyWith(
          selectedBike: event.bike,
          clearSelectedStation: true,
        ),
      );
    }
  }

  void _onStationSelected(StationSelected event, Emitter<MapState> emit) {
    final currentState = state;
    if (currentState is MapLoaded) {
      emit(
        currentState.copyWith(
          selectedStation: event.station,
          clearSelectedBike: true,
        ),
      );
    }
  }

  void _onSelectionCleared(SelectionCleared event, Emitter<MapState> emit) {
    final currentState = state;
    if (currentState is MapLoaded) {
      emit(
        currentState.copyWith(
          clearSelectedBike: true,
          clearSelectedStation: true,
          isBottomSheetDismissing: false,
        ),
      );
    }
  }

  void _onBottomSheetDismissRequested(
    BottomSheetDismissRequested event,
    Emitter<MapState> emit,
  ) {
    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(isBottomSheetDismissing: true));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      NetworkFailure() => networkFailureMessage,
      ServerFailure() => serverFailureMessage,
      _ => 'An unexpected error occurred',
    };
  }
}
