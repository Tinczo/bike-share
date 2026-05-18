import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/auth/domain/entities/user.dart';
import 'package:bike_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bike_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetCurrentUser usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = GetCurrentUser(mockAuthRepository);
  });

  const tUser = User(id: '1', email: 'test@example.com');

  test(
    'should get current user from the repository when user is logged in',
    () async {
      // arrange
      when(
        () => mockAuthRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tUser));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Right(tUser));
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test('should return null when no user is logged in', () async {
    // arrange
    when(
      () => mockAuthRepository.getCurrentUser(),
    ).thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(null));
    verify(() => mockAuthRepository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return failure when getting current user fails', () async {
    // arrange
    when(
      () => mockAuthRepository.getCurrentUser(),
    ).thenAnswer((_) async => Left(CacheFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(CacheFailure()));
    verify(() => mockAuthRepository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
