import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/features/account/domain/entities/fault_report.dart';
import 'package:bike_app/features/account/domain/entities/fault_type.dart';
import 'package:bike_app/features/account/domain/usecases/report_fault.dart';
import 'package:bike_app/features/account/presentation/bloc/report_fault_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockReportFault extends Mock implements ReportFault {}

void main() {
  late ReportFaultBloc bloc;
  late MockReportFault mockReportFault;

  setUp(() {
    mockReportFault = MockReportFault();
    bloc = ReportFaultBloc(reportFault: mockReportFault);
  });

  setUpAll(() {
    registerFallbackValue(
      const ReportFaultParams(bikeId: 'bike-123', type: FaultType.flatTire),
    );
  });

  tearDown(() {
    bloc.close();
  });

  const tBikeId = 'bike-123';
  final tTimestamp = DateTime(2024, 1, 15, 10, 30);

  final tFaultReport = FaultReport(
    id: 'fault-123',
    bikeId: tBikeId,
    userId: 'user-123',
    type: FaultType.flatTire,
    timestamp: tTimestamp,
    isVerified: false,
    isConfirmed: false,
  );

  test('initial state should be ReportFaultInitial', () {
    expect(bloc.state, const ReportFaultInitial());
  });

  group('FaultTypeSelected', () {
    blocTest<ReportFaultBloc, ReportFaultState>(
      'emits [ReportFaultTypeSelected] when fault type is selected',
      build: () => bloc,
      act: (bloc) => bloc.add(const FaultTypeSelected(FaultType.flatTire)),
      expect: () => [const ReportFaultTypeSelected(FaultType.flatTire)],
    );

    blocTest<ReportFaultBloc, ReportFaultState>(
      'allows changing fault type selection',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const FaultTypeSelected(FaultType.flatTire));
        bloc.add(const FaultTypeSelected(FaultType.brokenChain));
      },
      expect: () => [
        const ReportFaultTypeSelected(FaultType.flatTire),
        const ReportFaultTypeSelected(FaultType.brokenChain),
      ],
    );
  });

  group('DescriptionChanged', () {
    blocTest<ReportFaultBloc, ReportFaultState>(
      'emits [ReportFaultTypeSelected] with description when changed',
      build: () => bloc,
      seed: () => const ReportFaultTypeSelected(FaultType.other),
      act: (bloc) => bloc.add(const DescriptionChanged('Custom description')),
      expect: () => [
        const ReportFaultTypeSelected(
          FaultType.other,
          description: 'Custom description',
        ),
      ],
    );

    blocTest<ReportFaultBloc, ReportFaultState>(
      'does nothing if no fault type selected',
      build: () => bloc,
      act: (bloc) => bloc.add(const DescriptionChanged('Custom description')),
      expect: () => [],
    );
  });

  group('FaultReportSubmitted', () {
    blocTest<ReportFaultBloc, ReportFaultState>(
      'emits [ReportFaultSubmitting, ReportFaultSuccess] on success',
      build: () {
        when(() => mockReportFault(any()))
            .thenAnswer((_) async => Right(tFaultReport));
        return bloc;
      },
      seed: () => const ReportFaultTypeSelected(FaultType.flatTire),
      act: (bloc) => bloc.add(FaultReportSubmitted(bikeId: tBikeId)),
      expect: () => [
        const ReportFaultSubmitting(),
        ReportFaultSuccess(tFaultReport),
      ],
      verify: (_) {
        verify(
          () => mockReportFault(
            const ReportFaultParams(
              bikeId: tBikeId,
              type: FaultType.flatTire,
            ),
          ),
        ).called(1);
      },
    );

    blocTest<ReportFaultBloc, ReportFaultState>(
      'emits [ReportFaultSubmitting, ReportFaultSuccess] with description',
      build: () {
        when(() => mockReportFault(any()))
            .thenAnswer((_) async => Right(tFaultReport));
        return bloc;
      },
      seed: () => const ReportFaultTypeSelected(
        FaultType.other,
        description: 'Custom issue',
      ),
      act: (bloc) => bloc.add(FaultReportSubmitted(bikeId: tBikeId)),
      expect: () => [
        const ReportFaultSubmitting(),
        ReportFaultSuccess(tFaultReport),
      ],
      verify: (_) {
        verify(
          () => mockReportFault(
            const ReportFaultParams(
              bikeId: tBikeId,
              type: FaultType.other,
              description: 'Custom issue',
            ),
          ),
        ).called(1);
      },
    );

    blocTest<ReportFaultBloc, ReportFaultState>(
      'emits [ReportFaultSubmitting, ReportFaultFailure] on ServerFailure',
      build: () {
        when(() => mockReportFault(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      seed: () => const ReportFaultTypeSelected(FaultType.flatTire),
      act: (bloc) => bloc.add(FaultReportSubmitted(bikeId: tBikeId)),
      expect: () => [
        const ReportFaultSubmitting(),
        const ReportFaultFailure(serverFailureMessage),
      ],
    );

    blocTest<ReportFaultBloc, ReportFaultState>(
      'emits [ReportFaultSubmitting, ReportFaultFailure] on NetworkFailure',
      build: () {
        when(() => mockReportFault(any()))
            .thenAnswer((_) async => Left(NetworkFailure()));
        return bloc;
      },
      seed: () => const ReportFaultTypeSelected(FaultType.flatTire),
      act: (bloc) => bloc.add(FaultReportSubmitted(bikeId: tBikeId)),
      expect: () => [
        const ReportFaultSubmitting(),
        const ReportFaultFailure(networkFailureMessage),
      ],
    );

    blocTest<ReportFaultBloc, ReportFaultState>(
      'emits [ReportFaultFailure] when no fault type selected',
      build: () => bloc,
      act: (bloc) => bloc.add(FaultReportSubmitted(bikeId: tBikeId)),
      expect: () => [
        const ReportFaultFailure('Please select a fault type'),
      ],
      verify: (_) {
        verifyNever(() => mockReportFault(any()));
      },
    );
  });
}
