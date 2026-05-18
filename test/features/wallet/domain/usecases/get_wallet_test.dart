import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/wallet/domain/entities/wallet.dart';
import 'package:bike_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bike_app/features/wallet/domain/usecases/get_wallet.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late GetWallet usecase;
  late MockWalletRepository mockWalletRepository;

  setUp(() {
    mockWalletRepository = MockWalletRepository();
    usecase = GetWallet(mockWalletRepository);
  });

  const tWallet = Wallet(
    balance: 100.0,
    status: WalletStatus.active,
    hasCard: true,
  );

  test('should get wallet from the repository', () async {
    // arrange
    when(
      () => mockWalletRepository.getWallet(),
    ).thenAnswer((_) async => const Right(tWallet));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(tWallet));
    verify(() => mockWalletRepository.getWallet()).called(1);
    verifyNoMoreInteractions(mockWalletRepository);
  });

  test('should return failure when getting wallet fails', () async {
    // arrange
    when(
      () => mockWalletRepository.getWallet(),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(ServerFailure()));
    verify(() => mockWalletRepository.getWallet()).called(1);
    verifyNoMoreInteractions(mockWalletRepository);
  });

  test('should return NetworkFailure when no network connection', () async {
    // arrange
    when(
      () => mockWalletRepository.getWallet(),
    ).thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(NetworkFailure()));
    verify(() => mockWalletRepository.getWallet()).called(1);
  });
}
