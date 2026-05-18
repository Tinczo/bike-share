import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/map/domain/entities/location.dart';
import 'package:bike_app/features/map/domain/entities/station.dart';
import 'package:bike_app/features/map/domain/repositories/map_repository.dart';
import 'package:bike_app/features/map/domain/usecases/get_stations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMapRepository extends Mock implements MapRepository {}

void main() {
  late GetStations usecase;
  late MockMapRepository mockMapRepository;

  setUp(() {
    mockMapRepository = MockMapRepository();
    usecase = GetStations(mockMapRepository);
  });

  const tStations = [
    Station(
      id: '1',
      name: 'Rynek Główny',
      location: Location(latitude: 51.1100, longitude: 17.0300),
      capacity: 20,
      availableBikes: 12,
      availableStands: 8,
    ),
    Station(
      id: '2',
      name: 'Dworzec Główny',
      location: Location(latitude: 51.0990, longitude: 17.0350),
      capacity: 30,
      availableBikes: 18,
      availableStands: 12,
    ),
  ];

  test('should get list of stations from the repository', () async {
    // arrange
    when(
      () => mockMapRepository.getStations(),
    ).thenAnswer((_) async => const Right(tStations));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(tStations));
    verify(() => mockMapRepository.getStations()).called(1);
    verifyNoMoreInteractions(mockMapRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    when(
      () => mockMapRepository.getStations(),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(ServerFailure()));
    verify(() => mockMapRepository.getStations()).called(1);
    verifyNoMoreInteractions(mockMapRepository);
  });

  test('should return empty list when no stations exist', () async {
    // arrange
    when(
      () => mockMapRepository.getStations(),
    ).thenAnswer((_) async => const Right(<Station>[]));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(<Station>[]));
    verify(() => mockMapRepository.getStations()).called(1);
    verifyNoMoreInteractions(mockMapRepository);
  });
}
