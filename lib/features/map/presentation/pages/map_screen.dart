import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../rental/presentation/bloc/rental_bloc.dart';
import '../../../rental/presentation/bloc/reservation_bloc.dart';
import '../../domain/entities/bike.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/station.dart';
import '../bloc/map_bloc.dart';
import '../widgets/widgets.dart';

/// Main map screen displaying bikes and stations.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch events only once when screen is first created
    // (not on every rebuild like in build() method)
    sl<RentalBloc>().add(const ActiveRentalLoaded());
    sl<ReservationBloc>().add(const ActiveReservationLoaded());

    // Initialize map if not already loaded
    final mapBloc = sl<MapBloc>();
    if (mapBloc.state is MapInitial) {
      mapBloc.add(
        const LoadMapRequested(
          // Default center: Wrocław, Poland
          center: Location(latitude: 51.1079, longitude: 17.0385),
          radiusKm: 5.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<MapBloc>()),
        BlocProvider.value(value: sl<RentalBloc>()),
        BlocProvider.value(value: sl<ReservationBloc>()),
      ],
      child: const _MapScreenContent(),
    );
  }
}

class _MapScreenContent extends StatefulWidget {
  const _MapScreenContent();

  @override
  State<_MapScreenContent> createState() => _MapScreenContentState();
}

class _MapScreenContentState extends State<_MapScreenContent> {
  final MapController _mapController = MapController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // TODO: Re-enable background refresh once bottom sheet animation issue is fixed
    // _startBackgroundRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // TODO: Re-enable once bottom sheet animation interruption issue is resolved
  // void _startBackgroundRefresh() {
  //   _refreshTimer = Timer.periodic(
  //     const Duration(seconds: 3),
  //     (_) => context.read<MapBloc>().add(const SilentRefreshMapRequested()),
  //   );
  // }

  void _clearSelection() {
    context.read<MapBloc>().add(const SelectionCleared());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BikeShare'),
        actions: [
          BlocBuilder<MapBloc, MapState>(
            builder: (context, state) {
              return IconButton(
                onPressed: state is MapLoading
                    ? null
                    : () => context.read<MapBloc>().add(
                        const RefreshMapRequested(),
                      ),
                icon: state is MapLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Refresh',
              );
            },
          ),
        ],
      ),
      drawer: const MapDrawer(),
      body: Stack(
        children: [
          // Main map content with BlocConsumer
          BlocConsumer<MapBloc, MapState>(
            listener: (context, state) {
              if (state is MapError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  _buildMap(context, state),
                  if (state is MapLoading) _buildLoadingOverlay(),
                  _buildLocationButton(context, state),
                ],
              );
            },
          ),
          // Active rentals bottom sheet with QR button (always visible)
          const ActiveRentalsBottomSheet(),
          // Bike/station bottom sheets OUTSIDE the main BlocConsumer
          // so they don't get recreated on every map state change.
          // Their own buildWhen controls when they rebuild.
          _BikeBottomSheetBuilder(onClose: _clearSelection),
          _StationBottomSheetBuilder(onClose: _clearSelection),
        ],
      ),
    );
  }

  Widget _buildLocationButton(BuildContext context, MapState state) {
    if (state is! MapLoaded) return const SizedBox.shrink();

    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _centerOnUser(context),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Icon(
                  Icons.navigation_rounded,
                  color: AppPalette.primaryBlue,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context, MapState state) {
    final bikes = state is MapLoaded ? state.bikes : <Bike>[];
    final stations = state is MapLoaded ? state.stations : <Station>[];
    final selectedBike = state is MapLoaded ? state.selectedBike : null;
    final selectedStation = state is MapLoaded ? state.selectedStation : null;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(51.1079, 17.0385),
        initialZoom: 14,
        onTap: (tapPosition, latLng) {
          context.read<MapBloc>().add(const BottomSheetDismissRequested());
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.bike_app',
        ),
        MarkerLayer(
          markers: [
            ..._buildBikeMarkers(context, bikes, selectedBike),
            ..._buildStationMarkers(context, stations, selectedStation),
          ],
        ),
      ],
    );
  }

  List<Marker> _buildBikeMarkers(
    BuildContext context,
    List<Bike> bikes,
    Bike? selectedBike,
  ) {
    return bikes.map((bike) {
      return Marker(
        point: LatLng(bike.location.latitude, bike.location.longitude),
        width: 40,
        height: 40,
        rotate: false,
        child: BikeMarker(
          bike: bike,
          isSelected: selectedBike?.id == bike.id,
          onTap: () => context.read<MapBloc>().add(BikeSelected(bike)),
        ),
      );
    }).toList();
  }

  List<Marker> _buildStationMarkers(
    BuildContext context,
    List<Station> stations,
    Station? selectedStation,
  ) {
    return stations.map((station) {
      return Marker(
        point: LatLng(station.location.latitude, station.location.longitude),
        width: 56,
        height: 56,
        rotate: false,
        child: StationMarker(
          station: station,
          isSelected: selectedStation?.id == station.id,
          onTap: () => context.read<MapBloc>().add(StationSelected(station)),
        ),
      );
    }).toList();
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black26,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  void _centerOnUser(BuildContext context) {
    // TODO: Implement location permission and get user's actual location
    // For now, center on default location
    _mapController.move(const LatLng(51.1079, 17.0385), 14);
  }
}

/// Separate BlocBuilder for bike bottom sheet to prevent animation interruption
/// during silent map refreshes. Only rebuilds when selection changes.
class _BikeBottomSheetBuilder extends StatelessWidget {
  final VoidCallback onClose;

  const _BikeBottomSheetBuilder({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (previous, current) {
        // Only rebuild when selection or dismissal state changes
        final prevBike = previous is MapLoaded ? previous.selectedBike : null;
        final currBike = current is MapLoaded ? current.selectedBike : null;
        final prevDismissing = previous is MapLoaded
            ? previous.isBottomSheetDismissing
            : false;
        final currDismissing = current is MapLoaded
            ? current.isBottomSheetDismissing
            : false;

        return prevBike?.id != currBike?.id || prevDismissing != currDismissing;
      },
      builder: (context, state) {
        if (state is! MapLoaded || state.selectedBike == null) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: BikeDetailsBottomSheet(
            bike: state.selectedBike!,
            isDismissRequested: state.isBottomSheetDismissing,
            onClose: onClose,
          ),
        );
      },
    );
  }
}

/// Separate BlocBuilder for station bottom sheet to prevent animation interruption
/// during silent map refreshes. Only rebuilds when selection changes.
class _StationBottomSheetBuilder extends StatelessWidget {
  final VoidCallback onClose;

  const _StationBottomSheetBuilder({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (previous, current) {
        // Only rebuild when selection or dismissal state changes
        final prevStation = previous is MapLoaded
            ? previous.selectedStation
            : null;
        final currStation = current is MapLoaded
            ? current.selectedStation
            : null;
        final prevDismissing = previous is MapLoaded
            ? previous.isBottomSheetDismissing
            : false;
        final currDismissing = current is MapLoaded
            ? current.isBottomSheetDismissing
            : false;

        return prevStation?.id != currStation?.id ||
            prevDismissing != currDismissing;
      },
      builder: (context, state) {
        if (state is! MapLoaded || state.selectedStation == null) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: StationDetailsBottomSheet(
            station: state.selectedStation!,
            isDismissRequested: state.isBottomSheetDismissing,
            onClose: onClose,
          ),
        );
      },
    );
  }
}
