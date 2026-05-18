import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/account/domain/entities/rental_history_item.dart';
import 'package:bike_app/features/account/domain/repositories/account_repository.dart';
import 'package:bike_app/features/account/domain/usecases/get_rental_history.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

void main() {
  late GetRentalHistory usecase;
  late MockAccountRepository mockRepository;

  setUp(() {
    mockRepository = MockAccountRepository();
    usecase = GetRentalHistory(mockRepository);
  });

  final tStartTime1 = DateTime(2024, 1, 15, 10, 0);
  final tEndTime1 = DateTime(2024, 1, 15, 11, 30);
  final tStartTime2 = DateTime(2024, 1, 14, 8, 0);
  final tEndTime2 = DateTime(2024, 1, 14, 9, 0);

  final tRentalHistoryList = [
    RentalHistoryItem(
      id: 'rental-1',
      bikeId: 'bike-1',
      startTime: tStartTime1,
      endTime: tEndTime1,
      cost: 4.5,
      startStationName: 'Station A',
      endStationName: 'Station B',
    ),
    RentalHistoryItem(
      id: 'rental-2',
      bikeId: 'bike-2',
      startTime: tStartTime2,
      endTime: tEndTime2,
      cost: 3.0,
      startStationName: 'Station C',
      endStationName: 'Station D',
    ),
  ];

  test('should get rental history from repository', () async {
    // arrange
    when(() => mockRepository.getRentalHistory())
        .thenAnswer((_) async => Right(tRentalHistoryList));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Right(tRentalHistoryList));
    verify(() => mockRepository.getRentalHistory()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return empty list when no rental history exists', () async {
    // arrange
    when(() => mockRepository.getRentalHistory())
        .thenAnswer((_) async => const Right([]));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(<RentalHistoryItem>[]));
    verify(() => mockRepository.getRentalHistory()).called(1);
  });

  test('should return ServerFailure when repository fails', () async {
    // arrange
    when(() => mockRepository.getRentalHistory())
        .thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(ServerFailure()));
    verify(() => mockRepository.getRentalHistory()).called(1);
  });

  test('should return NetworkFailure when no connection', () async {
    // arrange
    when(() => mockRepository.getRentalHistory())
        .thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(NetworkFailure()));
  });
}
