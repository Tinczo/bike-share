import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/features/map/domain/entities/bike.dart';
import 'package:bike_app/features/map/domain/entities/bike_status.dart';
import 'package:bike_app/features/map/domain/entities/location.dart';
import 'package:bike_app/features/map/domain/repositories/map_repository.dart';
import 'package:bike_app/features/map/domain/usecases/get_nearby_bikes.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMapRepository extends Mock implements MapRepository {}

void main() {
  late GetNearbyBikes usecase;
  late MockMapRepository mockMapRepository;

  setUp(() {
    mockMapRepository = MockMapRepository();
    usecase = GetNearbyBikes(mockMapRepository);
  });

  const tCenter = Location(latitude: 51.1079, longitude: 17.0385);
  const tRadiusKm = 5.0;
  const tBikes = [
    Bike(
      id: '1',
      qrCode: 'BIKE001',
      status: BikeStatus.available,
      batteryLevel: 85,
      location: Location(latitude: 51.1080, longitude: 17.0390),
      rangeKm: 25,
    ),
    Bike(
      id: '2',
      qrCode: 'BIKE002',
      status: BikeStatus.rented,
      batteryLevel: 60,
      location: Location(latitude: 51.1075, longitude: 17.0380),
      rangeKm: 18,
    ),
  ];

  test('should get list of nearby bikes from the repository', () async {
    // arrange
    when(
      () => mockMapRepository.getNearbyBikes(
        center: tCenter,
        radiusKm: tRadiusKm,
      ),
    ).thenAnswer((_) async => const Right(tBikes));

    // act
    final result = await usecase(
      const GetNearbyBikesParams(center: tCenter, radiusKm: tRadiusKm),
    );

    // assert
    expect(result, const Right(tBikes));
    verify(
      () => mockMapRepository.getNearbyBikes(
        center: tCenter,
        radiusKm: tRadiusKm,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockMapRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    when(
      () => mockMapRepository.getNearbyBikes(
        center: tCenter,
        radiusKm: tRadiusKm,
      ),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(
      const GetNearbyBikesParams(center: tCenter, radiusKm: tRadiusKm),
    );

    // assert
    expect(result, Left(ServerFailure()));
    verify(
      () => mockMapRepository.getNearbyBikes(
        center: tCenter,
        radiusKm: tRadiusKm,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockMapRepository);
  });

  test('should return empty list when no bikes are nearby', () async {
    // arrange
    when(
      () => mockMapRepository.getNearbyBikes(
        center: tCenter,
        radiusKm: tRadiusKm,
      ),
    ).thenAnswer((_) async => const Right(<Bike>[]));

    // act
    final result = await usecase(
      const GetNearbyBikesParams(center: tCenter, radiusKm: tRadiusKm),
    );

    // assert
    expect(result, const Right(<Bike>[]));
    verify(
      () => mockMapRepository.getNearbyBikes(
        center: tCenter,
        radiusKm: tRadiusKm,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockMapRepository);
  });
}
