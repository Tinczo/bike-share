import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/wallet/domain/entities/payment_method.dart';
import 'package:bike_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bike_app/features/wallet/domain/usecases/get_payment_methods.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late GetPaymentMethods usecase;
  late MockWalletRepository mockWalletRepository;

  setUp(() {
    mockWalletRepository = MockWalletRepository();
    usecase = GetPaymentMethods(mockWalletRepository);
  });

  const tPaymentMethods = [
    PaymentMethod(
      id: '1',
      type: PaymentMethodType.card,
      lastFourDigits: '4242',
      cardBrand: 'Visa',
    ),
    PaymentMethod(id: '2', type: PaymentMethodType.blik),
  ];

  test('should get list of payment methods from the repository', () async {
    // arrange
    when(
      () => mockWalletRepository.getPaymentMethods(),
    ).thenAnswer((_) async => const Right(tPaymentMethods));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(tPaymentMethods));
    verify(() => mockWalletRepository.getPaymentMethods()).called(1);
    verifyNoMoreInteractions(mockWalletRepository);
  });

  test('should return empty list when no payment methods exist', () async {
    // arrange
    when(
      () => mockWalletRepository.getPaymentMethods(),
    ).thenAnswer((_) async => const Right(<PaymentMethod>[]));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(<PaymentMethod>[]));
    verify(() => mockWalletRepository.getPaymentMethods()).called(1);
  });

  test('should return failure when getting payment methods fails', () async {
    // arrange
    when(
      () => mockWalletRepository.getPaymentMethods(),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Left(ServerFailure()));
    verify(() => mockWalletRepository.getPaymentMethods()).called(1);
    verifyNoMoreInteractions(mockWalletRepository);
  });
}
