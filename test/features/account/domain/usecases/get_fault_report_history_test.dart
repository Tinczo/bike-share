import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/account/domain/entities/fault_report.dart';
import 'package:bike_app/features/account/domain/entities/fault_type.dart';
import 'package:bike_app/features/account/domain/repositories/account_repository.dart';
import 'package:bike_app/features/account/domain/usecases/get_fault_report_history.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

void main() {
  late GetFaultReportHistory usecase;
  late MockAccountRepository mockRepository;

  setUp(() {
    mockRepository = MockAccountRepository();
    usecase = GetFaultReportHistory(mockRepository);
  });

  final tTimestamp1 = DateTime(2024, 1, 15, 10, 0);
  final tTimestamp2 = DateTime(2024, 1, 14, 8, 0);
  final tVerificationDate = DateTime(2024, 1, 16, 14, 0);

  final tFaultReportList = [
    FaultReport(
      id: 'fault-1',
      bikeId: 'bike-1',
      userId: 'user-1',
      type: FaultType.flatTire,
      timestamp: tTimestamp1,
      isVerified: true,
      isConfirmed: true,
      verificationDate: tVerificationDate,
      rewardAmount: 5.0,
    ),
    FaultReport(
      id: 'fault-2',
      bikeId: 'bike-2',
      userId: 'user-1',
      type: FaultType.brokenChain,
      timestamp: tTimestamp2,
      isVerified: false,
      isConfirmed: false,
    ),
  ];

  test('should get fault report history from repository', () async {
    // arrange
    when(() => mockRepository.getFaultReportHistory())
        .thenAnswer((_) async => Right(tFaultReportList));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Right(tFaultReportList));
    verify(() => mockRepository.getFaultReportHistory()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return empty list when no fault reports exist', () async {
    // arrange
    when(() => mockRepository.getFaultReportHistory())
        .thenAnswer((_) async => const Right([]));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(<FaultReport>[]));
    verify(() => mockRepository.getFaultReportHistory()).called(1);
  });

  test('should return ServerFailure when repository fails', () async {
    // arrange
    when(() => mockRepository.getFaultReportHistory())
        .thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(ServerFailure()));
    verify(() => mockRepository.getFaultReportHistory()).called(1);
  });

  test('should return NetworkFailure when no connection', () async {
    // arrange
    when(() => mockRepository.getFaultReportHistory())
        .thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(NetworkFailure()));
  });
}
