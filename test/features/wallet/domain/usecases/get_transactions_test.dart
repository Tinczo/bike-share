import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/wallet/domain/entities/transaction.dart';
import 'package:bike_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bike_app/features/wallet/domain/usecases/get_transactions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late GetTransactions usecase;
  late MockWalletRepository mockWalletRepository;

  setUp(() {
    mockWalletRepository = MockWalletRepository();
    usecase = GetTransactions(mockWalletRepository);
  });

  final tTransactions = [
    Transaction(
      id: '1',
      amount: 50.0,
      type: TransactionType.topUp,
      date: DateTime(2024, 1, 15),
      description: 'Top up via BLIK',
    ),
    Transaction(
      id: '2',
      amount: -5.0,
      type: TransactionType.fee,
      date: DateTime(2024, 1, 16),
      description: 'Rental fee',
    ),
  ];

  test('should get list of transactions from the repository', () async {
    // arrange
    when(
      () => mockWalletRepository.getTransactions(),
    ).thenAnswer((_) async => Right(tTransactions));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Right(tTransactions));
    verify(() => mockWalletRepository.getTransactions()).called(1);
    verifyNoMoreInteractions(mockWalletRepository);
  });

  test('should return empty list when no transactions exist', () async {
    // arrange
    when(
      () => mockWalletRepository.getTransactions(),
    ).thenAnswer((_) async => const Right(<Transaction>[]));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(<Transaction>[]));
    verify(() => mockWalletRepository.getTransactions()).called(1);
  });

  test('should return failure when getting transactions fails', () async {
    // arrange
    when(
      () => mockWalletRepository.getTransactions(),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(ServerFailure()));
    verify(() => mockWalletRepository.getTransactions()).called(1);
    verifyNoMoreInteractions(mockWalletRepository);
  });
}
