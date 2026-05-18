import 'package:bike_app/core/error/exceptions.dart';
import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/network/network_info.dart';
import 'package:bike_app/features/map/data/datasources/map_local_datasource.dart';
import 'package:bike_app/features/map/data/datasources/map_remote_datasource.dart';
import 'package:bike_app/features/map/data/models/bike_model.dart';
import 'package:bike_app/features/map/data/models/location_model.dart';
import 'package:bike_app/features/map/data/models/station_model.dart';
import 'package:bike_app/features/map/data/repositories/map_repository_impl.dart';
import 'package:bike_app/features/map/domain/entities/bike_status.dart';
import 'package:bike_app/features/map/domain/entities/location.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMapRemoteDataSource extends Mock implements MapRemoteDataSource {}

class MockMapLocalDataSource extends Mock implements MapLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MapRepositoryImpl repository;
  late MockMapRemoteDataSource mockRemoteDataSource;
  late MockMapLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockMapRemoteDataSource();
    mockLocalDataSource = MockMapLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = MapRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void setUpNetworkConnected() {
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
  }

  void setUpNetworkDisconnected() {
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
  }

  group('getNearbyBikes', () {
    const tCenter = Location(latitude: 51.1079, longitude: 17.0385);
    const tRadiusKm = 5.0;

    final tBikeModels = [
      const BikeModel(
        id: '1',
        qrCode: 'BIKE001',
        status: BikeStatus.available,
        batteryLevel: 85,
        location: LocationModel(latitude: 51.1080, longitude: 17.0390),
        rangeKm: 25,
      ),
      const BikeModel(
        id: '2',
        qrCode: 'BIKE002',
        status: BikeStatus.rented,
        batteryLevel: 60,
        location: LocationModel(latitude: 51.1075, longitude: 17.0380),
        rangeKm: 18,
      ),
    ];

    group('cache is valid', () {
      test(
        'should return cached bikes without calling remote when cache is valid',
        () async {
          // arrange
          when(
            () => mockLocalDataSource.isBikesCacheValid(),
          ).thenAnswer((_) async => true);
          when(
            () => mockLocalDataSource.getCachedBikes(),
          ).thenAnswer((_) async => tBikeModels);

          // act
          final result = await repository.getNearbyBikes(
            center: tCenter,
            radiusKm: tRadiusKm,
          );

          // assert
          verify(() => mockLocalDataSource.isBikesCacheValid()).called(1);
          verify(() => mockLocalDataSource.getCachedBikes()).called(1);
          verifyZeroInteractions(mockRemoteDataSource);
          verifyZeroInteractions(mockNetworkInfo);
          expect(result, Right(tBikeModels));
        },
      );
    });

    group('cache is invalid and device is online', () {
      setUp(() {
        when(
          () => mockLocalDataSource.isBikesCacheValid(),
        ).thenAnswer((_) async => false);
        setUpNetworkConnected();
      });

      test('should return and cache bikes when remote call succeeds', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getNearbyBikes(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenAnswer((_) async => tBikeModels);
        when(
          () => mockLocalDataSource.cacheBikes(any()),
        ).thenAnswer((_) async {});

        // act
        final result = await repository.getNearbyBikes(
          center: tCenter,
          radiusKm: tRadiusKm,
        );

        // assert
        verify(() => mockLocalDataSource.isBikesCacheValid()).called(1);
        verify(() => mockNetworkInfo.isConnected).called(1);
        verify(
          () => mockRemoteDataSource.getNearbyBikes(
            latitude: tCenter.latitude,
            longitude: tCenter.longitude,
            radiusKm: tRadiusKm,
          ),
        ).called(1);
        verify(() => mockLocalDataSource.cacheBikes(tBikeModels)).called(1);
        expect(result, Right(tBikeModels));
      });

      test('should return CacheFailure when remote call fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getNearbyBikes(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenThrow(ServerException());

        // act
        final result = await repository.getNearbyBikes(
          center: tCenter,
          radiusKm: tRadiusKm,
        );

        // assert
        verify(() => mockLocalDataSource.isBikesCacheValid()).called(1);
        verify(() => mockNetworkInfo.isConnected).called(1);
        expect(result, Left(CacheFailure()));
      });
    });

    group('cache is invalid and device is offline', () {
      setUp(() {
        when(
          () => mockLocalDataSource.isBikesCacheValid(),
        ).thenAnswer((_) async => false);
        setUpNetworkDisconnected();
      });

      test('should return CacheFailure', () async {
        // act
        final result = await repository.getNearbyBikes(
          center: tCenter,
          radiusKm: tRadiusKm,
        );

        // assert
        verify(() => mockLocalDataSource.isBikesCacheValid()).called(1);
        verify(() => mockNetworkInfo.isConnected).called(1);
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, Left(CacheFailure()));
      });
    });

    group('cache check throws exception', () {
      setUp(() {
        when(
          () => mockLocalDataSource.isBikesCacheValid(),
        ).thenThrow(CacheException());
        setUpNetworkConnected();
      });

      test(
        'should try network when cache check fails and return bikes',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.getNearbyBikes(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              radiusKm: any(named: 'radiusKm'),
            ),
          ).thenAnswer((_) async => tBikeModels);
          when(
            () => mockLocalDataSource.cacheBikes(any()),
          ).thenAnswer((_) async {});

          // act
          final result = await repository.getNearbyBikes(
            center: tCenter,
            radiusKm: tRadiusKm,
          );

          // assert
          verify(() => mockLocalDataSource.isBikesCacheValid()).called(1);
          verify(() => mockNetworkInfo.isConnected).called(1);
          verify(
            () => mockRemoteDataSource.getNearbyBikes(
              latitude: tCenter.latitude,
              longitude: tCenter.longitude,
              radiusKm: tRadiusKm,
            ),
          ).called(1);
          expect(result, Right(tBikeModels));
        },
      );

      test(
        'should return CacheFailure when cache check fails and offline',
        () async {
          // arrange - override to be offline
          reset(mockNetworkInfo);
          setUpNetworkDisconnected();

          // act
          final result = await repository.getNearbyBikes(
            center: tCenter,
            radiusKm: tRadiusKm,
          );

          // assert
          verify(() => mockLocalDataSource.isBikesCacheValid()).called(1);
          verify(() => mockNetworkInfo.isConnected).called(1);
          verifyZeroInteractions(mockRemoteDataSource);
          expect(result, Left(CacheFailure()));
        },
      );
    });
  });

  group('getStations', () {
    final tStationModels = [
      const StationModel(
        id: '1',
        name: 'Rynek Główny',
        location: LocationModel(latitude: 51.1100, longitude: 17.0300),
        capacity: 20,
        availableBikes: 12,
        availableStands: 8,
      ),
      const StationModel(
        id: '2',
        name: 'Dworzec Główny',
        location: LocationModel(latitude: 51.0990, longitude: 17.0350),
        capacity: 30,
        availableBikes: 18,
        availableStands: 12,
      ),
    ];

    group('cache is valid', () {
      test(
        'should return cached stations without calling remote when cache is valid',
        () async {
          // arrange
          when(
            () => mockLocalDataSource.isStationsCacheValid(),
          ).thenAnswer((_) async => true);
          when(
            () => mockLocalDataSource.getCachedStations(),
          ).thenAnswer((_) async => tStationModels);

          // act
          final result = await repository.getStations();

          // assert
          verify(() => mockLocalDataSource.isStationsCacheValid()).called(1);
          verify(() => mockLocalDataSource.getCachedStations()).called(1);
          verifyZeroInteractions(mockRemoteDataSource);
          verifyZeroInteractions(mockNetworkInfo);
          expect(result, Right(tStationModels));
        },
      );
    });

    group('cache is invalid and device is online', () {
      setUp(() {
        when(
          () => mockLocalDataSource.isStationsCacheValid(),
        ).thenAnswer((_) async => false);
        setUpNetworkConnected();
      });

      test(
        'should return and cache stations when remote call succeeds',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.getStations(),
          ).thenAnswer((_) async => tStationModels);
          when(
            () => mockLocalDataSource.cacheStations(any()),
          ).thenAnswer((_) async {});

          // act
          final result = await repository.getStations();

          // assert
          verify(() => mockLocalDataSource.isStationsCacheValid()).called(1);
          verify(() => mockNetworkInfo.isConnected).called(1);
          verify(() => mockRemoteDataSource.getStations()).called(1);
          verify(
            () => mockLocalDataSource.cacheStations(tStationModels),
          ).called(1);
          expect(result, Right(tStationModels));
        },
      );

      test('should return CacheFailure when remote call fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getStations(),
        ).thenThrow(ServerException());

        // act
        final result = await repository.getStations();

        // assert
        verify(() => mockLocalDataSource.isStationsCacheValid()).called(1);
        verify(() => mockNetworkInfo.isConnected).called(1);
        expect(result, Left(CacheFailure()));
      });
    });

    group('cache is invalid and device is offline', () {
      setUp(() {
        when(
          () => mockLocalDataSource.isStationsCacheValid(),
        ).thenAnswer((_) async => false);
        setUpNetworkDisconnected();
      });

      test('should return CacheFailure', () async {
        // act
        final result = await repository.getStations();

        // assert
        verify(() => mockLocalDataSource.isStationsCacheValid()).called(1);
        verify(() => mockNetworkInfo.isConnected).called(1);
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, Left(CacheFailure()));
      });
    });

    group('cache check throws exception', () {
      setUp(() {
        when(
          () => mockLocalDataSource.isStationsCacheValid(),
        ).thenThrow(CacheException());
        setUpNetworkConnected();
      });

      test(
        'should try network when cache check fails and return stations',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.getStations(),
          ).thenAnswer((_) async => tStationModels);
          when(
            () => mockLocalDataSource.cacheStations(any()),
          ).thenAnswer((_) async {});

          // act
          final result = await repository.getStations();

          // assert
          verify(() => mockLocalDataSource.isStationsCacheValid()).called(1);
          verify(() => mockNetworkInfo.isConnected).called(1);
          verify(() => mockRemoteDataSource.getStations()).called(1);
          expect(result, Right(tStationModels));
        },
      );

      test(
        'should return CacheFailure when cache check fails and offline',
        () async {
          // arrange - override to be offline
          reset(mockNetworkInfo);
          setUpNetworkDisconnected();

          // act
          final result = await repository.getStations();

          // assert
          verify(() => mockLocalDataSource.isStationsCacheValid()).called(1);
          verify(() => mockNetworkInfo.isConnected).called(1);
          verifyZeroInteractions(mockRemoteDataSource);
          expect(result, Left(CacheFailure()));
        },
      );
    });
  });
}
