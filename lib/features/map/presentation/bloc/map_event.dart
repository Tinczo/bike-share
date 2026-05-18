part of 'map_bloc.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load map data (bikes and stations).
final class LoadMapRequested extends MapEvent {
  final Location center;
  final double radiusKm;

  const LoadMapRequested({required this.center, required this.radiusKm});

  @override
  List<Object?> get props => [center, radiusKm];
}

/// Event to refresh map data using the current center and radius.
final class RefreshMapRequested extends MapEvent {
  /// If true, invalidates cache before fetching fresh data from network.

  const RefreshMapRequested();

  @override
  List<Object?> get props => [];
}

/// Event when a bike marker is tapped.
final class BikeSelected extends MapEvent {
  final Bike bike;

  const BikeSelected(this.bike);

  @override
  List<Object?> get props => [bike];
}

/// Event when a station marker is tapped.
final class StationSelected extends MapEvent {
  final Station station;

  const StationSelected(this.station);

  @override
  List<Object?> get props => [station];
}

/// Event to clear the current selection.
final class SelectionCleared extends MapEvent {
  const SelectionCleared();
}

/// Event to request bottom sheet dismissal with animation.
final class BottomSheetDismissRequested extends MapEvent {
  const BottomSheetDismissRequested();
}

/// Silently refresh map data without showing loading indicator.
/// Used for background polling to keep map data fresh.
final class SilentRefreshMapRequested extends MapEvent {
  const SilentRefreshMapRequested();
}
