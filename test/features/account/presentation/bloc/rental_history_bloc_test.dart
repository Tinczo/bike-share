import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/account/domain/entities/rental_history_item.dart';
import 'package:bike_app/features/account/domain/usecases/get_rental_history.dart';
import 'package:bike_app/features/account/presentation/bloc/rental_history_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetRentalHistory extends Mock implements GetRentalHistory {}

void main() {
  late RentalHistoryBloc bloc;
  late MockGetRentalHistory mockGetRentalHistory;

  setUp(() {
    mockGetRentalHistory = MockGetRentalHistory();
    bloc = RentalHistoryBloc(getRentalHistory: mockGetRentalHistory);
  });

  setUpAll(() {
    registerFallbackValue(NoParams());
  });

  tearDown(() {
    bloc.close();
  });

  final tStartTime = DateTime(2024, 1, 15, 10, 0);
  final tEndTime = DateTime(2024, 1, 15, 11, 30);

  final tRentalHistory = [
    RentalHistoryItem(
      id: 'rental-1',
      bikeId: 'bike-1',
      startTime: tStartTime,
      endTime: tEndTime,
      cost: 4.5,
      startStationName: 'Station A',
      endStationName: 'Station B',
    ),
    RentalHistoryItem(
      id: 'rental-2',
      bikeId: 'bike-2',
      startTime: tStartTime,
      endTime: tEndTime,
      cost: 3.0,
    ),
  ];

  test('initial state should be RentalHistoryInitial', () {
    expect(bloc.state, const RentalHistoryInitial());
  });

  group('RentalHistoryLoadRequested', () {
    blocTest<RentalHistoryBloc, RentalHistoryState>(
      'emits [RentalHistoryLoading, RentalHistoryLoaded] on success',
      build: () {
        when(() => mockGetRentalHistory(any()))
            .thenAnswer((_) async => Right(tRentalHistory));
        return bloc;
      },
      act: (bloc) => bloc.add(const RentalHistoryLoadRequested()),
      expect: () => [
        const RentalHistoryLoading(),
        RentalHistoryLoaded(tRentalHistory),
      ],
      verify: (_) {
        verify(() => mockGetRentalHistory(any())).called(1);
      },
    );

    blocTest<RentalHistoryBloc, RentalHistoryState>(
      'emits [RentalHistoryLoading, RentalHistoryEmpty] when empty list',
      build: () {
        when(() => mockGetRentalHistory(any()))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const RentalHistoryLoadRequested()),
      expect: () => [
        const RentalHistoryLoading(),
        const RentalHistoryEmpty(),
      ],
    );

    blocTest<RentalHistoryBloc, RentalHistoryState>(
      'emits [RentalHistoryLoading, RentalHistoryError] on ServerFailure',
      build: () {
        when(() => mockGetRentalHistory(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const RentalHistoryLoadRequested()),
      expect: () => [
        const RentalHistoryLoading(),
        const RentalHistoryError('Server error. Please try again later.'),
      ],
    );

    blocTest<RentalHistoryBloc, RentalHistoryState>(
      'emits [RentalHistoryLoading, RentalHistoryError] on NetworkFailure',
      build: () {
        when(() => mockGetRentalHistory(any()))
            .thenAnswer((_) async => Left(NetworkFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const RentalHistoryLoadRequested()),
      expect: () => [
        const RentalHistoryLoading(),
        const RentalHistoryError('No internet connection'),
      ],
    );
  });
}
