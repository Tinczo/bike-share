import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/rental/domain/entities/rental_eligibility.dart';
import 'package:bike_app/features/rental/domain/repositories/rental_repository.dart';
import 'package:bike_app/features/rental/domain/usecases/check_rental_eligibility.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRentalRepository extends Mock implements RentalRepository {}

void main() {
  late CheckRentalEligibility usecase;
  late MockRentalRepository mockRentalRepository;

  setUp(() {
    mockRentalRepository = MockRentalRepository();
    usecase = CheckRentalEligibility(mockRentalRepository);
  });

  const tEligibility = RentalEligibility(
    isEligible: true,
    hasMinimumBalance: true,
    hasLinkedCard: true,
    hasActiveSubscription: false,
    isDebtor: false,
  );

  test('should get rental eligibility from the repository', () async {
    // arrange
    when(
      () => mockRentalRepository.checkEligibility(),
    ).thenAnswer((_) async => const Right(tEligibility));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(tEligibility));
    verify(() => mockRentalRepository.checkEligibility()).called(1);
    verifyNoMoreInteractions(mockRentalRepository);
  });

  test('should return failure when checking eligibility fails', () async {
    // arrange
    when(
      () => mockRentalRepository.checkEligibility(),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(ServerFailure()));
    verify(() => mockRentalRepository.checkEligibility()).called(1);
    verifyNoMoreInteractions(mockRentalRepository);
  });

  test('should return NetworkFailure when no network connection', () async {
    // arrange
    when(
      () => mockRentalRepository.checkEligibility(),
    ).thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(NetworkFailure()));
    verify(() => mockRentalRepository.checkEligibility()).called(1);
  });
}
