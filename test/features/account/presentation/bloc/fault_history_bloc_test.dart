import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/account/domain/entities/fault_report.dart';
import 'package:bike_app/features/account/domain/entities/fault_type.dart';
import 'package:bike_app/features/account/domain/usecases/get_fault_report_history.dart';
import 'package:bike_app/features/account/presentation/bloc/fault_history_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetFaultReportHistory extends Mock implements GetFaultReportHistory {}

void main() {
  late FaultHistoryBloc bloc;
  late MockGetFaultReportHistory mockGetFaultReportHistory;

  setUp(() {
    mockGetFaultReportHistory = MockGetFaultReportHistory();
    bloc = FaultHistoryBloc(getFaultReportHistory: mockGetFaultReportHistory);
  });

  setUpAll(() {
    registerFallbackValue(NoParams());
  });

  tearDown(() {
    bloc.close();
  });

  final tTimestamp = DateTime(2024, 1, 15, 10, 30);
  final tVerificationDate = DateTime(2024, 1, 16, 14, 0);

  final tFaultReports = [
    FaultReport(
      id: 'fault-1',
      bikeId: 'bike-1',
      userId: 'user-1',
      type: FaultType.flatTire,
      timestamp: tTimestamp,
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
      timestamp: tTimestamp,
      isVerified: false,
      isConfirmed: false,
    ),
  ];

  test('initial state should be FaultHistoryInitial', () {
    expect(bloc.state, const FaultHistoryInitial());
  });

  group('FaultHistoryLoadRequested', () {
    blocTest<FaultHistoryBloc, FaultHistoryState>(
      'emits [FaultHistoryLoading, FaultHistoryLoaded] on success',
      build: () {
        when(() => mockGetFaultReportHistory(any()))
            .thenAnswer((_) async => Right(tFaultReports));
        return bloc;
      },
      act: (bloc) => bloc.add(const FaultHistoryLoadRequested()),
      expect: () => [
        const FaultHistoryLoading(),
        FaultHistoryLoaded(tFaultReports),
      ],
      verify: (_) {
        verify(() => mockGetFaultReportHistory(any())).called(1);
      },
    );

    blocTest<FaultHistoryBloc, FaultHistoryState>(
      'emits [FaultHistoryLoading, FaultHistoryEmpty] when empty list returned',
      build: () {
        when(() => mockGetFaultReportHistory(any()))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const FaultHistoryLoadRequested()),
      expect: () => [
        const FaultHistoryLoading(),
        const FaultHistoryEmpty(),
      ],
    );

    blocTest<FaultHistoryBloc, FaultHistoryState>(
      'emits [FaultHistoryLoading, FaultHistoryError] on ServerFailure',
      build: () {
        when(() => mockGetFaultReportHistory(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const FaultHistoryLoadRequested()),
      expect: () => [
        const FaultHistoryLoading(),
        const FaultHistoryError('Server error. Please try again later.'),
      ],
    );

    blocTest<FaultHistoryBloc, FaultHistoryState>(
      'emits [FaultHistoryLoading, FaultHistoryError] on NetworkFailure',
      build: () {
        when(() => mockGetFaultReportHistory(any()))
            .thenAnswer((_) async => Left(NetworkFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const FaultHistoryLoadRequested()),
      expect: () => [
        const FaultHistoryLoading(),
        const FaultHistoryError('No internet connection'),
      ],
    );
  });
}
