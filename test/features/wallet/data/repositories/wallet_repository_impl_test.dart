import 'package:bike_app/core/error/exceptions.dart';
import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/network/network_info.dart';
import 'package:bike_app/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:bike_app/features/wallet/data/models/payment_method_model.dart';
import 'package:bike_app/features/wallet/data/models/transaction_model.dart';
import 'package:bike_app/features/wallet/data/models/wallet_model.dart';
import 'package:bike_app/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:bike_app/features/wallet/domain/entities/payment_method.dart';
import 'package:bike_app/features/wallet/domain/entities/transaction.dart';
import 'package:bike_app/features/wallet/domain/entities/wallet.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletRemoteDataSource extends Mock
    implements WalletRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late WalletRepositoryImpl repository;
  late MockWalletRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockWalletRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = WalletRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      const PaymentMethodModel(id: '', type: PaymentMethodType.card),
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

  group('getWallet', () {
    const tWalletModel = WalletModel(
      balance: 100.0,
      status: WalletStatus.active,
      hasCard: true,
    );

    runTestsOnline(() {
      test('should return wallet when remote call is successful', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getWallet(),
        ).thenAnswer((_) async => tWalletModel);

        // act
        final result = await repository.getWallet();

        // assert
        verify(() => mockRemoteDataSource.getWallet()).called(1);
        expect(result, const Right(tWalletModel));
      });

      test('should return ServerFailure when remote call fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getWallet(),
        ).thenThrow(ServerException());

        // act
        final result = await repository.getWallet();

        // assert
        verify(() => mockRemoteDataSource.getWallet()).called(1);
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.getWallet();

        // assert
        verifyNever(() => mockRemoteDataSource.getWallet());
        expect(result, Left(NetworkFailure()));
      });
    });
  });

  group('getTransactions', () {
    final tTransactionModels = [
      TransactionModel(
        id: '1',
        amount: 50.0,
        type: TransactionType.topUp,
        date: DateTime(2024, 1, 15),
        description: 'Top up',
      ),
    ];

    runTestsOnline(() {
      test(
        'should return transactions when remote call is successful',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.getTransactions(),
          ).thenAnswer((_) async => tTransactionModels);

          // act
          final result = await repository.getTransactions();

          // assert
          verify(() => mockRemoteDataSource.getTransactions()).called(1);
          expect(result, Right(tTransactionModels));
        },
      );

      test('should return ServerFailure when remote call fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getTransactions(),
        ).thenThrow(ServerException());

        // act
        final result = await repository.getTransactions();

        // assert
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.getTransactions();

        // assert
        expect(result, Left(NetworkFailure()));
      });
    });
  });

  group('topUpWallet', () {
    const tAmount = 50.0;
    const tMethod = 'blik';

    runTestsOnline(() {
      test('should return Unit when top up is successful', () async {
        // arrange
        when(
          () => mockRemoteDataSource.topUpWallet(
            amount: tAmount,
            method: tMethod,
          ),
        ).thenAnswer((_) async => {});

        // act
        final result = await repository.topUpWallet(
          amount: tAmount,
          method: tMethod,
        );

        // assert
        verify(
          () => mockRemoteDataSource.topUpWallet(
            amount: tAmount,
            method: tMethod,
          ),
        ).called(1);
        expect(result, const Right(unit));
      });

      test('should return ServerFailure when top up fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.topUpWallet(
            amount: tAmount,
            method: tMethod,
          ),
        ).thenThrow(ServerException());

        // act
        final result = await repository.topUpWallet(
          amount: tAmount,
          method: tMethod,
        );

        // assert
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.topUpWallet(
          amount: tAmount,
          method: tMethod,
        );

        // assert
        expect(result, Left(NetworkFailure()));
      });
    });
  });

  group('getPaymentMethods', () {
    const tPaymentMethodModels = [
      PaymentMethodModel(
        id: '1',
        type: PaymentMethodType.card,
        lastFourDigits: '4242',
        cardBrand: 'Visa',
      ),
    ];

    runTestsOnline(() {
      test(
        'should return payment methods when remote call is successful',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.getPaymentMethods(),
          ).thenAnswer((_) async => tPaymentMethodModels);

          // act
          final result = await repository.getPaymentMethods();

          // assert
          verify(() => mockRemoteDataSource.getPaymentMethods()).called(1);
          expect(result, const Right(tPaymentMethodModels));
        },
      );

      test('should return ServerFailure when remote call fails', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getPaymentMethods(),
        ).thenThrow(ServerException());

        // act
        final result = await repository.getPaymentMethods();

        // assert
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.getPaymentMethods();

        // assert
        expect(result, Left(NetworkFailure()));
      });
    });
  });

  group('addPaymentMethod', () {
    const tPaymentMethod = PaymentMethod(
      id: '1',
      type: PaymentMethodType.card,
      lastFourDigits: '4242',
      cardBrand: 'Visa',
    );

    runTestsOnline(() {
      test(
        'should return Unit when adding payment method is successful',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.addPaymentMethod(tPaymentMethod),
          ).thenAnswer((_) async => {});

          // act
          final result = await repository.addPaymentMethod(tPaymentMethod);

          // assert
          verify(
            () => mockRemoteDataSource.addPaymentMethod(tPaymentMethod),
          ).called(1);
          expect(result, const Right(unit));
        },
      );

      test(
        'should return ServerFailure when adding payment method fails',
        () async {
          // arrange
          when(
            () => mockRemoteDataSource.addPaymentMethod(tPaymentMethod),
          ).thenThrow(ServerException());

          // act
          final result = await repository.addPaymentMethod(tPaymentMethod);

          // assert
          expect(result, Left(ServerFailure()));
        },
      );
    });

    runTestsOffline(() {
      test('should return NetworkFailure when device is offline', () async {
        // act
        final result = await repository.addPaymentMethod(tPaymentMethod);

        // assert
        expect(result, Left(NetworkFailure()));
      });
    });
  });
}
