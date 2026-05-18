import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/map/domain/repositories/map_repository.dart';
import 'package:bike_app/features/map/domain/usecases/invalidate_map_cache.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMapRepository extends Mock implements MapRepository {}

void main() {
  late InvalidateMapCache usecase;
  late MockMapRepository mockRepository;

  setUp(() {
    mockRepository = MockMapRepository();
    usecase = InvalidateMapCache(mockRepository);
  });

  test('should call repository.invalidateCache', () async {
    // arrange
    when(
      () => mockRepository.invalidateCache(),
    ).thenAnswer((_) async => const Right(unit));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(unit));
    verify(() => mockRepository.invalidateCache()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return CacheFailure when repository fails', () async {
    // arrange
    when(
      () => mockRepository.invalidateCache(),
    ).thenAnswer((_) async => Left(CacheFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(CacheFailure()));
    verify(() => mockRepository.invalidateCache()).called(1);
  });
}
