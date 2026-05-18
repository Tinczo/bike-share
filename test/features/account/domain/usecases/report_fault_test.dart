import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/features/account/domain/entities/fault_report.dart';
import 'package:bike_app/features/account/domain/entities/fault_type.dart';
import 'package:bike_app/features/account/domain/repositories/account_repository.dart';
import 'package:bike_app/features/account/domain/usecases/report_fault.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

void main() {
  late ReportFault usecase;
  late MockAccountRepository mockRepository;

  setUp(() {
    mockRepository = MockAccountRepository();
    usecase = ReportFault(mockRepository);
  });

  const tBikeId = 'bike-123';
  const tFaultType = FaultType.flatTire;
  const tDescription = 'Front tire is completely flat';
  final tTimestamp = DateTime(2024, 1, 15, 10, 0);

  final tFaultReport = FaultReport(
    id: 'fault-123',
    bikeId: tBikeId,
    userId: 'user-123',
    type: tFaultType,
    description: null,
    timestamp: tTimestamp,
    isVerified: false,
    isConfirmed: false,
  );

  test('should report fault without description', () async {
    // arrange
    when(
      () => mockRepository.reportFault(
        bikeId: tBikeId,
        type: tFaultType,
        description: null,
      ),
    ).thenAnswer((_) async => Right(tFaultReport));

    // act
    final result = await usecase(
      const ReportFaultParams(bikeId: tBikeId, type: tFaultType),
    );

    // assert
    expect(result, Right(tFaultReport));
    verify(
      () => mockRepository.reportFault(
        bikeId: tBikeId,
        type: tFaultType,
        description: null,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should report fault with description', () async {
    // arrange
    final faultWithDescription = tFaultReport.copyWith(
      type: FaultType.other,
      description: tDescription,
    );

    when(
      () => mockRepository.reportFault(
        bikeId: tBikeId,
        type: FaultType.other,
        description: tDescription,
      ),
    ).thenAnswer((_) async => Right(faultWithDescription));

    // act
    final result = await usecase(
      const ReportFaultParams(
        bikeId: tBikeId,
        type: FaultType.other,
        description: tDescription,
      ),
    );

    // assert
    expect(result, Right(faultWithDescription));
    verify(
      () => mockRepository.reportFault(
        bikeId: tBikeId,
        type: FaultType.other,
        description: tDescription,
      ),
    ).called(1);
  });

  test('should return ServerFailure when repository fails', () async {
    // arrange
    when(
      () => mockRepository.reportFault(
        bikeId: tBikeId,
        type: tFaultType,
        description: null,
      ),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(
      const ReportFaultParams(bikeId: tBikeId, type: tFaultType),
    );

    // assert
    expect(result, Left(ServerFailure()));
    verify(
      () => mockRepository.reportFault(
        bikeId: tBikeId,
        type: tFaultType,
        description: null,
      ),
    ).called(1);
  });

  test('should return NetworkFailure when no connection', () async {
    // arrange
    when(
      () => mockRepository.reportFault(
        bikeId: tBikeId,
        type: tFaultType,
        description: null,
      ),
    ).thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase(
      const ReportFaultParams(bikeId: tBikeId, type: tFaultType),
    );

    // assert
    expect(result, Left(NetworkFailure()));
  });

  group('ReportFaultParams', () {
    test('should support value equality', () {
      const params1 = ReportFaultParams(bikeId: tBikeId, type: tFaultType);
      const params2 = ReportFaultParams(bikeId: tBikeId, type: tFaultType);

      expect(params1, equals(params2));
    });

    test('should support value equality with description', () {
      const params1 = ReportFaultParams(
        bikeId: tBikeId,
        type: FaultType.other,
        description: tDescription,
      );
      const params2 = ReportFaultParams(
        bikeId: tBikeId,
        type: FaultType.other,
        description: tDescription,
      );

      expect(params1, equals(params2));
    });

    test('props should contain bikeId, type, and description', () {
      const params = ReportFaultParams(
        bikeId: tBikeId,
        type: FaultType.other,
        description: tDescription,
      );

      expect(params.props, [tBikeId, FaultType.other, tDescription]);
    });
  });
}
