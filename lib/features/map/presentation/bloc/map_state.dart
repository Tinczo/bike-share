part of 'map_bloc.dart';

sealed class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
final class MapInitial extends MapState {
  const MapInitial();
}

/// State when map data is being loaded.
final class MapLoading extends MapState {
  const MapLoading();
}

/// State when map data is successfully loaded.
final class MapLoaded extends MapState {
  final List<Bike> bikes;
  final List<Station> stations;
  final Bike? selectedBike;
  final Station? selectedStation;
  final Location? currentCenter;
  final double? currentRadiusKm;
  final bool isBottomSheetDismissing;

  const MapLoaded({
    required this.bikes,
    required this.stations,
    this.selectedBike,
    this.selectedStation,
    this.currentCenter,
    this.currentRadiusKm,
    this.isBottomSheetDismissing = false,
  });

  /// Creates a copy of this state with optional overrides.
  MapLoaded copyWith({
    List<Bike>? bikes,
    List<Station>? stations,
    Bike? selectedBike,
    Station? selectedStation,
    Location? currentCenter,
    double? currentRadiusKm,
    bool clearSelectedBike = false,
    bool clearSelectedStation = false,
    bool? isBottomSheetDismissing,
  }) {
    return MapLoaded(
      bikes: bikes ?? this.bikes,
      stations: stations ?? this.stations,
      selectedBike: clearSelectedBike
          ? null
          : selectedBike ?? this.selectedBike,
      selectedStation: clearSelectedStation
          ? null
          : selectedStation ?? this.selectedStation,
      currentCenter: currentCenter ?? this.currentCenter,
      currentRadiusKm: currentRadiusKm ?? this.currentRadiusKm,
      isBottomSheetDismissing:
          isBottomSheetDismissing ?? this.isBottomSheetDismissing,
    );
  }

  @override
  List<Object?> get props => [
    bikes,
    stations,
    selectedBike,
    selectedStation,
    currentCenter,
    currentRadiusKm,
    isBottomSheetDismissing,
  ];
}

/// State when an error occurs.
final class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}
