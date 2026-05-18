import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bike_app/features/auth/domain/usecases/logout_user.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUser usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LogoutUser(mockAuthRepository);
  });

  test('should call logout on the repository', () async {
    // arrange
    when(
      () => mockAuthRepository.logout(),
    ).thenAnswer((_) async => const Right(unit));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(unit));
    verify(() => mockAuthRepository.logout()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return failure when logout fails', () async {
    // arrange
    when(
      () => mockAuthRepository.logout(),
    ).thenAnswer((_) async => Left(CacheFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(CacheFailure()));
    verify(() => mockAuthRepository.logout()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
