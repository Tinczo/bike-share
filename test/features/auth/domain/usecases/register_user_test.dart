import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/features/auth/domain/entities/user.dart';
import 'package:bike_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bike_app/features/auth/domain/usecases/register_user.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUser usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = RegisterUser(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = User(id: '1', email: tEmail);

  test(
    'should get user from the repository on successful registration',
    () async {
      // arrange
      when(
        () => mockAuthRepository.register(email: tEmail, password: tPassword),
      ).thenAnswer((_) async => const Right(tUser));

      // act
      final result = await usecase(
        const RegisterParams(email: tEmail, password: tPassword),
      );

      // assert
      expect(result, const Right(tUser));
      verify(
        () => mockAuthRepository.register(email: tEmail, password: tPassword),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test('should return failure when registration fails', () async {
    // arrange
    when(
      () => mockAuthRepository.register(email: tEmail, password: tPassword),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(
      const RegisterParams(email: tEmail, password: tPassword),
    );

    // assert
    expect(result, Left(ServerFailure()));
    verify(
      () => mockAuthRepository.register(email: tEmail, password: tPassword),
    ).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
