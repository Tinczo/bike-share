import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bike_app/features/wallet/domain/usecases/top_up_wallet.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late TopUpWallet usecase;
  late MockWalletRepository mockWalletRepository;

  setUp(() {
    mockWalletRepository = MockWalletRepository();
    usecase = TopUpWallet(mockWalletRepository);
  });

  const tAmount = 50.0;
  const tMethod = 'blik';

  test('should top up wallet via repository', () async {
    // arrange
    when(
      () => mockWalletRepository.topUpWallet(amount: tAmount, method: tMethod),
    ).thenAnswer((_) async => const Right(unit));

    // act
    final result = await usecase(
      const TopUpParams(amount: tAmount, method: tMethod),
    );

    // assert
    expect(result, const Right(unit));
    verify(
      () => mockWalletRepository.topUpWallet(amount: tAmount, method: tMethod),
    ).called(1);
    verifyNoMoreInteractions(mockWalletRepository);
  });

  test('should return failure when top up fails', () async {
    // arrange
    when(
      () => mockWalletRepository.topUpWallet(amount: tAmount, method: tMethod),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(
      const TopUpParams(amount: tAmount, method: tMethod),
    );

    // assert
    expect(result, Left(ServerFailure()));
    verify(
      () => mockWalletRepository.topUpWallet(amount: tAmount, method: tMethod),
    ).called(1);
    verifyNoMoreInteractions(mockWalletRepository);
  });

  test('should return NetworkFailure when no network connection', () async {
    // arrange
    when(
      () => mockWalletRepository.topUpWallet(amount: tAmount, method: tMethod),
    ).thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase(
      const TopUpParams(amount: tAmount, method: tMethod),
    );

    // assert
    expect(result, Left(NetworkFailure()));
  });

  group('TopUpParams', () {
    test('should support value equality', () {
      const params1 = TopUpParams(amount: 50.0, method: 'blik');
      const params2 = TopUpParams(amount: 50.0, method: 'blik');

      expect(params1, equals(params2));
    });

    test('props should contain amount and method', () {
      const params = TopUpParams(amount: 50.0, method: 'blik');

      expect(params.props, [50.0, 'blik']);
    });
  });
}
