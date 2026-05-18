import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/map/data/models/location_model.dart';
import 'package:bike_app/features/map/domain/entities/bike.dart';
import 'package:bike_app/features/map/domain/entities/bike_status.dart';
import 'package:bike_app/features/map/domain/entities/location.dart';
import 'package:bike_app/features/map/domain/entities/station.dart';
import 'package:bike_app/features/map/domain/usecases/get_nearby_bikes.dart';
import 'package:bike_app/features/map/domain/usecases/get_stations.dart';
import 'package:bike_app/features/map/domain/usecases/invalidate_map_cache.dart';
import 'package:bike_app/features/map/presentation/bloc/map_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetNearbyBikes extends Mock implements GetNearbyBikes {}

class MockGetStations extends Mock implements GetStations {}

class MockInvalidateMapCache extends Mock implements InvalidateMapCache {}

void main() {
  late MapBloc bloc;
  late MockGetNearbyBikes mockGetNearbyBikes;
  late MockGetStations mockGetStations;
  late MockInvalidateMapCache mockInvalidateMapCache;

  setUp(() {
    mockGetNearbyBikes = MockGetNearbyBikes();
    mockGetStations = MockGetStations();
    mockInvalidateMapCache = MockInvalidateMapCache();
    bloc = MapBloc(
      getNearbyBikes: mockGetNearbyBikes,
      getStations: mockGetStations,
      invalidateMapCache: mockInvalidateMapCache,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      const GetNearbyBikesParams(
        center: Location(latitude: 0, longitude: 0),
        radiusKm: 0,
      ),
    );
    registerFallbackValue(NoParams());
  });

  tearDown(() {
    bloc.close();
  });

  const tCenter = Location(latitude: 51.1079, longitude: 17.0385);
  const tRadiusKm = 5.0;

  final tBikes = [
    const Bike(
      id: '1',
      qrCode: 'BIKE001',
      status: BikeStatus.available,
      batteryLevel: 85,
      location: LocationModel(latitude: 51.1080, longitude: 17.0390),
      rangeKm: 25,
    ),
    const Bike(
      id: '2',
      qrCode: 'BIKE002',
      status: BikeStatus.rented,
      batteryLevel: 60,
      location: LocationModel(latitude: 51.1075, longitude: 17.0380),
      rangeKm: 18,
    ),
  ];

  final tStations = [
    const Station(
      id: '1',
      name: 'Rynek Główny',
      location: LocationModel(latitude: 51.1100, longitude: 17.0300),
      capacity: 20,
      availableBikes: 12,
      availableStands: 8,
    ),
    const Station(
      id: '2',
      name: 'Dworzec Główny',
      location: LocationModel(latitude: 51.0990, longitude: 17.0350),
      capacity: 30,
      availableBikes: 18,
      availableStands: 12,
    ),
  ];

  test('initial state should be MapInitial', () {
    expect(bloc.state, const MapInitial());
  });

  group('LoadMapRequested', () {
    blocTest<MapBloc, MapState>(
      'emits [MapLoading, MapLoaded] when both bikes and stations load '
      'successfully',
      build: () {
        when(
          () => mockGetNearbyBikes(any()),
        ).thenAnswer((_) async => Right(tBikes));
        when(
          () => mockGetStations(any()),
        ).thenAnswer((_) async => Right(tStations));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const LoadMapRequested(center: tCenter, radiusKm: tRadiusKm),
      ),
      expect: () => [
        const MapLoading(),
        MapLoaded(
          bikes: tBikes,
          stations: tStations,
          currentCenter: tCenter,
          currentRadiusKm: tRadiusKm,
        ),
      ],
      verify: (_) {
        verify(
          () => mockGetNearbyBikes(
            const GetNearbyBikesParams(center: tCenter, radiusKm: tRadiusKm),
          ),
        ).called(1);
        verify(() => mockGetStations(any())).called(1);
      },
    );

    blocTest<MapBloc, MapState>(
      'emits [MapLoading, MapError] when bikes fetch fails',
      build: () {
        when(
          () => mockGetNearbyBikes(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        when(
          () => mockGetStations(any()),
        ).thenAnswer((_) async => Right(tStations));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const LoadMapRequested(center: tCenter, radiusKm: tRadiusKm),
      ),
      expect: () => [
        const MapLoading(),
        const MapError('Server error. Please try again later.'),
      ],
    );

    blocTest<MapBloc, MapState>(
      'emits [MapLoading, MapError] when stations fetch fails',
      build: () {
        when(
          () => mockGetNearbyBikes(any()),
        ).thenAnswer((_) async => Right(tBikes));
        when(
          () => mockGetStations(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const LoadMapRequested(center: tCenter, radiusKm: tRadiusKm),
      ),
      expect: () => [
        const MapLoading(),
        const MapError('Server error. Please try again later.'),
      ],
    );

    blocTest<MapBloc, MapState>(
      'emits [MapLoading, MapError] when network fails',
      build: () {
        when(
          () => mockGetNearbyBikes(any()),
        ).thenAnswer((_) async => Left(NetworkFailure()));
        when(
          () => mockGetStations(any()),
        ).thenAnswer((_) async => Right(tStations));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const LoadMapRequested(center: tCenter, radiusKm: tRadiusKm),
      ),
      expect: () => [
        const MapLoading(),
        const MapError('No internet connection'),
      ],
    );

    blocTest<MapBloc, MapState>(
      'emits [MapLoading, MapLoaded] with empty lists when no data exists',
      build: () {
        when(
          () => mockGetNearbyBikes(any()),
        ).thenAnswer((_) async => const Right(<Bike>[]));
        when(
          () => mockGetStations(any()),
        ).thenAnswer((_) async => const Right(<Station>[]));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const LoadMapRequested(center: tCenter, radiusKm: tRadiusKm),
      ),
      expect: () => [
        const MapLoading(),
        const MapLoaded(
          bikes: [],
          stations: [],
          currentCenter: tCenter,
          currentRadiusKm: tRadiusKm,
        ),
      ],
    );
  });

  group('RefreshMapRequested', () {
    blocTest<MapBloc, MapState>(
      'emits [MapLoading, MapLoaded] when refresh succeeds from loaded state',
      build: () {
        when(
          () => mockGetNearbyBikes(any()),
        ).thenAnswer((_) async => Right(tBikes));
        when(
          () => mockGetStations(any()),
        ).thenAnswer((_) async => Right(tStations));
        when(
          () => mockInvalidateMapCache(any()),
        ).thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      seed: () => MapLoaded(
        bikes: tBikes,
        stations: tStations,
        currentCenter: tCenter,
        currentRadiusKm: tRadiusKm,
      ),
      act: (bloc) => bloc.add(const RefreshMapRequested()),
      expect: () => [
        const MapLoading(),
        MapLoaded(
          bikes: tBikes,
          stations: tStations,
          currentCenter: tCenter,
          currentRadiusKm: tRadiusKm,
        ),
      ],
    );

    blocTest<MapBloc, MapState>(
      'calls invalidateMapCache',
      build: () {
        when(
          () => mockInvalidateMapCache(any()),
        ).thenAnswer((_) async => const Right(unit));
        when(
          () => mockGetNearbyBikes(any()),
        ).thenAnswer((_) async => Right(tBikes));
        when(
          () => mockGetStations(any()),
        ).thenAnswer((_) async => Right(tStations));
        return bloc;
      },
      seed: () => MapLoaded(
        bikes: tBikes,
        stations: tStations,
        currentCenter: tCenter,
        currentRadiusKm: tRadiusKm,
      ),
      act: (bloc) => bloc.add(const RefreshMapRequested()),
      expect: () => [
        const MapLoading(),
        MapLoaded(
          bikes: tBikes,
          stations: tStations,
          currentCenter: tCenter,
          currentRadiusKm: tRadiusKm,
        ),
      ],
      verify: (_) {
        verify(() => mockInvalidateMapCache(any())).called(1);
        verify(() => mockGetNearbyBikes(any())).called(1);
        verify(() => mockGetStations(any())).called(1);
      },
    );

    blocTest<MapBloc, MapState>(
      'does nothing when state is not MapLoaded',
      build: () => bloc,
      seed: () => const MapInitial(),
      act: (bloc) => bloc.add(const RefreshMapRequested()),
      expect: () => <MapState>[],
    );
  });

  group('BikeSelected', () {
    blocTest<MapBloc, MapState>(
      'emits MapLoaded with selectedBike when bike is selected',
      build: () => bloc,
      seed: () => MapLoaded(bikes: tBikes, stations: tStations),
      act: (bloc) => bloc.add(BikeSelected(tBikes.first)),
      expect: () => [
        MapLoaded(
          bikes: tBikes,
          stations: tStations,
          selectedBike: tBikes.first,
        ),
      ],
    );

    blocTest<MapBloc, MapState>(
      'clears selectedStation when bike is selected',
      build: () => bloc,
      seed: () => MapLoaded(
        bikes: tBikes,
        stations: tStations,
        selectedStation: tStations.first,
      ),
      act: (bloc) => bloc.add(BikeSelected(tBikes.first)),
      expect: () => [
        MapLoaded(
          bikes: tBikes,
          stations: tStations,
          selectedBike: tBikes.first,
        ),
      ],
    );
  });

  group('StationSelected', () {
    blocTest<MapBloc, MapState>(
      'emits MapLoaded with selectedStation when station is selected',
      build: () => bloc,
      seed: () => MapLoaded(bikes: tBikes, stations: tStations),
      act: (bloc) => bloc.add(StationSelected(tStations.first)),
      expect: () => [
        MapLoaded(
          bikes: tBikes,
          stations: tStations,
          selectedStation: tStations.first,
        ),
      ],
    );

    blocTest<MapBloc, MapState>(
      'clears selectedBike when station is selected',
      build: () => bloc,
      seed: () => MapLoaded(
        bikes: tBikes,
        stations: tStations,
        selectedBike: tBikes.first,
      ),
      act: (bloc) => bloc.add(StationSelected(tStations.first)),
      expect: () => [
        MapLoaded(
          bikes: tBikes,
          stations: tStations,
          selectedStation: tStations.first,
        ),
      ],
    );
  });

  group('SelectionCleared', () {
    blocTest<MapBloc, MapState>(
      'emits MapLoaded with no selection when selection is cleared',
      build: () => bloc,
      seed: () => MapLoaded(
        bikes: tBikes,
        stations: tStations,
        selectedBike: tBikes.first,
      ),
      act: (bloc) => bloc.add(const SelectionCleared()),
      expect: () => [MapLoaded(bikes: tBikes, stations: tStations)],
    );
  });
}
