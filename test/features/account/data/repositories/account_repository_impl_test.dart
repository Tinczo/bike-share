import 'package:bike_app/core/error/exceptions.dart';
import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/network/network_info.dart';
import 'package:bike_app/features/account/data/datasources/account_remote_datasource.dart';
import 'package:bike_app/features/account/data/models/fault_report_model.dart';
import 'package:bike_app/features/account/data/models/rental_history_item_model.dart';
import 'package:bike_app/features/account/data/repositories/account_repository_impl.dart';
import 'package:bike_app/features/account/domain/entities/fault_type.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountRemoteDataSource extends Mock
    implements AccountRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AccountRepositoryImpl repository;
  late MockAccountRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockAccountRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AccountRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getRentalHistory', () {
    final tStartTime = DateTime(2024, 1, 15, 10, 0);
    final tEndTime = DateTime(2024, 1, 15, 11, 30);

    final tRentalHistoryModels = [
      RentalHistoryItemModel(
        id: 'rental-1',
        bikeId: 'bike-1',
        startTime: tStartTime,
        endTime: tEndTime,
        cost: 4.5,
        startStationName: 'Station A',
        endStationName: 'Station B',
      ),
    ];

    runTestsOnline(() {
      test('should return rental history when call is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getRentalHistory())
            .thenAnswer((_) async => tRentalHistoryModels);

        // act
        final result = await repository.getRentalHistory();

        // assert
        verify(() => mockRemoteDataSource.getRentalHistory()).called(1);
        expect(result, equals(Right(tRentalHistoryModels)));
      });

      test('should return ServerFailure when call is unsuccessful', () async {
        // arrange
        when(() => mockRemoteDataSource.getRentalHistory())
            .thenThrow(ServerException());

        // act
        final result = await repository.getRentalHistory();

        // assert
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.getRentalHistory();

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(Left(NetworkFailure())));
      });
    });
  });

  group('getFaultReportHistory', () {
    final tTimestamp = DateTime(2024, 1, 15, 10, 30);

    final tFaultReportModels = [
      FaultReportModel(
        id: 'fault-1',
        bikeId: 'bike-1',
        userId: 'user-1',
        type: FaultType.flatTire,
        timestamp: tTimestamp,
        isVerified: false,
        isConfirmed: false,
      ),
    ];

    runTestsOnline(() {
      test('should return fault report history when call is successful',
          () async {
        // arrange
        when(() => mockRemoteDataSource.getFaultReportHistory())
            .thenAnswer((_) async => tFaultReportModels);

        // act
        final result = await repository.getFaultReportHistory();

        // assert
        verify(() => mockRemoteDataSource.getFaultReportHistory()).called(1);
        expect(result, equals(Right(tFaultReportModels)));
      });

      test('should return ServerFailure when call is unsuccessful', () async {
        // arrange
        when(() => mockRemoteDataSource.getFaultReportHistory())
            .thenThrow(ServerException());

        // act
        final result = await repository.getFaultReportHistory();

        // assert
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.getFaultReportHistory();

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(Left(NetworkFailure())));
      });
    });
  });

  group('reportFault', () {
    const tBikeId = 'bike-123';
    const tFaultType = FaultType.flatTire;
    const tDescription = 'Front tire is flat';
    final tTimestamp = DateTime(2024, 1, 15, 10, 30);

    final tFaultReportModel = FaultReportModel(
      id: 'fault-123',
      bikeId: tBikeId,
      userId: 'user-123',
      type: tFaultType,
      description: tDescription,
      timestamp: tTimestamp,
      isVerified: false,
      isConfirmed: false,
    );

    runTestsOnline(() {
      test('should return fault report when call is successful', () async {
        // arrange
        when(
          () => mockRemoteDataSource.reportFault(
            bikeId: tBikeId,
            type: tFaultType,
            description: tDescription,
          ),
        ).thenAnswer((_) async => tFaultReportModel);

        // act
        final result = await repository.reportFault(
          bikeId: tBikeId,
          type: tFaultType,
          description: tDescription,
        );

        // assert
        verify(
          () => mockRemoteDataSource.reportFault(
            bikeId: tBikeId,
            type: tFaultType,
            description: tDescription,
          ),
        ).called(1);
        expect(result, equals(Right(tFaultReportModel)));
      });

      test('should handle null description', () async {
        // arrange
        when(
          () => mockRemoteDataSource.reportFault(
            bikeId: tBikeId,
            type: tFaultType,
            description: null,
          ),
        ).thenAnswer((_) async => tFaultReportModel);

        // act
        final result = await repository.reportFault(
          bikeId: tBikeId,
          type: tFaultType,
        );

        // assert
        verify(
          () => mockRemoteDataSource.reportFault(
            bikeId: tBikeId,
            type: tFaultType,
            description: null,
          ),
        ).called(1);
        expect(result, equals(Right(tFaultReportModel)));
      });

      test('should return ServerFailure when call is unsuccessful', () async {
        // arrange
        when(
          () => mockRemoteDataSource.reportFault(
            bikeId: tBikeId,
            type: tFaultType,
            description: null,
          ),
        ).thenThrow(ServerException());

        // act
        final result = await repository.reportFault(
          bikeId: tBikeId,
          type: tFaultType,
        );

        // assert
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.reportFault(
          bikeId: tBikeId,
          type: tFaultType,
        );

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(Left(NetworkFailure())));
      });
    });
  });
}
